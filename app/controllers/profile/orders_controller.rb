class Profile::OrdersController < ApplicationController
  before_action :require_reguser

  def index
    @user = current_user
    @orders = current_user.orders
  end

  def show
    @order = Order.find(params[:id])
  end

  def destroy
    @order = Order.find(params[:id])
    if @order.user == current_user
      @order.order_items.where(fulfilled: true).each do |oi|
        item = Item.find(oi.item_id)
        item.inventory += oi.quantity
        item.save
        oi.fulfilled = false
        oi.save
      end

      @order.status = :cancelled
      @order.save

      redirect_to profile_orders_path
    else
      render file: 'public/404', status: 404
    end
  end

  def create
    coupon = Coupon.find(session[:coupon]["id"]).code || "" if session[:coupon]
    order = Order.create(user: current_user, status: :pending, coupon: coupon)
    cart.items.each do |item, quantity|
      discount = apply_discount(item)
      order.order_items.create(item: item, quantity: quantity, price: item.price-discount, discount: discount)
    end
    session.delete(:cart)
    flash[:success] = "Your order has been created!"
    redirect_to profile_orders_path
  end

  private

  def apply_discount(item)
    coupon = Coupon.find(session[:coupon]["id"]) if session[:coupon]
    discount = 0
      if coupon && coupon.user_id == item.merchant_id
        discount = item.price * coupon.discount
      else
        discount = 0
      end
    discount
  end
end
