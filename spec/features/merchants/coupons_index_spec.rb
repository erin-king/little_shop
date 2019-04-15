require 'rails_helper'

RSpec.describe "merchant coupon index" do
  before :each do
    @merchant = create(:merchant)
    # @i1, @i2, @i3, @i4, @i5 = create_list(:item, 5, user: @merchant)
    @c1 = @merchant.coupons.create(code: "10OFF", discount: 0.10)
    @c2 = @merchant.coupons.create(code: "15OFF", discount: 0.15)
    @c3 = @merchant.coupons.create(code: "20OFF", discount: 0.20)
    @c4 = @merchant.coupons.create(code: "25OFF", discount: 0.25)
    @c5 = @merchant.coupons.create(code: "50OFF", discount: 0.50)
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

    within "#coupon-info-id-#{@c5.id}" do
      expect(page).to have_link(@c5.code)
      expect(page).to have_content(@c5.discount*100)
    end

    click_link @c5.code
    expect(current_path).to eq(dashboard_coupon_path(@c5))
  end
end
