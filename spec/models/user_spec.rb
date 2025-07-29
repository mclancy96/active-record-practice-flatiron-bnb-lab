require 'spec_helper'

describe User do
  let(:katie) { User.create(name: 'Katie', email: 'katie@example.com') }

  it 'has a name' do
    expect(katie.name).to eq('Katie')
  end

  context 'guest and host' do
    let(:nyc) { City.create(name: 'NYC') }
    let(:sf) { City.create(name: 'San Francisco') }
    let(:green_point) { Neighborhood.create(name: 'Green Point', city: nyc) }
    let(:mission) { Neighborhood.create(name: 'Mission', city: sf) }

    let(:listing1) do
      Listing.create(
        address: '6 Maple Street',
        listing_type: 'shared room',
        title: 'Shared room in apartment',
        description: "share a room with me because I'm poor",
        price: 15.00,
        neighborhood: green_point,
        host: katie
      )
    end

    let(:listing2) do
      Listing.create(
        address: '123 Valencia Street',
        listing_type: 'private room',
        title: 'Private room in SF',
        description: 'Nice private room',
        price: 25.00,
        neighborhood: mission,
        host: katie
      )
    end

    let(:logan) { User.create(name: 'Logan', email: 'logan@example.com') }
    let(:amanda) { User.create(name: 'Amanda', email: 'amanda@example.com') }

    let(:reservation1) do
      Reservation.create(
        checkin: Date.current - 10,
        checkout: Date.current - 7,
        listing: listing1,
        guest: logan
      )
    end

    let(:reservation2) do
      Reservation.create(
        checkin: Date.current - 20,
        checkout: Date.current - 18,
        listing: listing2,
        guest: amanda
      )
    end

    let(:reservation3) do
      Reservation.create(
        checkin: Date.current + 5,
        checkout: Date.current + 8,
        listing: listing1,
        guest: amanda
      )
    end

    context 'as host' do
      it 'has many listings' do
        expect(katie.listings).to include(listing1)
      end

      it 'has many reservations through their listing' do
        expect(katie.reservations).to include(reservation1)
      end

      describe '#host?' do
        it 'returns true when user has listings' do
          listing1 # create the listing
          expect(katie.host?).to be true
        end

        it 'returns false when user has no listings' do
          expect(logan.host?).to be false
        end
      end

      describe '#guests' do
        it "returns all unique guests who stayed at host's listings" do
          reservation1
          reservation2
          reservation3
          expect(katie.guests).to include(logan, amanda)
          expect(katie.guests.uniq.count).to eq(2)
        end
      end

      describe '#host_reviews' do
        let!(:review1) do
          Review.create(
            description: 'Great stay!',
            rating: 5,
            guest: logan,
            reservation: reservation1
          )
        end

        let!(:review2) do
          Review.create(
            description: 'Nice place',
            rating: 4,
            guest: amanda,
            reservation: reservation2
          )
        end

        it "returns all reviews for host's listings" do
          expect(katie.host_reviews).to include(review1, review2)
        end
      end

      describe '#total_earnings' do
        it 'calculates total earnings from all listings' do
          reservation1 # 3 nights * $15 = $45
          reservation2 # 2 nights * $25 = $50
          # Total: $95
          expect(katie.total_earnings).to eq(95.0)
        end
      end

      describe '#average_listing_price' do
        it "returns average price of user's listings" do
          listing1 # $15
          listing2 # $25
          # Average: $20
          expect(katie.average_listing_price).to eq(20.0)
        end
      end
    end

    context 'as guest' do
      let(:host_user) { User.create(name: 'Host', email: 'host@example.com') }
      let(:la) { City.create(name: 'Los Angeles') }
      let(:hollywood) { Neighborhood.create(name: 'Hollywood', city: la) }

      let(:la_listing) do
        Listing.create(
          address: '789 Sunset Blvd',
          listing_type: 'entire apartment',
          title: 'Hollywood Apartment',
          description: 'Great location',
          price: 100.00,
          neighborhood: hollywood,
          host: host_user
        )
      end

      let(:guest_reservation1) do
        Reservation.create(
          checkin: Date.current - 30,
          checkout: Date.current - 28,
          listing: listing1, # NYC
          guest: logan
        )
      end

      let(:guest_reservation2) do
        Reservation.create(
          checkin: Date.current - 20,
          checkout: Date.current - 18,
          listing: listing2, # SF
          guest: logan
        )
      end

      let(:guest_reservation3) do
        Reservation.create(
          checkin: Date.current - 10,
          checkout: Date.current - 8,
          listing: listing1, # NYC again
          guest: logan
        )
      end

      let(:guest_reservation4) do
        Reservation.create(
          checkin: Date.current - 5,
          checkout: Date.current - 3,
          listing: la_listing, # LA
          guest: logan
        )
      end

      let(:review) do
        Review.create(
          description: 'Meh, the host I shared a room with snored.',
          rating: 3,
          guest: logan,
          reservation: guest_reservation1
        )
      end

      it 'has many trips' do
        expect(logan.trips).to include(guest_reservation1)
      end

      it 'has written many reviews' do
        expect(logan.reviews).to include(review)
      end

      describe '#trip_count' do
        it 'returns number of trips as guest' do
          guest_reservation1
          guest_reservation2
          guest_reservation3
          guest_reservation4
          expect(logan.trip_count).to eq(4)
        end
      end

      describe '#top_three_destinations' do
        it 'returns top 3 cities visited most' do
          guest_reservation1 # NYC
          guest_reservation2 # SF
          guest_reservation3 # NYC again
          guest_reservation4 # LA
          # NYC: 2 visits, SF: 1 visit, LA: 1 visit
          top_cities = logan.top_three_destinations
          expect(top_cities.first).to eq(nyc)
          expect(top_cities).to include(sf, la)
          expect(top_cities.length).to be <= 3
        end
      end

      describe '#favorite_neighborhood' do
        it 'returns most visited neighborhood' do
          guest_reservation1 # Green Point
          guest_reservation2 # Mission
          guest_reservation3 # Green Point again
          # Green Point: 2 visits, Mission: 1 visit
          expect(logan.favorite_neighborhood).to eq(green_point)
        end
      end
    end

    describe 'class methods' do
      let(:host1) { User.create(name: 'Host1', email: 'host1@example.com') }
      let(:host2) { User.create(name: 'Host2', email: 'host2@example.com') }
      let(:guest_only) { User.create(name: 'GuestOnly', email: 'guest@example.com') }

      let!(:host1_listing1) do
        Listing.create(
          address: '100 Main St',
          listing_type: 'private room',
          title: 'Room 1',
          description: 'Nice room',
          price: 50.00,
          neighborhood: green_point,
          host: host1
        )
      end

      let!(:host1_listing2) do
        Listing.create(
          address: '200 Main St',
          listing_type: 'private room',
          title: 'Room 2',
          description: 'Another room',
          price: 60.00,
          neighborhood: green_point,
          host: host1
        )
      end

      let!(:host2_listing) do
        Listing.create(
          address: '300 Main St',
          listing_type: 'entire apartment',
          title: 'Apartment',
          description: 'Whole apartment',
          price: 120.00,
          neighborhood: green_point,
          host: host2
        )
      end

      let!(:guest_reservation) do
        Reservation.create(
          checkin: Date.current - 5,
          checkout: Date.current - 3,
          listing: host1_listing1,
          guest: guest_only
        )
      end

      describe '.hosts' do
        it 'returns users who have at least one listing' do
          hosts = User.hosts
          expect(hosts).to include(host1, host2)
          expect(hosts).not_to include(guest_only)
        end
      end

      describe '.guests' do
        it 'returns users who have made at least one reservation' do
          guests = User.guests
          expect(guests).to include(guest_only)
        end
      end

      describe '.top_host' do
        it 'returns user with most listings' do
          expect(User.top_host).to eq(host1) # has 2 listings vs host2's 1
        end
      end

      describe '.most_traveled' do
        let!(:reservation1) do
          Reservation.create(
            checkin: Date.current - 10,
            checkout: Date.current - 8,
            listing: host1_listing1,
            guest: guest_only
          )
        end

        let!(:reservation2) do
          Reservation.create(
            checkin: Date.current - 15,
            checkout: Date.current - 13,
            listing: host2_listing,
            guest: guest_only
          )
        end

        it 'returns user with most trips' do
          expect(User.most_traveled).to eq(guest_only) # has 3 total reservations
        end
      end
    end
  end
end
