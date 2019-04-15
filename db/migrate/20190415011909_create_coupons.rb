class CreateCoupons < ActiveRecord::Migration[5.1]
  def change
    create_table :coupons do |t|
      t.string :code
      t.float :discount
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
