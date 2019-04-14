class MerchantsController < ApplicationController
  def index
    if current_admin?
      @merchants = User.where(role: :merchant)
    else
      @merchants = User.active_merchants
    end
    @top_ten_merchants_by_items_this_month = @merchants.top_ten_merchants_by_items(DateTime.now.beginning_of_month, DateTime.now.end_of_month)
    @top_ten_merchants_by_items_last_month = @merchants.top_ten_merchants_by_items(DateTime.now.last_month.beginning_of_month, DateTime.now.last_month.end_of_month)
    @top_ten_merchants_by_fulfilled_orders_this_month = @merchants.top_ten_merchants_by_fulfilled_orders(DateTime.now.beginning_of_month, DateTime.now.end_of_month)
    @top_ten_merchants_by_fulfilled_orders_last_month = @merchants.top_ten_merchants_by_fulfilled_orders(DateTime.now.last_month.beginning_of_month, DateTime.now.last_month.end_of_month)
    
    @top_three_merchants_by_revenue = @merchants.top_merchants_by_revenue(3)
    @top_three_merchants_by_fulfillment = @merchants.top_merchants_by_fulfillment_time(3)
    @bottom_three_merchants_by_fulfillment = @merchants.bottom_merchants_by_fulfillment_time(3)
    @top_states_by_order_count = User.top_user_states_by_order_count(3)
    @top_cities_by_order_count = User.top_user_cities_by_order_count(3)
    @top_orders_by_items_shipped = Order.sorted_by_items_shipped(3)
  end
end
