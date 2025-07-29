# Comprehensive seed data for practicing ActiveRecord associations and queries
# Run this with: rake db:seed

puts '🌱 Seeding database...'

# Clear existing data
Review.destroy_all
Reservation.destroy_all
Listing.destroy_all
Neighborhood.destroy_all
City.destroy_all
User.destroy_all

# Cities
puts 'Creating cities...'
nyc = City.create!(name: 'New York City', state: 'NY', country: 'USA')
sf = City.create!(name: 'San Francisco', state: 'CA', country: 'USA')
la = City.create!(name: 'Los Angeles', state: 'CA', country: 'USA')
chicago = City.create!(name: 'Chicago', state: 'IL', country: 'USA')

# Neighborhoods
puts 'Creating neighborhoods...'
# NYC neighborhoods
manhattan = Neighborhood.create!(name: 'Manhattan', city: nyc, zip_code: '10001')
brooklyn = Neighborhood.create!(name: 'Brooklyn', city: nyc, zip_code: '11201')
queens = Neighborhood.create!(name: 'Queens', city: nyc, zip_code: '11101')

# SF neighborhoods
mission = Neighborhood.create!(name: 'Mission', city: sf, zip_code: '94110')
soma = Neighborhood.create!(name: 'SOMA', city: sf, zip_code: '94103')
castro = Neighborhood.create!(name: 'Castro', city: sf, zip_code: '94114')

# LA neighborhoods
hollywood = Neighborhood.create!(name: 'Hollywood', city: la, zip_code: '90028')
venice = Neighborhood.create!(name: 'Venice', city: la, zip_code: '90291')

# Chicago neighborhoods
loop = Neighborhood.create!(name: 'The Loop', city: chicago, zip_code: '60601')

# Users
puts 'Creating users...'
alice = User.create!(name: 'Alice Johnson', email: 'alice@example.com')
bob = User.create!(name: 'Bob Smith', email: 'bob@example.com')
charlie = User.create!(name: 'Charlie Brown', email: 'charlie@example.com')
diana = User.create!(name: 'Diana Prince', email: 'diana@example.com')
emma = User.create!(name: 'Emma Watson', email: 'emma@example.com')
frank = User.create!(name: 'Frank Castle', email: 'frank@example.com')

# Listings
puts 'Creating listings...'
# Alice's listings (prolific host)
listing1 = Listing.create!(
  title: 'Cozy Studio in Manhattan',
  description: 'Perfect for business travelers. Walking distance to subway.',
  address: '123 Broadway',
  listing_type: 'entire apartment',
  price: 180.00,
  max_guests: 2,
  active: true,
  neighborhood: manhattan,
  host: alice
)

listing2 = Listing.create!(
  title: 'Brooklyn Loft with Amazing Views',
  description: 'Industrial chic loft in trendy neighborhood.',
  address: '456 Smith Street',
  listing_type: 'entire apartment',
  price: 220.00,
  max_guests: 4,
  active: true,
  neighborhood: brooklyn,
  host: alice
)

listing3 = Listing.create!(
  title: 'Queens Budget Room',
  description: 'Great value for money. Close to airport.',
  address: '789 Northern Blvd',
  listing_type: 'private room',
  price: 85.00,
  max_guests: 1,
  active: true,
  neighborhood: queens,
  host: alice
)

# Bob's listings
listing4 = Listing.create!(
  title: 'Mission District Apartment',
  description: 'Hip neighborhood with great food scene.',
  address: '321 Valencia Street',
  listing_type: 'entire apartment',
  price: 250.00,
  max_guests: 3,
  active: true,
  neighborhood: mission,
  host: bob
)

listing5 = Listing.create!(
  title: 'SOMA High-Rise',
  description: 'Modern apartment in tech district.',
  address: '555 Market Street',
  listing_type: 'private room',
  price: 160.00,
  max_guests: 2,
  active: true,
  neighborhood: soma,
  host: bob
)

# Diana's listings
listing6 = Listing.create!(
  title: 'Hollywood Glamour Suite',
  description: 'Experience old Hollywood charm.',
  address: '777 Sunset Boulevard',
  listing_type: 'entire apartment',
  price: 300.00,
  max_guests: 2,
  active: true,
  neighborhood: hollywood,
  host: diana
)

listing7 = Listing.create!(
  title: 'Venice Beach House',
  description: 'Steps from the beach and boardwalk.',
  address: '888 Ocean Front Walk',
  listing_type: 'entire house',
  price: 400.00,
  max_guests: 6,
  active: true,
  neighborhood: venice,
  host: diana
)

