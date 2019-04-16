class Dashboard::CouponsController < Dashboard::BaseController

  def index
    @coupons = current_user.coupons
  end

  def show
    @coupon = Coupon.find(params[:id])
  end

  def new
    if check_coupons?
      flash[:alert] = "You have reached your maximum of 5 coupons."
      redirect_to dashboard_coupons_path
    else
      @coupon = Coupon.new
    end
  end

  def create
    @coupon = current_user.coupons.new(coupon_params)
    @coupon.active = true
    if @coupon.save
      flash[:success] = "Your coupon has been added!"
      redirect_to dashboard_coupons_path
    else
      flash[:danger] = @coupon.errors.full_messages
      render :new
    end
  end

  def destroy
    @coupon = Coupon.find(params[:id])
    if @coupon && @coupon.user == current_user
      # if @coupon && @coupon.used?
      #   flash[:error] = "You cannot delete this coupon."
      # else
        @coupon.destroy
      # end
      redirect_to dashboard_coupons_path
    else
      render file: 'public/404', status: 404
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:code, :discount)
  end

end
