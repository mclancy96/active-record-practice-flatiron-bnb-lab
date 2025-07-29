class Listing < ActiveRecord::Base
  belongs_to :neighborhood
  belongs_to :host, class_name: 'User'
  has_many :reservations
  has_many :reviews, through: :reservations
  has_many :guests, through: :reservations, source: :guest

  # Instance methods
  def average_review_rating
    return 0 if reviews.empty?
    reviews.average(:rating).to_f
  end

  def booked?
    reservations.count > 0
  end

  def total_earnings
    reservations.sum { |r| price * (r.checkout - r.checkin) }
  end

  def most_recent_review
    reviews.order(:created_at).last
  end

  def available_on?(date)
    !reservations.where('checkin <= ? AND checkout > ?', date, date).exists?
  end

  def booking_count
    reservations.count
  end

  # Class methods
  def self.highest_rated
    joins(:reviews)
      .group('listings.id')
      .having('AVG(reviews.rating) >= 4')
      .includes(:reviews)
      .select { |listing| listing.average_review_rating >= 4 }
  end

  def self.most_expensive
    order(:price).last
  end

  def self.by_city(city_name)
    joins(neighborhood: :city).where('cities.name = ?', city_name)
  end

  def self.available_between(start_date, end_date)
    where.not(
      id: joins(:reservations)
          .where('reservations.checkin < ? AND reservations.checkout > ?', end_date, start_date)
          .select(:id)
    )
  end

  def self.top_earners
    all.sort_by(&:total_earnings).reverse.first(3)
  end
end
