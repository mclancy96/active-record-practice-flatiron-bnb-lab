# Create sample data for testing ActiveRecord associations

# Cities
nyc = City.create(name: "New York City")
sf = City.create(name: "San Francisco")

# Neighborhoods
financial_district = Neighborhood.create(name: "Financial District", city: nyc)
greenpoint = Neighborhood.create(name: "Greenpoint", city: nyc)
mission = Neighborhood.create(name: "Mission", city: sf)

# Users
alice = User.create(name: "Alice")
bob = User.create(name: "Bob")
charlie = User.create(name: "Charlie")

# Listings
listing1 = Listing.create(
  address: "123 Wall Street",
  listing_type: "private room",
  title: "Cozy room in Financial District",
  description: "Perfect for business travelers",
  price: 150.00,
  neighborhood: financial_district,
  host: alice
)

listing2 = Listing.create(
  address: "456 Norman Ave",
  listing_type: "entire apartment",
  title: "Trendy Greenpoint Apartment",
  description: "Hip neighborhood with great restaurants",
  price: 200.00,
  neighborhood: greenpoint,
  host: bob
)

listing3 = Listing.create(
  address: "789 Mission Street",
  listing_type: "shared room",
  title: "Shared space in the Mission",
  description: "Great for budget travelers",
  price: 75.00,
  neighborhood: mission,
  host: alice
)

# Reservations
reservation1 = Reservation.create(
  checkin: Date.today + 7,
  checkout: Date.today + 10,
  listing: listing1,
  guest: charlie
)

reservation2 = Reservation.create(
  checkin: Date.today + 14,
  checkout: Date.today + 16,
  listing: listing2,
  guest: charlie
)

# Reviews
Review.create(
  description: "Great location, very clean!",
  rating: 5,
  guest: charlie,
  reservation: reservation1
)

puts "Seeded database with:"
puts "#{City.count} cities"
puts "#{Neighborhood.count} neighborhoods"
puts "#{User.count} users"
puts "#{Listing.count} listings"
puts "#{Reservation.count} reservations"
puts "#{Review.count} reviews"
