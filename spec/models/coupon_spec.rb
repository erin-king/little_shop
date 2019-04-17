require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of :code }
    it { should validate_presence_of :discount }
  end

  describe 'relationships' do
    it {should belong_to :user}
  end

  describe 'instance methods' do
    describe "it determines if a coupon has even been used" do
      it "#used?" do
        user_1 = create(:user)
        merchant_1 = create(:merchant)
        merchant_2 = create(:merchant)
        item_1 = create(:item, user: merchant_1)
        item_2 = create(:item, user: merchant_2)
        coupon_10 = merchant_1.coupons.create(code: "10OFF", discount: 0.1)
        coupon_20 = merchant_2.coupons.create(code: "20OFF", discount: 0.2)
        order = Order.create(user: user_1, status: :pending, coupon: coupon_10.code)

        expect(coupon_10.used?).to eq(true)
        expect(coupon_20.used?).to eq(false)
      end
    end
  end
end
