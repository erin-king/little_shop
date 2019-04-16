require 'rails_helper'

RSpec.describe "As a merchant" do
  before :each do
    @merchant = create(:merchant)
    @c1 = @merchant.coupons.create(code: "10OFF", discount: 0.10)
    @c2 = @merchant.coupons.create(code: "25OFF", discount: 0.25, active: false)
    @c6 = @merchant.coupons.create(code: "60OFF", discount: 0.60)
  end

  describe "when I visit the coupon show page" do
    it "my coupon is displayed" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_content(@c1.discount*100)
    end

    it "has a Add New Coupon link" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Add New Coupon")
    end

    it "when I click Add New Coupon I am directed to a form where I enter a new coupon and am returned to the index page and I see my new coupon" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c1)

      click_link "Add New Coupon"

      expect(current_path).to eq(new_dashboard_coupon_path)

      fill_in "Code", with: "Freebie"
      fill_in "Discount", with: 1.0
      click_button "Create Coupon"

      new_coupon = Coupon.last

      expect(current_path).to eq(dashboard_coupons_path)
      expect(page).to have_content("Your coupon has been added!")
      expect(page).to have_content("Code: #{new_coupon.code}")
      expect(page).to have_content("Discount: #{new_coupon.discount*100}")
    end

    it "I cannot add a new coupon if I have five coupons, I see a flash message telling me so, I am directed to the index page" do
      @c3 = @merchant.coupons.create(code: "10OFF", discount: 0.10)
      @c4 = @merchant.coupons.create(code: "40OFF", discount: 0.40, active: false)
      @c5 = @merchant.coupons.create(code: "50OFF", discount: 0.50, active: false)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c1)

      click_link "Add New Coupon"

      expect(current_path).to eq(dashboard_coupons_path)
      expect(page).to have_content("You have reached your maximum of 5 coupons.")
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

    xit "cannot Edit Coupon if coupon has been used" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c6)

      expect(current_path).to eq(dashboard_coupon_path(@c6))
      expect(page).to have_content("You cannot delete this coupon.")
      expect(page).to have_content(@c6.code)
    end

    it "has a Delete Coupon link" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Delete Coupon")
    end

    xit "cannot Delete Coupon if coupon has been used" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c6)

      expect(current_path).to eq(dashboard_coupon_path(@c6))
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

    it "has a Disable Coupon link" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c1)

      expect(current_path).to eq(dashboard_coupon_path(@c1))
      expect(page).to have_content(@c1.code)
      expect(page).to have_link("Disable Coupon")
      expect(page).to_not have_link("Enable Coupon")
    end

    it "has an Enable Coupon link" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_coupon_path(@c2)

      expect(current_path).to eq(dashboard_coupon_path(@c2))
      expect(page).to have_content(@c2.code)
      expect(page).to have_link("Enable Coupon")
      expect(page).to_not have_link("Disable Coupon")
    end
  end
end
