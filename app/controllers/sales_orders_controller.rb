class SalesOrdersController < ApplicationController
  def release
    @order    = SalesOrder.find(params[:id])
    @customer = @order.customer
    alice     = User.find_by!(email: "alice.chen@erpdemo.com")

    @order.transaction do
      @order.update!(status: "released")

      OrderCreditHoldEvent.create!(
        sales_order:         @order,
        triggered_by_rule:   nil,
        event_type:          "released",
        event_date:          Time.current,
        actor:               alice,
        override_reason:     "Manually approved via order review",
        credit_snapshot:     {
          credit_limit:    @customer.customer_credit_profile.credit_limit,
          released_by:     alice.name,
          released_at:     Time.current.iso8601
        }
      )
    end

    redirect_to orders_customer_path(@customer),
                notice: "Order released — #{@customer.name} can now proceed."
  end
end
