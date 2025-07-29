require 'spec_helper'

describe Reservation do
  let(:nyc) { City.create(name: 'NYC', state: 'NY', country: 'USA') }
  let(:fidi) { Neighborhood.create(name: 'Fi Di', city: nyc, zip_code: '10004') }
  let(:amanda) { User.create(name: 'Amanda', email: 'amanda@example.com') }
  let(:logan) { User.create(name: 'Logan', email: 'logan@example.com') }
  let(:listing) do
    Listing.create(
      address: '123 Main Street',
      listing_type: 'private room',
      title: 'Beautiful Apartment on Main Street',
      description: "My apartment is great. there's a bedroom. close to subway....blah blah",
      price: 50.00,
      max_guests: 2,
      active: true,
      neighborhood: fidi,
      host: amanda
    )
  end
  let(:reservation) do
    Reservation.create(
      checkin: '2014-04-25',
      checkout: '2014-04-30',
      guest_count: 2,
      status: 'confirmed',
      listing: listing,
      guest: logan
    )
  end

  it 'has a checkin time' do
    expect(reservation.checkin)
    expect(reservation.checkin).to eq(Date.parse('2014-04-25')).or eq('2014-04-25')
  end

  it 'has a checkout time' do
    expect(reservation.checkout).to eq(Date.parse('2014-04-30')).or eq('2014-04-30')
  end

  it 'belongs to a guest' do
    expect(reservation.guest).to eq(logan)
  end

  it 'belongs to a listing' do
    expect(reservation.listing).to eq(listing)
  end

  describe 'instance methods' do
    describe '#duration' do
      it 'returns number of nights for reservation' do
        # 2014-04-25 to 2014-04-30 = 5 nights
        expect(reservation.duration).to eq(5)
      end
    end

    describe '#total_cost' do
      it 'calculates total cost (price per night * duration)' do
        # $50 * 5 nights = $250
        expect(reservation.total_cost).to eq(250.0)
      end
    end
  end

  context 'class methods' do
    let(:guest1) { User.create(name: 'Guest1') }
    let(:guest2) { User.create(name: 'Guest2') }
    let(:host) { User.create(name: 'Host') }

    let(:expensive_listing) do
      Listing.create(
        address: '456 Luxury Ave',
        listing_type: 'luxury suite',
        title: 'Luxury Suite',
        description: 'High-end accommodation',
        price: 300.00,
        neighborhood: fidi,
        host: host
      )
    end

    let!(:old_reservation) do
      Reservation.create(
        checkin: Date.current - 30,
        checkout: Date.current - 28, # 2 nights
        listing: listing,
        guest: guest1
      )
    end

    let!(:recent_reservation1) do
      Reservation.create(
        checkin: Date.current - 5,
        checkout: Date.current - 3, # 2 nights
        listing: listing,
        guest: guest1
      )
    end

    let!(:recent_reservation2) do
      Reservation.create(
        checkin: Date.current - 3,
        checkout: Date.current - 1, # 2 nights
        listing: expensive_listing,
        guest: guest2
      )
    end

    let!(:current_reservation) do
      Reservation.create(
        checkin: Date.current - 1,
        checkout: Date.current + 2, # 3 nights, currently active
        listing: listing,
        guest: guest1
      )
    end

    let!(:future_reservation) do
      Reservation.create(
        checkin: Date.current + 5,
        checkout: Date.current + 8, # 3 nights
        listing: expensive_listing,
        guest: guest2
      )
    end

    describe '.most_recent' do
      it 'returns 5 most recent reservations by default' do
        recent = Reservation.most_recent
        expect(recent.length).to be <= 5
        # Should be ordered by creation time (most recent first)
        expect(recent.first.created_at).to be >= recent.last.created_at
      end

      it 'accepts custom limit parameter' do
        recent = Reservation.most_recent(3)
        expect(recent.length).to be <= 3
      end
    end

    describe '.highest_grossing' do
      it 'returns reservation with highest total cost' do
        # future_reservation: 3 nights * $300 = $900 (highest)
        # current_reservation: 3 nights * $50 = $150
        # recent_reservation2: 2 nights * $300 = $600
        # Others: 2 nights * $50 = $100 each
        expect(Reservation.highest_grossing).to eq(future_reservation)
      end
    end

    describe '.by_month' do
      let!(:april_reservation) do
        Reservation.create(
          checkin: Date.new(2024, 4, 15),
          checkout: Date.new(2024, 4, 18),
          listing: listing,
          guest: guest1
        )
      end

      let!(:may_reservation) do
        Reservation.create(
          checkin: Date.new(2024, 5, 10),
          checkout: Date.new(2024, 5, 12),
          listing: listing,
          guest: guest2
        )
      end

      it 'returns reservations for specified month and year' do
        april_reservations = Reservation.by_month(4, 2024)
        expect(april_reservations).to include(april_reservation)
        expect(april_reservations).not_to include(may_reservation)

        may_reservations = Reservation.by_month(5, 2024)
        expect(may_reservations).to include(may_reservation)
        expect(may_reservations).not_to include(april_reservation)
      end
    end

    describe '.current_guests' do
      it 'returns users who are currently checked in' do
        # current_reservation has guest1 checked in (checkin: yesterday, checkout: tomorrow)
        current_guests = Reservation.current_guests
        expect(current_guests).to include(guest1)
        expect(current_guests).not_to include(guest2) # not currently staying
      end
    end
  end
end
