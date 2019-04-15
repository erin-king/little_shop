require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of :code }
    it { should validate_presence_of :discount }
  end

  describe 'relationships' do
    it {should belong_to :user}
  end
end
