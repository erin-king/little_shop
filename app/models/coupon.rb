class Coupon < ApplicationRecord
  validates_presence_of :code
  validates_uniqueness_of :code
  validates_presence_of :discount

  belongs_to :user
end