# Emma's listing
listing8 = Listing.create!(
  title: 'Downtown Chicago Studio',
  description: 'Modern studio in the heart of the city.',
  address: '999 State Street',
  listing_type: 'entire apartment',
  price: 140.00,
  max_guests: 2,
  active: true,
  neighborhood: loop,
  host: emma
)

# Reservations
puts 'Creating reservations...'
# Charlie's trips
charlie_res1 = Reservation.create!(
  checkin: Date.current - 30,
  checkout: Date.current - 27,
  guest_count: 1,
  status: 'completed',
  listing: listing1,
  guest: charlie
)

charlie_res2 = Reservation.create!(
  checkin: Date.current - 15,
  checkout: Date.current - 12,
  guest_count: 2,
  status: 'completed',
  listing: listing4,
  guest: charlie
)

charlie_res3 = Reservation.create!(
  checkin: Date.current + 10,
  checkout: Date.current + 14,
  guest_count: 2,
  status: 'confirmed',
  listing: listing6,
  guest: charlie
)

# Diana's trips (when not hosting)
diana_res1 = Reservation.create!(
  checkin: Date.current - 20,
  checkout: Date.current - 18,
  guest_count: 3,
  status: 'completed',
  listing: listing2,
  guest: diana
)

diana_res2 = Reservation.create!(
  checkin: Date.current + 5,
  checkout: Date.current + 8,
  guest_count: 1,
  status: 'confirmed',
  listing: listing8,
  guest: diana
)

# Emma's trips
emma_res1 = Reservation.create!(
  checkin: Date.current - 45,
  checkout: Date.current - 42,
  guest_count: 1,
  status: 'completed',
  listing: listing5,
  guest: emma
)

emma_res2 = Reservation.create!(
  checkin: Date.current - 10,
  checkout: Date.current - 7,
  guest_count: 4,
  status: 'completed',
  listing: listing7,
  guest: emma
)

# Frank's trips
frank_res1 = Reservation.create!(
  checkin: Date.current - 60,
  checkout: Date.current - 58,
  guest_count: 1,
  status: 'completed',
  listing: listing3,
  guest: frank
)

frank_res2 = Reservation.create!(
  checkin: Date.current + 20,
  checkout: Date.current + 23,
  guest_count: 2,
  status: 'confirmed',
  listing: listing1,
  guest: frank
)

# Reviews
puts 'Creating reviews...'
Review.create!(
  description: 'Amazing location! Alice was a wonderful host.',
  rating: 5,
  cleanliness_rating: 5,
  communication_rating: 5,
  guest: charlie,
  reservation: charlie_res1
)

Review.create!(
  description: 'Great apartment, but a bit noisy at night.',
  rating: 4,
  cleanliness_rating: 4,
  communication_rating: 5,
  guest: charlie,
  reservation: charlie_res2
)

Review.create!(
  description: 'Beautiful loft with incredible views!',
  rating: 5,
  cleanliness_rating: 5,
  communication_rating: 4,
  guest: diana,
  reservation: diana_res1
)

Review.create!(
  description: 'Good value for the price. Clean and comfortable.',
  rating: 4,
  cleanliness_rating: 4,
  communication_rating: 4,
  guest: emma,
  reservation: emma_res1
)

Review.create!(
  description: 'Perfect beach getaway! Would definitely stay again.',
  rating: 5,
  cleanliness_rating: 5,
  communication_rating: 5,
  guest: emma,
  reservation: emma_res2
)

Review.create!(
  description: 'Basic room but served its purpose. Close to airport was convenient.',
  rating: 3,
  cleanliness_rating: 3,
  communication_rating: 3,
  guest: frank,
  reservation: frank_res1
)

puts '✅ Seeding complete!'
puts ''
puts '📊 Database Summary:'
puts "#{City.count} cities"
puts "#{Neighborhood.count} neighborhoods"
puts "#{User.count} users"
puts "#{Listing.count} listings"
puts "#{Reservation.count} reservations"
puts "#{Review.count} reviews"
puts ''
puts '🎯 Try these in the console (rake console):'
puts 'User.first.listings'
puts "City.find_by(name: 'New York City').neighborhoods"
puts "Listing.joins(:reviews).where('reviews.rating >= 4')"
puts "User.find_by(name: 'Alice Johnson').guests"
