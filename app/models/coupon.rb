class Coupon < ApplicationRecord
  validates_presence_of :code
  validates_uniqueness_of :code
  validates_presence_of :discount

  belongs_to :user

  def used?
    Order.where(coupon: self.code).count > 0
  end

  def self.already_used?(coupon_code, user)
    Order.where(coupon: coupon_code).where(user_id: user.id).count > 0
  end
end
