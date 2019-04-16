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
    @coupon_20 = @merchant_2.coupons.create(code: "20OFF", discount: 0.2)
  end

  describe "as a visitor or regular user when I visit my cart" do
    it "I can add one and only one coupon code to my cart and I can change coupons until checkout" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit item_path(@item_1)
      click_on "Add to Cart"
      visit cart_path

      fill_in "Code", with: @coupon_10.code
      click_button "Apply Coupon"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("You've added your coupon!")
      expect(page).to have_content("10OFF")

      visit cart_path

      fill_in "Code", with: @coupon_20.code
      click_button "Apply Coupon"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("You've added your coupon!")
      expect(page).to_not have_content("10OFF")
      expect(page).to have_content("20OFF")
    end

    it "my coupon persists if I navigate to a different page and return" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit item_path(@item_1)
      click_on "Add to Cart"
      visit cart_path

      fill_in "Code", with: "10OFF"
      click_button "Apply Coupon"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("You've added your coupon!")
      expect(page).to have_content("10OFF")

      visit item_path(@item_2)
      visit cart_path

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("10OFF")
    end
  end
end
  # <h4 id="flamin-hot">Discounted Total: <%= number_to_currency(cart.discounted_total) %></h4>
