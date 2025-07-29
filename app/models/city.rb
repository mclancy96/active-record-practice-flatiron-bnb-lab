class City < ActiveRecord::Base
  has_many :neighborhoods
  has_many :listings, through: :neighborhoods

  # Class methods
  def self.most_reservations
    joins(listings: :reservations)
      .group('cities.id')
      .order('COUNT(reservations.id) DESC')
      .first
  end

  def self.biggest_host
    joins(listings: :host)
      .group('cities.id')
      .order('COUNT(listings.id) DESC')
      .first
  end

  def self.highest_rated
    joins(listings: { reservations: :reviews })
      .group('cities.id')
      .order('AVG(reviews.rating) DESC')
      .first
  end

  def self.most_listings
    joins(:listings)
      .group('cities.id')
      .order('COUNT(listings.id) DESC')
      .first
  end
end
