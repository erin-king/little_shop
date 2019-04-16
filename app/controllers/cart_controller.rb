class CartController < ApplicationController
  before_action :visitor_or_user

  def show
    @coupon = Coupon.find(session[:coupon]) if session[:coupon]
  end

  def add_coupon
    if coupon = Coupon.find_by(code: params[:code])
      session[:coupon] = coupon.id
      flash[:success] = "You've added your coupon!"
    else
      flash[:alert] = "Not a coupon. Please try again."
    end
    redirect_to cart_path
  end

  def increment
    item = Item.find(params[:id])
    if item.inventory <= cart.count_of(item.id)
      flash[:danger] = "The Merchant does not have enough inventory."
    else
      cart.add_item(item.id)
      session[:cart] = cart.contents
      flash[:success] = "#{item.name} has been added to your cart!"
    end
    redirect_to cart_path
  end

  def decrement
    item = Item.find(params[:id])
    cart.remove_item(item.id)
    session[:cart] = cart.contents
    flash[:success] = "#{item.name} has been removed from your cart."
    redirect_to cart_path
  end

  def destroy
    session.delete(:cart)
    redirect_to cart_path
  end

  def remove_item
    item = Item.find(params[:id])
    session[:cart].delete(item.id.to_s)
    flash[:success] = "#{item.name} has been removed from your cart."
    redirect_to cart_path
  end
end
