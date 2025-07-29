require 'spec_helper'

describe City do
  let(:nyc) { City.create(name: 'NYC') }

  it 'has a name' do
    expect(nyc.name).to eq('NYC')
  end

  it 'has many neighborhoods' do
    financial_district = Neighborhood.create(name: 'Fi Di', city: nyc)
    green_point = Neighborhood.create(name: 'Green Point', city: nyc)
    brighton_beach = Neighborhood.create(name: 'Brighton Beach', city: nyc)

    expect(nyc.neighborhoods).to eq([financial_district, green_point, brighton_beach])
  end

  context 'listings' do
    let(:user) { User.create(name: 'user') }
    let(:fidi) { Neighborhood.create(name: 'Fi Di', city: nyc) }
    let!(:listing) do
      Listing.create(
        address: '123 Main Street',
        listing_type: 'private room',
        title: 'Beautiful Apartment on Main Street',
        description: "My apartment is great. there's a bedroom. close to subway....blah blah",
        price: 50.00,
        neighborhood: fidi,
        host: user
      )
    end

    it 'has many listings through neighborhoods' do
      expect(nyc.listings).to include(listing)
    end
  end

  context 'class methods' do
    let(:sf) { City.create(name: 'San Francisco') }
    let(:chicago) { City.create(name: 'Chicago') }

    let(:nyc_neighborhood) { Neighborhood.create(name: 'Manhattan', city: nyc) }
    let(:sf_neighborhood) { Neighborhood.create(name: 'Mission', city: sf) }
    let(:chicago_neighborhood) { Neighborhood.create(name: 'Loop', city: chicago) }

    let(:host1) { User.create(name: 'Host1') }
    let(:host2) { User.create(name: 'Host2') }
    let(:host3) { User.create(name: 'Host3') }
    let(:guest) { User.create(name: 'Guest') }

    # NYC listings (2 listings)
    let!(:nyc_listing1) do
      Listing.create(
        address: '100 Broadway',
        listing_type: 'private room',
        title: 'NYC Room 1',
        description: 'Nice NYC room',
        price: 100.00,
        neighborhood: nyc_neighborhood,
        host: host1
      )
    end

    let!(:nyc_listing2) do
      Listing.create(
        address: '200 Broadway',
        listing_type: 'entire apartment',
        title: 'NYC Apartment',
        description: 'Whole NYC apartment',
        price: 200.00,
        neighborhood: nyc_neighborhood,
        host: host1
      )
    end

    # SF listing (1 listing)
    let!(:sf_listing) do
      Listing.create(
        address: '300 Valencia',
        listing_type: 'private room',
        title: 'SF Room',
        description: 'SF room',
        price: 150.00,
        neighborhood: sf_neighborhood,
        host: host2
      )
    end

    # Chicago listing (1 listing)
    let!(:chicago_listing) do
      Listing.create(
        address: '400 State St',
        listing_type: 'shared room',
        title: 'Chicago Room',
        description: 'Budget Chicago room',
        price: 80.00,
        neighborhood: chicago_neighborhood,
        host: host3
      )
    end

    # Reservations - more in NYC
    let!(:nyc_reservation1) do
      Reservation.create(
        checkin: Date.current - 20,
        checkout: Date.current - 17, # 3 nights
        listing: nyc_listing1,
        guest: guest
      )
    end

    let!(:nyc_reservation2) do
      Reservation.create(
        checkin: Date.current - 15,
        checkout: Date.current - 12, # 3 nights
        listing: nyc_listing2,
        guest: guest
      )
    end

    let!(:nyc_reservation3) do
      Reservation.create(
        checkin: Date.current - 10,
        checkout: Date.current - 8, # 2 nights
        listing: nyc_listing1,
        guest: guest
      )
    end

    let!(:sf_reservation) do
      Reservation.create(
        checkin: Date.current - 25,
        checkout: Date.current - 23, # 2 nights
        listing: sf_listing,
        guest: guest
      )
    end

    # Reviews with different ratings
    let!(:nyc_review1) do
      Review.create(
        description: 'Great NYC stay!',
        rating: 5,
        guest: guest,
        reservation: nyc_reservation1
      )
    end

    let!(:nyc_review2) do
      Review.create(
        description: 'Good NYC apartment',
        rating: 4,
        guest: guest,
        reservation: nyc_reservation2
      )
    end

    let!(:nyc_review3) do
      Review.create(
        description: 'Excellent value',
        rating: 5,
        guest: guest,
        reservation: nyc_reservation3
      )
    end

    let!(:sf_review) do
      Review.create(
        description: 'Nice SF room',
        rating: 4,
        guest: guest,
        reservation: sf_reservation
      )
    end

    describe '.most_reservations' do
      it 'returns city with most reservations' do
        # NYC: 3 reservations, SF: 1 reservation, Chicago: 0 reservations
        expect(City.most_reservations).to eq(nyc)
      end
    end

    describe '.biggest_host' do
      it 'returns city where host with most listings is located' do
        # host1 has 2 listings in NYC, others have 1 each
        expect(City.biggest_host).to eq(nyc)
      end
    end

    describe '.highest_rated' do
      it 'returns city with highest average review rating' do
        # NYC: (5 + 4 + 5) / 3 = 4.67
        # SF: 4 / 1 = 4.0
        # Chicago: no reviews
        expect(City.highest_rated).to eq(nyc)
      end
    end

    describe '.most_listings' do
      it 'returns city with most listings' do
        # NYC: 2 listings, SF: 1 listing, Chicago: 1 listing
        expect(City.most_listings).to eq(nyc)
      end
    end
  end
end
