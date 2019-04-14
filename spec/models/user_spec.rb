require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :password }
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    # as user
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders)}
    # as merchant
    it { should have_many :items }
  end

  describe 'roles' do
    it 'can be created as a default user' do
      user = User.create(
        email: "email",
        password: "password",
        name: "name",
        address: "address",
        city: "city",
        state: "state",
        zip: "zip"
      )
      expect(user.role).to eq('default')
      expect(user.default?).to be_truthy
    end

    it 'can be created as a merchant' do
      user = User.create(
        email: "email",
        password: "password",
        name: "name",
        address: "address",
        city: "city",
        state: "state",
        zip: "zip",
        role: 1
      )
      expect(user.role).to eq('merchant')
      expect(user.merchant?).to be_truthy
    end

    it 'can be created as an admin' do
      user = User.create(
        email: "email",
        password: "password",
        name: "name",
        address: "address",
        city: "city",
        state: "state",
        zip: "zip",
        role: 2
      )
      expect(user.role).to eq('admin')
      expect(user.admin?).to be_truthy
    end
  end

  describe 'instance methods' do
    before :each do
      @u1 = create(:user, state: "CO", city: "Anywhere")
      @u2 = create(:user, state: "OK", city: "Tulsa")
      @u3 = create(:user, state: "IA", city: "Anywhere")
      u4 = create(:user, state: "IA", city: "Des Moines")
      u5 = create(:user, state: "IA", city: "Des Moines")
      u6 = create(:user, state: "IA", city: "Des Moines")

      @m1 = create(:merchant)
      @i1 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i2 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i3 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i4 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i5 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i6 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i7 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i8 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i9 = create(:inactive_item, merchant_id: @m1.id)

      @m2 = create(:merchant)
      @i10 = create(:item, merchant_id: @m2.id, inventory: 20)

      o1 = create(:shipped_order, user: @u1)
      o2 = create(:shipped_order, user: @u2)
      o3 = create(:shipped_order, user: @u3)
      o4 = create(:shipped_order, user: @u1)
      o5 = create(:shipped_order, user: @u1)
      o6 = create(:cancelled_order, user: u5)
      o7 = create(:order, user: u6)
      @oi1 = create(:order_item, item: @i1, order: o1, quantity: 2, created_at: 1.days.ago)
      @oi2 = create(:order_item, item: @i2, order: o2, quantity: 8, created_at: 7.days.ago)
      @oi3 = create(:order_item, item: @i2, order: o3, quantity: 6, created_at: 7.days.ago)
      @oi4 = create(:order_item, item: @i3, order: o3, quantity: 4, created_at: 6.days.ago)
      @oi5 = create(:order_item, item: @i4, order: o4, quantity: 3, created_at: 4.days.ago)
      @oi6 = create(:order_item, item: @i5, order: o5, quantity: 1, created_at: 5.days.ago)
      @oi7 = create(:order_item, item: @i6, order: o6, quantity: 2, created_at: 3.days.ago)
      @oi1.fulfill
      @oi2.fulfill
      @oi3.fulfill
      @oi4.fulfill
      @oi5.fulfill
      @oi6.fulfill
      @oi7.fulfill
    end

    it '.active_items' do
      expect(@m2.active_items).to eq([@i10])
      expect(@m1.active_items).to eq([@i1, @i2, @i3, @i4, @i5, @i6, @i7, @i8])
    end

    it '.top_items_sold_by_quantity' do
      expect(@m1.top_items_sold_by_quantity(5).length).to eq(5)
      expect(@m1.top_items_sold_by_quantity(5)[0].name).to eq(@i2.name)
      expect(@m1.top_items_sold_by_quantity(5)[0].quantity).to eq(14)
      expect(@m1.top_items_sold_by_quantity(5)[1].name).to eq(@i3.name)
      expect(@m1.top_items_sold_by_quantity(5)[1].quantity).to eq(4)
      expect(@m1.top_items_sold_by_quantity(5)[2].name).to eq(@i4.name)
      expect(@m1.top_items_sold_by_quantity(5)[2].quantity).to eq(3)
      expect(@m1.top_items_sold_by_quantity(5)[3].name).to eq(@i1.name)
      expect(@m1.top_items_sold_by_quantity(5)[3].quantity).to eq(2)
      expect(@m1.top_items_sold_by_quantity(5)[4].name).to eq(@i5.name)
      expect(@m1.top_items_sold_by_quantity(5)[4].quantity).to eq(1)
    end

    it '.total_items_sold' do
      expect(@m1.total_items_sold).to eq(24)
    end

    it '.percent_of_items_sold' do
      expect(@m1.percent_of_items_sold.round(2)).to eq(17.39)
    end

    it '.total_inventory_remaining' do
      expect(@m1.total_inventory_remaining).to eq(138)
    end

    it '.top_states_by_items_shipped' do
      expect(@m1.top_states_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_states_by_items_shipped(3)[0].quantity).to eq(10)
      expect(@m1.top_states_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_states_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_states_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_states_by_items_shipped(3)[2].quantity).to eq(6)
    end

    it '.top_cities_by_items_shipped' do
      expect(@m1.top_cities_by_items_shipped(3)[0].city).to eq("Anywhere")
      expect(@m1.top_cities_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_cities_by_items_shipped(3)[0].quantity).to eq(10)
      expect(@m1.top_cities_by_items_shipped(3)[1].city).to eq("Tulsa")
      expect(@m1.top_cities_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_cities_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_cities_by_items_shipped(3)[2].city).to eq("Anywhere")
      expect(@m1.top_cities_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_cities_by_items_shipped(3)[2].quantity).to eq(6)
    end

    it '.top_users_by_money_spent' do
      expect(@m1.top_users_by_money_spent(3)[0].name).to eq(@u3.name)
      expect(@m1.top_users_by_money_spent(3)[0].total.to_f).to eq(66.00)
      expect(@m1.top_users_by_money_spent(3)[1].name).to eq(@u1.name)
      expect(@m1.top_users_by_money_spent(3)[1].total.to_f).to eq(43.50)
      expect(@m1.top_users_by_money_spent(3)[2].name).to eq(@u2.name)
      expect(@m1.top_users_by_money_spent(3)[2].total.to_f).to eq(36.00)
    end

    it '.top_user_by_order_count' do
      expect(@m1.top_user_by_order_count.name).to eq(@u1.name)
      expect(@m1.top_user_by_order_count.count).to eq(3)
    end

    it '.top_user_by_item_count' do
      expect(@m1.top_user_by_item_count.name).to eq(@u3.name)
      expect(@m1.top_user_by_item_count.quantity).to eq(10)
    end
  end

  describe 'class methods' do
    it ".active_merchants" do
      active_merchants = create_list(:merchant, 3)
      inactive_merchant = create(:inactive_merchant)

      expect(User.active_merchants).to eq(active_merchants)
    end

    it '.default_users' do
      users = create_list(:user, 3)
      merchant = create(:merchant)
      admin = create(:admin)

      expect(User.default_users).to eq(users)
    end

    describe "statistics" do
      before :each do
        u1 = create(:user, state: "CO", city: "Fairfield")
        u2 = create(:user, state: "OK", city: "OKC")
        u3 = create(:user, state: "IA", city: "Fairfield")
        u4 = create(:user, state: "IA", city: "Des Moines")
        u5 = create(:user, state: "IA", city: "Des Moines")
        u6 = create(:user, state: "IA", city: "Des Moines")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7 = create_list(:merchant, 7)
        @i1 = create(:item, merchant_id: @m1.id)
        @i2 = create(:item, merchant_id: @m2.id)
        @i3 = create(:item, merchant_id: @m3.id)
        @i4 = create(:item, merchant_id: @m4.id)
        @i5 = create(:item, merchant_id: @m5.id)
        @i6 = create(:item, merchant_id: @m6.id)
        @i7 = create(:item, merchant_id: @m7.id)
        o1 = create(:shipped_order, user: u1)
        o2 = create(:shipped_order, user: u2)
        o3 = create(:shipped_order, user: u3)
        o4 = create(:shipped_order, user: u1)
        o5 = create(:cancelled_order, user: u5)
        o6 = create(:shipped_order, user: u6)
        o7 = create(:shipped_order, user: u6)
        oi1 = create(:fulfilled_order_item, item: @i1, order: o1, created_at: 1.days.ago)
        oi2 = create(:fulfilled_order_item, item: @i2, order: o2, created_at: 7.days.ago)
        oi3 = create(:fulfilled_order_item, item: @i3, order: o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: @i4, order: o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: @i5, order: o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: @i6, order: o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: @i7, order: o7, created_at: 2.days.ago)
      end

      it ".top_five_fastest_fulfilling_merchants_user_city(city)" do
        u7 = create(:user, state: "MI", city: "Frankenmuth")
        @m8 = create(:merchant)
        @m9 = create(:merchant)
        @m10 = create(:merchant)
        @m11 = create(:merchant)
        @m12 = create(:merchant)
        @m13 = create(:merchant)
        i8 = create(:item, merchant_id: @m8.id)
        i9 = create(:item, merchant_id: @m9.id)
        i10 = create(:item, merchant_id: @m10.id)
        i11 = create(:item, merchant_id: @m11.id)
        i12 = create(:item, merchant_id: @m12.id)
        i13 = create(:item, merchant_id: @m13.id)
        o8 = create(:shipped_order, user: u7)
        o9 = create(:shipped_order, user: u7)
        o10 = create(:shipped_order, user: u7)
        o11 = create(:shipped_order, user: u7)
        o12 = create(:shipped_order, user: u7)
        o13 = create(:shipped_order, user: u7)
        oi8 = create(:fulfilled_order_item, item: i11, order: o8, created_at: 2.days.ago)
        oi9 = create(:fulfilled_order_item, item: i9, order: o9, created_at: 2.days.ago)
        oi10 = create(:fulfilled_order_item, item: i10, order: o10, created_at: 2.days.ago)
        oi11 = create(:fulfilled_order_item, item: i11, order: o11, created_at: 2.days.ago)
        oi12 = create(:fulfilled_order_item, item: i12, order: o12, created_at: 2.days.ago)
        oi13 = create(:fulfilled_order_item, item: i13, order: o13, created_at: 2.days.ago)
        #Last Month
        oi14 = create(:fulfilled_order_item, item: i8, order: o8, updated_at: 1.month.ago)
        oi15 = create(:fulfilled_order_item, item: i9, order: o9, updated_at: 1.month.ago)
        oi16 = create(:fulfilled_order_item, item: i10, order: o10, updated_at: 1.month.ago)
        oi17 = create(:fulfilled_order_item, item: i11, order: o11, updated_at: 1.month.ago)
        oi18 = create(:fulfilled_order_item, item: i12, order: o12, updated_at: 1.month.ago)
        oi19 = create(:fulfilled_order_item, item: @i1, order: o12, updated_at: 1.month.ago)
        oi20 = create(:fulfilled_order_item, item: @i2, order: o12, updated_at: 1.month.ago)
        oi21 = create(:fulfilled_order_item, item: @i3, order: o12, updated_at: 1.month.ago)
        oi22 = create(:fulfilled_order_item, item: @i4, order: o12, updated_at: 1.month.ago)
        oi23 = create(:fulfilled_order_item, item: @i5, order: o12, updated_at: 1.month.ago)
        oi24 = create(:fulfilled_order_item, item: @i6, order: o12, updated_at: 1.month.ago)
        oi25 = create(:fulfilled_order_item, item: @i7, order: o12, updated_at: 1.month.ago)

        expect(User.top_five_fastest_fulfilling_merchants_user_city(u7.city)).to eq([@m1, @m2, @m3, @m4, @m5])
      end

      it ".top_five_fastest_fulfilling_merchants_user_city(city)" do
        u7 = create(:user, state: "MI", city: "Frankenmuth")
        @m8 = create(:merchant)
        @m9 = create(:merchant)
        @m10 = create(:merchant)
        @m11 = create(:merchant)
        @m12 = create(:merchant)
        @m13 = create(:merchant)
        i8 = create(:item, merchant_id: @m8.id)
        i9 = create(:item, merchant_id: @m9.id)
        i10 = create(:item, merchant_id: @m10.id)
        i11 = create(:item, merchant_id: @m11.id)
        i12 = create(:item, merchant_id: @m12.id)
        i13 = create(:item, merchant_id: @m13.id)
        o8 = create(:shipped_order, user: u7)
        o9 = create(:shipped_order, user: u7)
        o10 = create(:shipped_order, user: u7)
        o11 = create(:shipped_order, user: u7)
        o12 = create(:shipped_order, user: u7)
        o13 = create(:shipped_order, user: u7)
        oi8 = create(:fulfilled_order_item, item: i11, order: o8, created_at: 2.days.ago)
        oi9 = create(:fulfilled_order_item, item: i9, order: o9, created_at: 2.days.ago)
        oi10 = create(:fulfilled_order_item, item: i10, order: o10, created_at: 2.days.ago)
        oi11 = create(:fulfilled_order_item, item: i11, order: o11, created_at: 2.days.ago)
        oi12 = create(:fulfilled_order_item, item: i12, order: o12, created_at: 2.days.ago)
        oi13 = create(:fulfilled_order_item, item: i13, order: o13, created_at: 2.days.ago)
        #Last Month
        oi14 = create(:fulfilled_order_item, item: i8, order: o8, updated_at: 1.month.ago)
        oi15 = create(:fulfilled_order_item, item: i9, order: o9, updated_at: 1.month.ago)
        oi16 = create(:fulfilled_order_item, item: i10, order: o10, updated_at: 1.month.ago)
        oi17 = create(:fulfilled_order_item, item: i11, order: o11, updated_at: 1.month.ago)
        oi18 = create(:fulfilled_order_item, item: i12, order: o12, updated_at: 1.month.ago)
        oi19 = create(:fulfilled_order_item, item: @i1, order: o12, updated_at: 1.month.ago)
        oi20 = create(:fulfilled_order_item, item: @i2, order: o12, updated_at: 1.month.ago)
        oi21 = create(:fulfilled_order_item, item: @i3, order: o12, updated_at: 1.month.ago)
        oi22 = create(:fulfilled_order_item, item: @i4, order: o12, updated_at: 1.month.ago)
        oi23 = create(:fulfilled_order_item, item: @i5, order: o12, updated_at: 1.month.ago)
        oi24 = create(:fulfilled_order_item, item: @i6, order: o12, updated_at: 1.month.ago)
        oi25 = create(:fulfilled_order_item, item: @i7, order: o12, updated_at: 1.month.ago)

        expect(User.top_five_fastest_fulfilling_merchants_user_state(u7.state)).to eq([@m1, @m2, @m3, @m4, @m5])
      end

      it ".top_ten_merchants_by_items(start_date, end_date)" do
        u7 = create(:user, state: "MI", city: "Frankenmuth")
        @m8 = create(:merchant)
        @m9 = create(:merchant)
        @m10 = create(:merchant)
        @m11 = create(:merchant)
        @m12 = create(:merchant)
        @m13 = create(:merchant)
        i8 = create(:item, merchant_id: @m8.id)
        i9 = create(:item, merchant_id: @m9.id)
        i10 = create(:item, merchant_id: @m10.id)
        i11 = create(:item, merchant_id: @m11.id)
        i12 = create(:item, merchant_id: @m12.id)
        i13 = create(:item, merchant_id: @m13.id)
        o8 = create(:shipped_order, user: u7)
        o9 = create(:shipped_order, user: u7)
        o10 = create(:shipped_order, user: u7)
        o11 = create(:shipped_order, user: u7)
        o12 = create(:shipped_order, user: u7)
        o13 = create(:shipped_order, user: u7)
        oi8 = create(:fulfilled_order_item, item: i8, order: o8, created_at: 2.days.ago)
        oi9 = create(:fulfilled_order_item, item: i9, order: o9, created_at: 2.days.ago)
        oi10 = create(:fulfilled_order_item, item: i10, order: o10, created_at: 2.days.ago)
        oi11 = create(:fulfilled_order_item, item: i11, order: o11, created_at: 2.days.ago)
        oi12 = create(:fulfilled_order_item, item: i12, order: o12, created_at: 2.days.ago)
        oi13 = create(:fulfilled_order_item, item: i13, order: o13, created_at: 2.days.ago)
        #Last Month
        oi14 = create(:fulfilled_order_item, item: i8, order: o8, updated_at: 1.month.ago)
        oi15 = create(:fulfilled_order_item, item: i9, order: o9, updated_at: 1.month.ago)
        oi16 = create(:fulfilled_order_item, item: i10, order: o10, updated_at: 1.month.ago)
        oi17 = create(:fulfilled_order_item, item: i11, order: o11, updated_at: 1.month.ago)
        oi18 = create(:fulfilled_order_item, item: i12, order: o12, updated_at: 1.month.ago)
        oi19 = create(:fulfilled_order_item, item: @i1, order: o12, updated_at: 1.month.ago)
        oi20 = create(:fulfilled_order_item, item: @i2, order: o12, updated_at: 1.month.ago)
        oi21 = create(:fulfilled_order_item, item: @i3, order: o12, updated_at: 1.month.ago)
        oi22 = create(:fulfilled_order_item, item: @i4, order: o12, updated_at: 1.month.ago)
        oi23 = create(:fulfilled_order_item, item: @i5, order: o12, updated_at: 1.month.ago)
        oi24 = create(:fulfilled_order_item, item: @i6, order: o12, updated_at: 1.month.ago)
        oi25 = create(:fulfilled_order_item, item: @i7, order: o12, updated_at: 1.month.ago)

        start_date_this_month = DateTime.now.beginning_of_month
        end_date_this_month = DateTime.now.end_of_month
        start_date_next_month = DateTime.now.next_month.beginning_of_month
        end_date_next_month = DateTime.now.next_month.end_of_month
        start_date_last_month = DateTime.now.last_month.beginning_of_month
        end_date_last_month = DateTime.now.last_month.end_of_month

        expect(User.top_ten_merchants_by_items(start_date_next_month, end_date_next_month)).to eq([]) #next month has no orders
        expect(User.top_ten_merchants_by_items(start_date_this_month, end_date_this_month)).to eq([@m13, @m12, @m11, @m10, @m9, @m8, @m7, @m6, @m3, @m2])
        expect(User.top_ten_merchants_by_items(start_date_last_month, end_date_last_month)).to eq([@m7, @m6, @m5, @m4, @m3, @m2, @m1, @m12, @m11, @m10])
      end

      it ".top_ten_merchants_by_fulfilled_orders(start_date, end_date)" do
        u7 = create(:user, state: "MI", city: "Frankenmuth")
        @m8 = create(:merchant)
        @m9 = create(:merchant)
        @m10 = create(:merchant)
        @m11 = create(:merchant)
        @m12 = create(:merchant)
        @m13 = create(:merchant)
        i8 = create(:item, merchant_id: @m8.id)
        i9 = create(:item, merchant_id: @m9.id)
        i10 = create(:item, merchant_id: @m10.id)
        i11 = create(:item, merchant_id: @m11.id)
        i12 = create(:item, merchant_id: @m12.id)
        i13 = create(:item, merchant_id: @m13.id)
        o8 = create(:shipped_order, user: u7)
        o9 = create(:shipped_order, user: u7)
        o10 = create(:shipped_order, user: u7)
        o11 = create(:shipped_order, user: u7)
        o12 = create(:shipped_order, user: u7)
        o13 = create(:shipped_order, user: u7)
        oi8 = create(:fulfilled_order_item, item: i11, order: o8, created_at: 2.days.ago)
        oi9 = create(:fulfilled_order_item, item: i9, order: o9, created_at: 2.days.ago)
        oi10 = create(:fulfilled_order_item, item: i10, order: o10, created_at: 2.days.ago)
        oi11 = create(:fulfilled_order_item, item: i11, order: o11, created_at: 2.days.ago)
        oi12 = create(:fulfilled_order_item, item: i12, order: o12, created_at: 2.days.ago)
        oi13 = create(:fulfilled_order_item, item: i13, order: o13, created_at: 2.days.ago)
        #Last Month
        oi14 = create(:fulfilled_order_item, item: i8, order: o8, updated_at: 1.month.ago)
        oi15 = create(:fulfilled_order_item, item: i9, order: o9, updated_at: 1.month.ago)
        oi16 = create(:fulfilled_order_item, item: i10, order: o10, updated_at: 1.month.ago)
        oi17 = create(:fulfilled_order_item, item: i11, order: o11, updated_at: 1.month.ago)
        oi18 = create(:fulfilled_order_item, item: i12, order: o12, updated_at: 1.month.ago)
        oi19 = create(:fulfilled_order_item, item: @i1, order: o12, updated_at: 1.month.ago)
        oi20 = create(:fulfilled_order_item, item: @i2, order: o12, updated_at: 1.month.ago)
        oi21 = create(:fulfilled_order_item, item: @i3, order: o12, updated_at: 1.month.ago)
        oi22 = create(:fulfilled_order_item, item: @i4, order: o12, updated_at: 1.month.ago)
        oi23 = create(:fulfilled_order_item, item: @i5, order: o12, updated_at: 1.month.ago)
        oi24 = create(:fulfilled_order_item, item: @i6, order: o12, updated_at: 1.month.ago)
        oi25 = create(:fulfilled_order_item, item: @i7, order: o12, updated_at: 1.month.ago)

        start_date_this_month = DateTime.now.beginning_of_month
        end_date_this_month = DateTime.now.end_of_month
        start_date_last_month = DateTime.now.last_month.beginning_of_month
        end_date_last_month = DateTime.now.last_month.end_of_month

        expect(User.top_ten_merchants_by_fulfilled_orders(start_date_this_month, end_date_this_month)).to eq([@m11, @m2, @m3, @m6, @m7, @m9, @m10, @m12, @m1, @m13])
        expect(User.top_ten_merchants_by_fulfilled_orders(start_date_last_month, end_date_last_month)).to eq([@m1, @m2, @m3, @m4, @m5, @m6, @m7, @m8, @m9, @m10])
      end

      it ".merchants_sorted_by_revenue" do
        expect(User.merchants_sorted_by_revenue).to eq([@m7, @m6, @m3, @m2, @m1])
      end

      it ".top_merchants_by_revenue()" do
        expect(User.top_merchants_by_revenue(3)).to eq([@m7, @m6, @m3])
      end

      it ".merchants_sorted_by_fulfillment_time" do
        expect(User.merchants_sorted_by_fulfillment_time(1).length).to eq(1)
        expect(User.merchants_sorted_by_fulfillment_time(10).length).to eq(5)
        expect(User.merchants_sorted_by_fulfillment_time(10)).to eq([@m1, @m7, @m6, @m3, @m2])
      end

      it ".top_merchants_by_fulfillment_time" do
        expect(User.top_merchants_by_fulfillment_time(3)).to eq([@m1, @m7, @m6])
      end

      it ".bottom_merchants_by_fulfillment_time" do
        expect(User.bottom_merchants_by_fulfillment_time(3)).to eq([@m2, @m3, @m6])
      end

      it ".top_user_states_by_order_count" do
        expect(User.top_user_states_by_order_count(3)[0].state).to eq("IA")
        expect(User.top_user_states_by_order_count(3)[0].order_count).to eq(3)
        expect(User.top_user_states_by_order_count(3)[1].state).to eq("CO")
        expect(User.top_user_states_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_states_by_order_count(3)[2].state).to eq("OK")
        expect(User.top_user_states_by_order_count(3)[2].order_count).to eq(1)
      end

      it ".top_user_cities_by_order_count" do
        expect(User.top_user_cities_by_order_count(3)[0].state).to eq("CO")
        expect(User.top_user_cities_by_order_count(3)[0].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[0].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[1].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[1].city).to eq("Des Moines")
        expect(User.top_user_cities_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[2].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[2].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[2].order_count).to eq(1)
      end
    end
  end
end
