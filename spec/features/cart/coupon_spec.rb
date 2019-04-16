require 'rails_helper'

RSpec.describe "using coupons in the cart" do
  before :each do
    @user_1 = create(:user)
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)
    @item_1 = create(:item, user: @merchant_1, inventory: 3)
    @item_2 = create(:item, user: @merchant_2)
    @item_3 = create(:item, user: @merchant_2)
    @coupon_10 = @merchant_1.coupons.create(code: "10OFF", discount: 0.1)
  end

  describe "as a visitor or regular user when I visit my cart" do
    it "I can see a coupon code field and submit button" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)
      # visit login_path
      # fill_in :email, with: @user_1.email
      # fill_in :password, with: @user_1.password
      # click_button "Log in"
      visit item_path(@item_1)
      click_on "Add to Cart"
      visit cart_path

      fill_in "Code", with: "10OFF"
      click_button "Apply Coupon"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("You've added your coupon!")
      expect(page).to have_content("10OFF")
    end
  end
end
