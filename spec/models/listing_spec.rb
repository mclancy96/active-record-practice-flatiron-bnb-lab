require 'spec_helper'

describe Listing do
  let(:new_york_city) { City.create(name: 'NYC', state: 'NY', country: 'USA') }
  let(:financial_district) { Neighborhood.create(name: 'Fi Di', city: new_york_city, zip_code: '10004') }
  let(:amanda) { User.create(name: 'Amanda', email: 'amanda@example.com') }
  let(:logan) { User.create(name: 'Logan', email: 'logan@example.com') }
  let!(:listing) do
    Listing.create(
      address: '123 Main Street',
      listing_type: 'private room',
      title: 'Beautiful Apartment on Main Street',
      description: "My apartment is great. there's a bedroom. close to subway....blah blah",
      price: 50.00,
      max_guests: 2,
      active: true,
      neighborhood: financial_district,
      host: amanda
    )
  end

  it 'has a title' do
    expect(listing.title).to eq('Beautiful Apartment on Main Street')
  end

  it 'has a description' do
    expect(listing.description).to eq("My apartment is great. there's a bedroom. close to subway....blah blah")
  end

  it 'has an address' do
    expect(listing.address).to eq('123 Main Street')
  end

  it 'has a listing type' do
    expect(listing.listing_type).to eq('private room')
  end

  it 'has a price' do
    expect(listing.price).to eq(50.00)
  end

  it 'belongs to a neighborhood' do
    expect(listing.neighborhood.name).to eq('Fi Di')
  end

  it 'belongs to a host' do
    expect(listing.host.name).to eq('Amanda')
  end

  context 'reservations (and guests) and reviews' do
    let!(:reservation1) do
      Reservation.create(
        checkin: Date.current - 10,
        checkout: Date.current - 7, # 3 nights
        listing: listing,
        guest: logan
      )
    end

    let!(:reservation2) do
      Reservation.create(
        checkin: Date.current + 5,
        checkout: Date.current + 8, # 3 nights
        listing: listing,
        guest: logan
      )
    end

    let!(:review1) do
      Review.create(
        description: 'This place was great!',
        rating: 5,
        guest: logan,
        reservation: reservation1
      )
    end

    let!(:review2) do
      Review.create(
        description: 'Pretty good stay',
        rating: 4,
        guest: logan,
        reservation: reservation2
      )
    end

    it 'has many reservations' do
      expect(listing.reservations).to include(reservation1, reservation2)
    end

    it 'has many reviews through reservations' do
      expect(listing.reviews).to include(review1, review2)
    end

    it 'knows about all of its guests' do
      expect(listing.guests).to include(logan)
    end

    describe '#average_review_rating' do
      it 'returns average rating when reviews exist' do
        # (5 + 4) / 2 = 4.5
        expect(listing.average_review_rating).to eq(4.5)
      end

      it 'returns 0 when no reviews exist' do
        new_listing = Listing.create(
          address: '456 Another St',
          listing_type: 'entire apartment',
          title: 'No Reviews Apartment',
          description: 'Brand new listing',
          price: 75.00,
          neighborhood: financial_district,
          host: amanda
        )
        expect(new_listing.average_review_rating).to eq(0)
      end
    end

    describe '#booked?' do
      it 'returns true when listing has reservations' do
        expect(listing.booked?).to be true
      end

      it 'returns false when listing has no reservations' do
        new_listing = Listing.create(
          address: '789 Empty St',
          listing_type: 'shared room',
          title: 'Empty Listing',
          description: 'No bookings yet',
          price: 30.00,
          neighborhood: financial_district,
          host: amanda
        )
        expect(new_listing.booked?).to be false
      end
    end

    describe '#total_earnings' do
      it 'calculates total earnings from all reservations' do
        # reservation1: 3 nights * $50 = $150
        # reservation2: 3 nights * $50 = $150
        # Total: $300
        expect(listing.total_earnings).to eq(300.0)
      end
    end

    describe '#most_recent_review' do
      it 'returns the most recent review' do
        expect(listing.most_recent_review).to eq(review2)
      end
    end

    describe '#available_on?' do
      it 'returns false when date conflicts with existing reservation' do
        conflict_date = Date.current - 8 # during reservation1
        expect(listing.available_on?(conflict_date)).to be false
      end

      it "returns true when date doesn't conflict" do
        available_date = Date.current + 1 # between reservations
        expect(listing.available_on?(available_date)).to be true
      end
    end

    describe '#booking_count' do
      it 'returns total number of reservations' do
        expect(listing.booking_count).to eq(2)
      end
    end
  end

  context 'class methods' do
    let(:sf) { City.create(name: 'San Francisco', state: 'CA', country: 'USA') }
    let(:mission) { Neighborhood.create(name: 'Mission', city: sf, zip_code: '94103') }
    let(:chicago) { City.create(name: 'Chicago', state: 'IL', country: 'USA') }
    let(:loop_area) { Neighborhood.create(name: 'Loop', city: chicago, zip_code: '60601') }

    let(:host1) { User.create(name: 'Host1', email: 'host1@example.com') }
    let(:host2) { User.create(name: 'Host2', email: 'host2@example.com') }
    let(:guest) { User.create(name: 'Guest', email: 'guest@example.com') }

    let!(:sf_listing) do
      Listing.create(
        address: '100 Valencia St',
        listing_type: 'entire apartment',
        title: 'SF Apartment',
        description: 'Great SF location',
        price: 120.00,
        neighborhood: mission,
        host: host1
      )
    end

    let!(:expensive_listing) do
      Listing.create(
        address: '200 State St',
        listing_type: 'luxury suite',
        title: 'Luxury Chicago Suite',
        description: 'Top floor luxury',
        price: 300.00,
        neighborhood: loop_area,
        host: host2
      )
    end

    let!(:sf_reservation) do
      Reservation.create(
        checkin: Date.current - 15,
        checkout: Date.current - 10, # 5 nights
        listing: sf_listing,
        guest: guest
      )
    end

    let!(:expensive_reservation) do
      Reservation.create(
        checkin: Date.current - 20,
        checkout: Date.current - 18, # 2 nights
        listing: expensive_listing,
        guest: guest
      )
    end

    let!(:high_rating_review) do
      Review.create(
        description: 'Amazing place!',
        rating: 5,
        guest: guest,
        reservation: sf_reservation
      )
    end

    let!(:low_rating_review) do
      Review.create(
        description: 'Too expensive',
        rating: 2,
        guest: guest,
        reservation: expensive_reservation
      )
    end

    describe '.highest_rated' do
      it 'returns listings with average rating of 4 or higher' do
        highest = Listing.highest_rated
        expect(highest).to include(sf_listing) # rating: 5
        expect(highest).not_to include(expensive_listing) # rating: 2
      end
    end

    describe '.most_expensive' do
      it 'returns listing with highest price' do
        expect(Listing.most_expensive).to eq(expensive_listing) # $300
      end
    end

    describe '.by_city' do
      it 'returns all listings in specified city' do
        nyc_listings = Listing.by_city('NYC')
        expect(nyc_listings).to include(listing)
        expect(nyc_listings).not_to include(sf_listing)

        sf_listings = Listing.by_city('San Francisco')
        expect(sf_listings).to include(sf_listing)
        expect(sf_listings).not_to include(listing)
      end
    end

    describe '.available_between' do
      it 'returns listings available in date range' do
        start_date = Date.current + 10
        end_date = Date.current + 15
        available = Listing.available_between(start_date, end_date)
        expect(available).to include(listing, sf_listing, expensive_listing)
      end

      it 'excludes listings with conflicting reservations' do
        # Create a future reservation that conflicts
        future_reservation = Reservation.create(
          checkin: Date.current + 12,
          checkout: Date.current + 15,
          listing: sf_listing,
          guest: guest
        )

        start_date = Date.current + 10
        end_date = Date.current + 16
        available = Listing.available_between(start_date, end_date)
        expect(available).not_to include(sf_listing)
      end
    end

    describe '.top_earners' do
      it 'returns top 3 listings by total earnings' do
        # listing: 2 reservations * 3 nights * $50 = $300
        # sf_listing: 1 reservation * 5 nights * $120 = $600
        # expensive_listing: 1 reservation * 2 nights * $300 = $600
        top_earners = Listing.top_earners
        expect(top_earners.length).to be <= 3
        expect(top_earners.first.total_earnings).to be >= top_earners.last.total_earnings
      end
    end
  end
end
