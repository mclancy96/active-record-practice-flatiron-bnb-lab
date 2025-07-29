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
nyc = City.create!(name: 'New York City')
sf = City.create!(name: 'San Francisco')
la = City.create!(name: 'Los Angeles')
chicago = City.create!(name: 'Chicago')

# Neighborhoods
puts 'Creating neighborhoods...'
# NYC neighborhoods
manhattan = Neighborhood.create!(name: 'Manhattan', city: nyc)
brooklyn = Neighborhood.create!(name: 'Brooklyn', city: nyc)
queens = Neighborhood.create!(name: 'Queens', city: nyc)

# SF neighborhoods
mission = Neighborhood.create!(name: 'Mission', city: sf)
soma = Neighborhood.create!(name: 'SOMA', city: sf)
castro = Neighborhood.create!(name: 'Castro', city: sf)

# LA neighborhoods
hollywood = Neighborhood.create!(name: 'Hollywood', city: la)
venice = Neighborhood.create!(name: 'Venice', city: la)

# Chicago neighborhoods
loop = Neighborhood.create!(name: 'The Loop', city: chicago)

# Users
puts 'Creating users...'
alice = User.create!(name: 'Alice Johnson')
bob = User.create!(name: 'Bob Smith')
charlie = User.create!(name: 'Charlie Brown')
diana = User.create!(name: 'Diana Prince')
emma = User.create!(name: 'Emma Watson')
frank = User.create!(name: 'Frank Castle')

# Listings
puts 'Creating listings...'
# Alice's listings (prolific host)
listing1 = Listing.create!(
  title: 'Cozy Studio in Manhattan',
  description: 'Perfect for business travelers. Walking distance to subway.',
  address: '123 Broadway',
  listing_type: 'entire apartment',
  price: 180.00,
  neighborhood: manhattan,
  host: alice
)

listing2 = Listing.create!(
  title: 'Brooklyn Loft with Amazing Views',
  description: 'Industrial chic loft in trendy neighborhood.',
  address: '456 Smith Street',
  listing_type: 'entire apartment',
  price: 220.00,
  neighborhood: brooklyn,
  host: alice
)

listing3 = Listing.create!(
  title: 'Queens Budget Room',
  description: 'Great value for money. Close to airport.',
  address: '789 Northern Blvd',
  listing_type: 'private room',
  price: 85.00,
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
  neighborhood: mission,
  host: bob
)

listing5 = Listing.create!(
  title: 'SOMA High-Rise',
  description: 'Modern apartment in tech district.',
  address: '555 Market Street',
  listing_type: 'private room',
  price: 160.00,
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
  neighborhood: hollywood,
  host: diana
)

listing7 = Listing.create!(
  title: 'Venice Beach House',
  description: 'Steps from the beach and boardwalk.',
  address: '888 Ocean Front Walk',
  listing_type: 'entire house',
  price: 400.00,
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
  neighborhood: loop,
  host: emma
)

# Reservations
puts 'Creating reservations...'
# Charlie's trips
res1 = Reservation.create!(
  checkin: Date.current - 30,
  checkout: Date.current - 27,
  listing: listing1,
  guest: charlie
)

res2 = Reservation.create!(
  checkin: Date.current - 15,
  checkout: Date.current - 12,
  listing: listing4,
  guest: charlie
)

res3 = Reservation.create!(
  checkin: Date.current + 10,
  checkout: Date.current + 14,
  listing: listing6,
  guest: charlie
)

# Diana's trips (when not hosting)
res4 = Reservation.create!(
  checkin: Date.current - 20,
  checkout: Date.current - 18,
  listing: listing2,
  guest: diana
)

res5 = Reservation.create!(
  checkin: Date.current + 5,
  checkout: Date.current + 8,
  listing: listing8,
  guest: diana
)

# Emma's trips
res6 = Reservation.create!(
  checkin: Date.current - 45,
  checkout: Date.current - 42,
  listing: listing5,
  guest: emma
)

res7 = Reservation.create!(
  checkin: Date.current - 10,
  checkout: Date.current - 7,
  listing: listing7,
  guest: emma
)

# Frank's trips
res8 = Reservation.create!(
  checkin: Date.current - 60,
  checkout: Date.current - 58,
  listing: listing3,
  guest: frank
)

res9 = Reservation.create!(
  checkin: Date.current + 20,
  checkout: Date.current + 23,
  listing: listing1,
  guest: frank
)

# Reviews
puts 'Creating reviews...'
Review.create!(
  description: 'Amazing location! Alice was a wonderful host.',
  rating: 5,
  guest: charlie,
  reservation: res1
)

Review.create!(
  description: 'Great apartment, but a bit noisy at night.',
  rating: 4,
  guest: charlie,
  reservation: res2
)

Review.create!(
  description: 'Beautiful loft with incredible views!',
  rating: 5,
  guest: diana,
  reservation: res4
)

Review.create!(
  description: 'Good value for the price. Clean and comfortable.',
  rating: 4,
  guest: emma,
  reservation: res6
)

Review.create!(
  description: 'Perfect beach getaway! Would definitely stay again.',
  rating: 5,
  guest: emma,
  reservation: res7
)

Review.create!(
  description: 'Basic room but served its purpose. Close to airport was convenient.',
  rating: 3,
  guest: frank,
  reservation: res8
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
