class Dashboard::CouponsController < Dashboard::BaseController
  def index
    @coupons = current_user.coupons
  end

  def show
    @coupon = Coupon.find(params[:id])
  end

  def new
    @merchant = current_user
    @coupon = Coupon.new
  end

  def create
    @merchant = current_user
    @coupon = @merchant.coupons.new(coupon_params)
    @coupon.save
    redirect_to dashboard_coupons_path
  end

  private

  def coupon_params
    params.require(:coupon).permit(:code, :discount)
  end

end
