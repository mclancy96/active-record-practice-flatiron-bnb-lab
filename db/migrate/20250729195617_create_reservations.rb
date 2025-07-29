class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.date :checkin
      t.date :checkout
      t.integer :guest_count
      t.string :status, default: 'confirmed'
      t.integer :listing_id
      t.integer :guest_id
      t.timestamps
    end
  end
end
