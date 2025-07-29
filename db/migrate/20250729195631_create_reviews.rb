class CreateReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.text :description
      t.integer :rating
      t.integer :cleanliness_rating
      t.integer :communication_rating
      t.integer :guest_id
      t.integer :reservation_id
      t.timestamps
    end
  end
end
