class User < ActiveRecord::Base
  # When a user acts as a HOST:
  has_many :listings, foreign_key: 'host_id'
  has_many :reservations, through: :listings
  has_many :guests, through: :reservations, source: :guest
  has_many :host_reviews, through: :reservations, source: :reviews

  # When a user acts as a GUEST:
  has_many :trips, class_name: 'Reservation', foreign_key: 'guest_id'
  has_many :reviews, foreign_key: 'guest_id'

  # Instance methods
  def host?
    listings.count > 0
  end

  def trip_count
    trips.count
  end

  def top_three_destinations
    # Get city_ids with their counts, then find the actual City objects
    city_ids = trips.joins(listing: { neighborhood: :city })
                   .group('cities.id')
                   .order('COUNT(cities.id) DESC')
                   .limit(3)
                   .pluck('cities.id')
    City.where(id: city_ids)
  end

  def favorite_neighborhood
    # Get neighborhood_id with highest count, then find the actual Neighborhood object
    neighborhood_id = trips.joins(listing: :neighborhood)
                          .group('neighborhoods.id')
                          .order('COUNT(neighborhoods.id) DESC')
                          .limit(1)
                          .pluck('neighborhoods.id')
                          .first
    Neighborhood.find(neighborhood_id) if neighborhood_id
  end

  def total_earnings
    # Calculate earnings for all reservations on user's listings
    listings.sum do |listing|
      listing.reservations.sum { |r| listing.price * (r.checkout - r.checkin) }
    end
  end

  def average_listing_price
    return 0 if listings.empty?
    listings.average(:price).to_f
  end

  # Class methods
  def self.hosts
    joins(:listings).distinct
  end

  def self.guests
    joins(:trips).distinct
  end

  def self.top_host
    joins(:listings).group('users.id').order('COUNT(listings.id) DESC').first
  end

  def self.most_traveled
    joins(:trips).group('users.id').order('COUNT(reservations.id) DESC').first
  end
end
