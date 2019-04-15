class Dashboard::CouponsController < Dashboard::BaseController
  def index
    @coupons = current_user.coupons
  end

  def show

  end
end
