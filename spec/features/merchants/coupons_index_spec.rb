require 'rails_helper'

RSpec.describe "merchant coupon index" do
  before :each do
    @merchant = create(:merchant)
    @c1 = @merchant.coupons.create(code: "10OFF", discount: 0.10)
    @c2 = @merchant.coupons.create(code: "15OFF", discount: 0.15)
    @c3 = @merchant.coupons.create(code: "20OFF", discount: 0.20)
    @c4 = @merchant.coupons.create(code: "25OFF", discount: 0.25)
  end

  it "displays all coupons for the merchant and each coupon code is a link to its show page" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    visit dashboard_path

    click_link "Manage My Coupons"

    expect(current_path).to eq(dashboard_coupons_path)

    within "#coupon-info-id-#{@c1.id}" do
      expect(page).to have_link(@c1.code)
      expect(page).to have_content(@c1.discount*100)
    end

    within "#coupon-info-id-#{@c2.id}" do
      expect(page).to have_link(@c2.code)
      expect(page).to have_content(@c2.discount*100)
    end

    within "#coupon-info-id-#{@c3.id}" do
      expect(page).to have_link(@c3.code)
      expect(page).to have_content(@c3.discount*100)
    end

    within "#coupon-info-id-#{@c4.id}" do
      expect(page).to have_link(@c4.code)
      expect(page).to have_content(@c4.discount*100)
    end

    click_link @c4.code

    expect(current_path).to eq(dashboard_coupon_path(@c4))
  end

  it "has an Add New Coupon link" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

    visit dashboard_coupons_path

    expect(current_path).to eq(dashboard_coupons_path)
    expect(page).to have_link("Add New Coupon")
  end

  it "when I click Add New Coupon I am directed to a form where I enter a new coupon and am returned to the index page and I see my new coupon" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

    visit dashboard_coupons_path

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
    @c5 = @merchant.coupons.create(code: "50OFF", discount: 0.50)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

    visit dashboard_coupons_path

    click_link "Add New Coupon"

    expect(current_path).to eq(dashboard_coupons_path)
    expect(page).to have_content("You have reached your maximum of 5 coupons.")
  end
end
