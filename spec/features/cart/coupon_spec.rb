require 'rails_helper'

RSpec.describe "using coupons in the cart" do
  before :each do
    @user_1 = create(:user)
    @user_2 = create(:user)
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

      fill_in "Code", with: @coupon_10.code
      click_button "Apply Coupon"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("You've added your coupon!")
      expect(page).to have_content("10OFF")

      visit item_path(@item_2)
      visit cart_path

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("10OFF")
    end

    it "displays discounted total in cart when coupon is applied and can only be applied to the coupon's merchant's items" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit item_path(@item_1)
      click_on "Add to Cart"
      visit item_path(@item_2)
      click_on "Add to Cart"
      visit cart_path

      fill_in "Code", with: @coupon_10.code
      click_button "Apply Coupon"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("You've added your coupon!")
      expect(page).to have_content("10OFF")
      expect(page).to have_content("Total: $7.50")
      #item_1 = $3, coupon applied to item_1 , item_2 = 4.5
      expect(page).to have_content("Discounted Total: $7.20")
    end

    it "displays discounted total in cart when coupon is applied and can only be applied to the coupon's merchant's items" do
      visit login_path
      fill_in :email, with: @user_1.email
      fill_in :password, with: @user_1.password
      click_button "Log in"

      visit item_path(@item_1)
      click_on "Add to Cart"
      visit item_path(@item_2)
      click_on "Add to Cart"
      visit cart_path

      fill_in "Code", with: @coupon_10.code
      click_button "Apply Coupon"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("You've added your coupon!")
      expect(page).to have_content("10OFF")
      expect(page).to have_content("Total: $7.50")
      #item_1 = $3, coupon applied to item_1 , item_2 = 4.5
      expect(page).to have_content("Discounted Total: $7.20")

      visit logout_path

      visit login_path
      fill_in :email, with: @user_2.email
      fill_in :password, with: @user_2.password
      click_button "Log in"

      visit item_path(@item_1)
      click_on "Add to Cart"
      visit item_path(@item_1)
      click_on "Add to Cart"
      visit item_path(@item_2)
      click_on "Add to Cart"
      visit cart_path

      fill_in "Code", with: @coupon_10.code
      click_button "Apply Coupon"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("You've added your coupon!")
      expect(page).to have_content("10OFF")
      expect(page).to have_content("Total: $10.50")
      #item_1 = $3, coupon applied to item_1 , item_2 = 4.5
      expect(page).to have_content("Discounted Total: $9.90")
    end
  end
end
