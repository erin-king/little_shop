require 'rails_helper'

RSpec.describe "As a merchant" do
  before :each do
    @merchant = create(:merchant)
    @c1 = @merchant.coupons.create(code: "10OFF", discount: 0.10)
    @c2 = @merchant.coupons.create(code: "10OFF", discount: 0.10, active: false)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
  end

  describe "when I visit the coupon show page" do
    it "my coupon is displayed" do
      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_content(@c1.discount)
    end

    it "has a Add New Coupon link" do
      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Add New Coupon")
    end

    it "has an Edit Coupon link" do
      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Edit Coupon")
    end

    it "has a Delete Coupon link" do
      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Edit Coupon")
    end

    it "has a Disable Coupon link" do
      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Disable Coupon")
      expect(page).to_not have_link("Enable Coupon")
    end

    it "has an Enable Coupon link" do
      visit dashboard_coupon_path(@c2)

      expect(current_path).to eq(dashboard_coupon_path(@c2))
      expect(page).to have_content(@c2.code)
      expect(page).to have_link("Enable Coupon")
      expect(page).to_not have_link("Disable Coupon")
    end
  end
end
