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
    describe "#used?" do
      it "it determines if a coupon has even been used" do
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
  
  describe 'class methods' do
    describe ".already_used?" do
      it "determines if a coupon had already been used by a user in a different order" do
        user_1 = create(:user)
        merchant_1 = create(:merchant)
        item_1 = create(:item, user: merchant_1)
        coupon_10 = merchant_1.coupons.create(code: "10OFF", discount: 0.1)

        expect(Coupon.already_used?(coupon_10.code, user_1)).to eq(false)

        user_1 = create(:user)
        merchant_1 = create(:merchant)
        item_1 = create(:item, user: merchant_1)
        coupon_10 = merchant_1.coupons.create(code: "10OFF", discount: 0.1)
        order = Order.create(user: user_1, status: :pending, coupon: coupon_10.code)

        expect(Coupon.already_used?(coupon_10.code, user_1)).to eq(true)
      end
    end
  end
end
