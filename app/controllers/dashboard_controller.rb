class DashboardController < ApplicationController
  def index
    held = Customer
      .joins(:customer_credit_profile)
      .where(customer_credit_profiles: { credit_hold_flag: true })
      .includes(:customer_credit_profile, sales_orders: :invoices)
      .order(:name)

    @held_customers = held.map do |customer|
      profile  = customer.customer_credit_profile
      invoices = customer.invoices.to_a
      orders   = customer.sales_orders.to_a

      overdue_amount  = invoices.select(&:overdue?).sum { |i| i.total_amount - i.paid_amount }
      open_amount     = invoices.select { |i| i.open? || i.partially_paid? }.sum { |i| i.total_amount - i.paid_amount }
      pending_orders  = orders.select(&:pending_credit_check?)
      pending_amount  = pending_orders.sum(&:total_amount)
      total_exposure  = overdue_amount + open_amount + pending_amount
      utilization_pct = profile.credit_limit > 0 ? (total_exposure / profile.credit_limit * 100).round : 0

      {
        customer:             customer,
        profile:              profile,
        overdue_amount:       overdue_amount,
        open_amount:          open_amount,
        pending_orders_count: pending_orders.size,
        pending_amount:       pending_amount,
        total_exposure:       total_exposure,
        utilization_pct:      utilization_pct
      }
    end

    @summary = {
      count:                 @held_customers.size,
      total_overdue:         @held_customers.sum { |r| r[:overdue_amount] },
      total_exposure:        @held_customers.sum { |r| r[:total_exposure] },
      total_pending_orders:  @held_customers.sum { |r| r[:pending_orders_count] }
    }
  end
end
