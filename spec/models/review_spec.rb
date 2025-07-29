require 'spec_helper'

describe Review do
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
  let(:review) do
    Review.create(
      description: 'This place was great!',
      rating: 5,
      cleanliness_rating: 5,
      communication_rating: 4,
      guest: logan,
      reservation: reservation
    )
  end

  it 'has a description' do
    expect(review.description).to eq('This place was great!')
  end

  it 'has a rating' do
    expect(review.rating).to eq(5)
  end

  it 'belongs to a guest' do
    expect(review.guest).to eq(logan)
  end

  it 'belongs to a reservation' do
    expect(review.reservation).to be(reservation)
  end

  context 'class methods' do
    let(:guest1) { User.create(name: 'Guest1') }
    let(:guest2) { User.create(name: 'Guest2') }
    let(:host) { User.create(name: 'Host') }

    let(:listing2) do
      Listing.create(
        address: '456 Another St',
        listing_type: 'entire apartment',
        title: 'Another Great Place',
        description: 'Also very nice',
        price: 75.00,
        neighborhood: fidi,
        host: host
      )
    end

    let(:reservation1) do
      Reservation.create(
        checkin: Date.current - 20,
        checkout: Date.current - 18,
        listing: listing,
        guest: guest1
      )
    end

    let(:reservation2) do
      Reservation.create(
        checkin: Date.current - 15,
        checkout: Date.current - 13,
        listing: listing2,
        guest: guest1
      )
    end

    let(:reservation3) do
      Reservation.create(
        checkin: Date.current - 10,
        checkout: Date.current - 8,
        listing: listing,
        guest: guest2
      )
    end

    let(:reservation4) do
      Reservation.create(
        checkin: Date.current - 5,
        checkout: Date.current - 3,
        listing: listing2,
        guest: guest2
      )
    end

    let!(:excellent_review1) do
      Review.create(
        description: 'Absolutely amazing stay!',
        rating: 5,
        guest: guest1,
        reservation: reservation1
      )
    end

    let!(:excellent_review2) do
      Review.create(
        description: 'Perfect place!',
        rating: 5,
        guest: guest2,
        reservation: reservation3
      )
    end

    let!(:good_review) do
      Review.create(
        description: 'Pretty good experience',
        rating: 4,
        guest: guest1,
        reservation: reservation2
      )
    end

    let!(:average_review) do
      Review.create(
        description: 'It was okay',
        rating: 3,
        guest: guest2,
        reservation: reservation4
      )
    end

    let!(:poor_review1) do
      Review.create(
        description: 'Not great',
        rating: 2,
        guest: guest1,
        reservation: reservation
      )
    end

    let!(:terrible_review) do
      Review.create(
        description: 'Awful experience',
        rating: 1,
        guest: guest2,
        reservation: reservation
      )
    end

    describe '.highest_rated' do
      it 'returns reviews with rating of 5' do
        highest = Review.highest_rated
        expect(highest).to include(excellent_review1, excellent_review2)
        expect(highest).not_to include(good_review, average_review, poor_review1, terrible_review)
      end
    end

    describe '.lowest_rated' do
      it 'returns reviews with rating of 1 or 2' do
        lowest = Review.lowest_rated
        expect(lowest).to include(poor_review1, terrible_review)
        expect(lowest).not_to include(excellent_review1, good_review, average_review)
      end
    end

    describe '.most_recent' do
      it 'returns 10 most recent reviews by default' do
        recent = Review.most_recent
        expect(recent.length).to be <= 10
        # Should be ordered by creation time (most recent first)
        expect(recent.first.created_at).to be >= recent.last.created_at
      end

      it 'accepts custom limit parameter' do
        recent = Review.most_recent(3)
        expect(recent.length).to be <= 3
      end
    end

    describe '.average_rating' do
      it 'returns overall average rating across all reviews' do
        # (5 + 5 + 4 + 3 + 2 + 1 + 5) / 7 = 25 / 7 ≈ 3.57
        # Including the original review (rating: 5)
        average = Review.average_rating
        expect(average).to be_between(3.0, 4.0)
        expect(average.round(2)).to eq(3.57)
      end

      it 'returns 0 when no reviews exist' do
        Review.destroy_all
        expect(Review.average_rating).to eq(0)
      end
    end
  end
end
