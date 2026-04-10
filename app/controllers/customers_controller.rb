class CustomersController < ApplicationController
  before_action :load_customer

  # GET /customers/:id
  def show
    today = Date.today
    all_invoices = @customer.invoices.to_a
    unpaid = all_invoices.reject(&:paid?)

    @aging = {
      current:      unpaid.select { |i| i.due_date >= today },
      days_1_30:    unpaid.select { |i| i.due_date >= today - 30 && i.due_date < today },
      days_31_60:   unpaid.select { |i| i.due_date >= today - 60 && i.due_date < today - 30 },
      days_60_plus: unpaid.select { |i| i.due_date < today - 60 }
    }
  end

  # GET /customers/:id/orders
  def orders
    @pending_orders = @customer.sales_orders.select(&:pending_credit_check?).sort_by(&:order_date).reverse
  end

  # GET /customers/:id/export_orders.csv
  def export_orders
    orders = @customer.sales_orders.includes(sales_order_lines: :product).order(order_date: :desc)

    csv = CSV.generate(headers: true) do |rows|
      rows << %w[order_id order_date status total_amount currency]
      orders.each do |o|
        rows << [o.id, o.order_date, o.status, o.total_amount, o.currency_code]
      end
    end

    send_data csv,
              filename: "#{@customer.name.parameterize}-orders-#{Date.today}.csv",
              type: "text/csv", disposition: "attachment"
  end

  # GET /customers/:id/export_invoices.csv
  def export_invoices
    invoices = @customer.invoices.includes(:sales_order).order(due_date: :asc)

    csv = CSV.generate(headers: true) do |rows|
      rows << %w[invoice_id order_id invoice_date due_date total paid outstanding status days_overdue]
      invoices.each do |i|
        outstanding  = i.total_amount - i.paid_amount
        days_overdue = i.due_date < Date.today && !i.paid? ? (Date.today - i.due_date).to_i : 0
        rows << [i.id, i.sales_order_id, i.invoice_date, i.due_date,
                 i.total_amount, i.paid_amount, outstanding, i.status, days_overdue]
      end
    end

    send_data csv,
              filename: "#{@customer.name.parameterize}-invoices-#{Date.today}.csv",
              type: "text/csv", disposition: "attachment"
  end

  # GET /customers/:id/export_interactions.csv
  def export_interactions
    interactions = @customer.customer_interactions.includes(:actor).order(interaction_date: :desc)

    csv = CSV.generate(headers: true) do |rows|
      rows << %w[date type sentiment summary logged_by]
      interactions.each do |i|
        rows << [i.interaction_date, i.interaction_type, i.sentiment, i.summary, i.actor.name]
      end
    end

    send_data csv,
              filename: "#{@customer.name.parameterize}-interactions-#{Date.today}.csv",
              type: "text/csv", disposition: "attachment"
  end

  private

  def load_customer
    @customer = Customer
      .includes(
        :customer_credit_profile,
        :crm_account,
        sales_orders: [:invoices, { sales_order_lines: :product }],
        customer_interactions: :actor
      )
      .find(params[:id])

    @profile     = @customer.customer_credit_profile
    @crm_account = @customer.crm_account

    invoices        = @customer.invoices.to_a
    orders          = @customer.sales_orders.to_a
    @overdue_amount = invoices.select(&:overdue?).sum { |i| i.total_amount - i.paid_amount }
    @open_amount    = invoices.select { |i| i.open? || i.partially_paid? }.sum { |i| i.total_amount - i.paid_amount }
    @pending_count  = orders.count(&:pending_credit_check?)
    @total_exposure = @overdue_amount + @open_amount +
                      orders.select(&:pending_credit_check?).sum(&:total_amount)
    @utilization_pct = @profile.credit_limit > 0 ?
                       (@total_exposure / @profile.credit_limit * 100).round : 0
  end
end
