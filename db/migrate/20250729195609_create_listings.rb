class CreateListings < ActiveRecord::Migration[6.1]
  def change
    create_table :listings do |t|
      t.string :title
      t.text :description
      t.string :address
      t.string :listing_type
      t.decimal :price, precision: 8, scale: 2
      t.integer :max_guests
      t.integer :neighborhood_id
      t.integer :host_id
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
