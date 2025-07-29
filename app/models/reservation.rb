class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :guest, class_name: 'User'
  has_many :reviews

  # Instance methods
  def duration
    (checkout - checkin).to_i
  end

  def total_cost
    listing.price * duration
  end

  # Class methods
  def self.most_recent(limit = 5)
    order(:created_at).reverse_order.limit(limit)
  end

  def self.highest_grossing
    all.max_by(&:total_cost)
  end

  def self.by_month(month, year)
    where('strftime("%m", checkin) = ? AND strftime("%Y", checkin) = ?',
          month.to_s.rjust(2, '0'), year.to_s)
  end

  def self.current_guests
    today = Date.current
    where('checkin <= ? AND checkout > ?', today, today)
      .includes(:guest)
      .map(&:guest)
      .uniq
  end
end
