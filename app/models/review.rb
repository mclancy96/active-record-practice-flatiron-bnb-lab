class Review < ActiveRecord::Base
  belongs_to :guest, class_name: 'User'
  belongs_to :reservation

  # Class methods
  def self.highest_rated
    where(rating: 5)
  end

  def self.lowest_rated
    where('rating <= 2')
  end

  def self.most_recent(limit = 10)
    order(:created_at).reverse_order.limit(limit)
  end

  def self.average_rating
    return 0 if count == 0
    average(:rating).to_f
  end

  def self.by_rating(rating)
    where(rating: rating)
  end

  def self.detailed_ratings
    group(:rating).count
  end
end
