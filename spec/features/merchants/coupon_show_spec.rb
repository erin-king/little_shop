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
      expect(page).to have_content(@c1.discount*100)
    end

    it "has a Add New Coupon link" do
      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Add New Coupon")
    end

    it "when I click Add New Coupon I am directed to a form where I enter a new coupon and am returned to the index page and I see my new coupon" do
      visit dashboard_coupon_path(@c1)

      click_link "Add New Coupon"

      expect(current_path).to eq(new_dashboard_coupon_path)

      fill_in "Code", with: "Freebie"
      fill_in "Discount", with: 1.0
      click_button "Create Coupon"

      new_coupon = Coupon.last
save_and_open_page
      expect(current_path).to eq(dashboard_coupons_path)
      expect(page).to have_content("Code: #{new_coupon.code}")
      expect(page).to have_content("Discount: #{new_coupon.discount*100}")
    end

    xit "I cannot add a new coupon if I have five coupons, I see a flash message telling me so, I am directed to the index page" do

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
