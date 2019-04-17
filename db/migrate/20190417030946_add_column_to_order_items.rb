class AddColumnToOrderItems < ActiveRecord::Migration[5.1]
  def change
    add_column :order_items, :discount, :decimal, default: 0
  end
end
