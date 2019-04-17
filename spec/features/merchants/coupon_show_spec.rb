require 'rails_helper'

RSpec.describe "As a merchant" do
  before :each do
    @merchant = create(:merchant)
    @user = create(:user)
    @c1 = @merchant.coupons.create(code: "10OFF", discount: 0.10)
    @c2 = @merchant.coupons.create(code: "25OFF", discount: 0.25, active: false)
    @c6 = @merchant.coupons.create(code: "60OFF", discount: 0.60)
    order = Order.create(user: @user, status: :pending, coupon: @c6.code)
  end

  describe "when I visit the coupon show page" do
    it "my coupon is displayed" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_content(@c1.discount*100)
    end

    it "has an Edit Coupon link" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Edit Coupon")
    end

    it "edits a coupon when I click Edit Coupon link, I'm returned to the coupon index and see the edited value on the coupon" do

      visit login_path
      fill_in :email, with: @merchant.email
      fill_in :password, with: @merchant.password
      click_button "Log in"

      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)

      click_on "Edit Coupon"

      expect(current_path).to eq(edit_dashboard_coupon_path(@c1))

      fill_in "Discount", with: 0.5
      click_button "Update Coupon"

      expect(current_path).to eq(dashboard_coupons_path)
      expect(page).to have_content("Your coupon edit has been saved.")

      within "#coupon-info-id-#{@c1.id}" do
        expect(page).to_not have_content("Discount: 10.0% Off")
        expect(page).to have_content("Discount: 50.0% Off")
      end
    end

    it "cannot edit coupon if coupon has been used" do
      # allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit login_path
      fill_in :email, with: @merchant.email
      fill_in :password, with: @merchant.password
      click_button "Log in"
      visit dashboard_coupon_path(@c6)

      click_on "Edit Coupon"

      expect(current_path).to eq(dashboard_coupon_path(@c6))
      expect(page).to have_content("You cannot edit this coupon.")
      expect(page).to have_content(@c6.code)
    end

    it "cannot delete a coupon if the coupon has been used" do
      visit login_path
      fill_in :email, with: @merchant.email
      fill_in :password, with: @merchant.password
      click_button "Log in"
      visit dashboard_coupon_path(@c6)

      click_on "Delete Coupon"

      expect(current_path).to eq(dashboard_coupons_path)
      expect(page).to have_content("You cannot delete this coupon.")
      expect(page).to have_content(@c6.code)
    end

    it "deletes a coupon when I click Delete Coupon link, I'm returned to the coupon index and do not see the deleted coupon" do
      visit login_path

      fill_in :email, with: @merchant.email
      fill_in :password, with: @merchant.password

      click_button "Log in"

      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)

      click_on "Delete Coupon"

      expect(current_path).to eq(dashboard_coupons_path)
      expect(page).to_not have_content(@c1.code)
    end

    it "in edit form it can be disabled and enabled" do
      visit login_path
      fill_in :email, with: @merchant.email
      fill_in :password, with: @merchant.password
      click_button "Log in"

      visit dashboard_coupon_path(@c2)

      expect(current_path).to eq(dashboard_coupon_path(@c2))
      expect(page).to have_content(@c2.code)

      click_link "Edit Coupon"

      expect(page).to have_unchecked_field('coupon_active')

      check('coupon_active')
      click_button "Update Coupon"
      visit dashboard_coupon_path(@c2)
      click_link "Edit Coupon"

      expect(page).to have_checked_field('coupon_active')
    end
  end
end
