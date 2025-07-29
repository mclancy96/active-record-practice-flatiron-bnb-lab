require 'spec_helper'

describe Neighborhood do
  let(:nyc) { City.create(name: 'NYC', state: 'NY', country: 'USA') }
  let(:brighton_beach) { Neighborhood.create(name: 'Brighton Beach', city: nyc, zip_code: '11235') }

  it 'has a name' do
    expect(brighton_beach.name).to eq('Brighton Beach')
  end

  it 'belongs to a city' do
    expect(brighton_beach.city).to be(nyc)
  end

  context 'listings' do
    let(:user1) { User.create(name: 'Host1', email: 'host1@example.com') }
    let(:user2) { User.create(name: 'Host2', email: 'host2@example.com') }
    let(:guest) { User.create(name: 'Guest', email: 'guest@example.com') }

    let!(:listing1) do
      Listing.create(
        address: '44 Ridge Lane',
        listing_type: 'whole house',
        title: 'Beautiful Home on Mountain',
        description: 'Whole house for rent on mountain. Many bedrooms.',
        price: 200.00,
        neighborhood: brighton_beach,
        host: user1
      )
    end

    let!(:listing2) do
      Listing.create(
        address: '55 Ocean Ave',
        listing_type: 'private room',
        title: 'Cozy Room Near Beach',
        description: 'Nice room close to the beach.',
        price: 100.00,
        neighborhood: brighton_beach,
        host: user2
      )
    end

    it 'has many listings' do
      expect(brighton_beach.listings).to include(listing1, listing2)
    end

    context 'with reservations and reviews' do
      let!(:reservation1) do
        Reservation.create(
          checkin: Date.current - 15,
          checkout: Date.current - 12, # 3 nights
          listing: listing1,
          guest: guest
        )
      end

      let!(:reservation2) do
        Reservation.create(
          checkin: Date.current - 10,
          checkout: Date.current - 8, # 2 nights
          listing: listing1,
          guest: guest
        )
      end

      let!(:reservation3) do
        Reservation.create(
          checkin: Date.current - 20,
          checkout: Date.current - 18, # 2 nights
          listing: listing2,
          guest: guest
        )
      end

      describe '#most_popular_listing' do
        it 'returns listing with most reservations' do
          # listing1: 2 reservations, listing2: 1 reservation
          expect(brighton_beach.most_popular_listing).to eq(listing1)
        end
      end

      describe '#average_price' do
        it 'returns average listing price in neighborhood' do
          # (200 + 100) / 2 = 150
          expect(brighton_beach.average_price).to eq(150.0)
        end
      end

      describe '#reservation_count' do
        it 'returns total number of reservations in neighborhood' do
          expect(brighton_beach.reservation_count).to eq(3)
        end
      end
    end
  end

  context 'class methods' do
    let(:sf) { City.create(name: 'San Francisco', state: 'CA', country: 'USA') }
    let(:mission) { Neighborhood.create(name: 'Mission', city: sf, zip_code: '94103') }
    let(:fidi) { Neighborhood.create(name: 'Financial District', city: nyc, zip_code: '10004') }

    let(:host1) { User.create(name: 'Host1', email: 'host1@example.com') }
    let(:host2) { User.create(name: 'Host2', email: 'host2@example.com') }
    let(:host3) { User.create(name: 'Host3', email: 'host3@example.com') }
    let(:guest) { User.create(name: 'Guest', email: 'guest@example.com') }

    # Brighton Beach listings (expensive)
    let!(:bb_listing1) do
      Listing.create(
        address: '100 Beach Ave',
        listing_type: 'luxury apartment',
        title: 'Luxury Beach Apartment',
        description: 'High-end beachfront apartment',
        price: 400.00,
        neighborhood: brighton_beach,
        host: host1
      )
    end

    let!(:bb_listing2) do
      Listing.create(
        address: '200 Beach Ave',
        listing_type: 'penthouse',
        title: 'Beach Penthouse',
        description: 'Ultimate luxury experience',
        price: 600.00,
        neighborhood: brighton_beach,
        host: host2
      )
    end

    # Mission listings (moderate)
    let!(:mission_listing) do
      Listing.create(
        address: '300 Valencia St',
        listing_type: 'apartment',
        title: 'Mission Apartment',
        description: 'Cool neighborhood apartment',
        price: 150.00,
        neighborhood: mission,
        host: host3
      )
    end

    # Financial District listings (budget)
    let!(:fidi_listing) do
      Listing.create(
        address: '400 Wall St',
        listing_type: 'studio',
        title: 'Financial District Studio',
        description: 'Convenient business location',
        price: 120.00,
        neighborhood: fidi,
        host: host1
      )
    end

    # Reservations for earnings calculation
    let!(:bb_reservation1) do
      Reservation.create(
        checkin: Date.current - 10,
        checkout: Date.current - 7, # 3 nights * $400 = $1200
        listing: bb_listing1,
        guest: guest
      )
    end

    let!(:bb_reservation2) do
      Reservation.create(
        checkin: Date.current - 20,
        checkout: Date.current - 18, # 2 nights * $600 = $1200
        listing: bb_listing2,
        guest: guest
      )
    end

    let!(:mission_reservation) do
      Reservation.create(
        checkin: Date.current - 15,
        checkout: Date.current - 12, # 3 nights * $150 = $450
        listing: mission_listing,
        guest: guest
      )
    end

    let!(:fidi_reservation) do
      Reservation.create(
        checkin: Date.current - 25,
        checkout: Date.current - 23, # 2 nights * $120 = $240
        listing: fidi_listing,
        guest: guest
      )
    end

    describe '.highest_earner' do
      it 'returns neighborhood with highest total earnings' do
        # Brighton Beach: $1200 + $1200 = $2400
        # Mission: $450
        # Financial District: $240
        expect(Neighborhood.highest_earner).to eq(brighton_beach)
      end
    end

    describe '.most_expensive' do
      it 'returns neighborhood with highest average listing price' do
        # Brighton Beach: ($400 + $600) / 2 = $500
        # Mission: $150 / 1 = $150
        # Financial District: $120 / 1 = $120
        expect(Neighborhood.most_expensive).to eq(brighton_beach)
      end
    end
  end
end
