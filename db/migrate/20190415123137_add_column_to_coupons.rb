class AddColumnToCoupons < ActiveRecord::Migration[5.1]
  def change
    add_column :coupons, :active, :boolean, default: true
  end
end
