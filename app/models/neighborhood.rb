class Neighborhood < ActiveRecord::Base
  belongs_to :city
  has_many :listings

  # Instance methods
  def most_popular_listing
    listings.joins(:reservations)
            .group('listings.id')
            .order('COUNT(reservations.id) DESC')
            .first
  end

  def average_price
    return 0 if listings.empty?
    listings.average(:price).to_f
  end

  def reservation_count
    listings.joins(:reservations).count
  end

  # Class methods
  def self.highest_earner
    # Calculate earnings for each neighborhood using Ruby instead of SQL
    all.max_by do |neighborhood|
      neighborhood.listings.joins(:reservations).sum do |listing|
        listing.reservations.sum { |r| listing.price * (r.checkout - r.checkin) }
      end
    end
  end

  def self.most_expensive
    joins(:listings)
      .group('neighborhoods.id')
      .order('AVG(listings.price) DESC')
      .first
  end
end
