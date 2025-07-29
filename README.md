# ActiveRecord Practice: Flatiron BnB Lab

## Learning Objectives

After completing this lab, you will be able to:

- **Active Record Migrations**: Create and modify database tables using Active Record migrations with different data types
- **Active Record Associations**: Establish and manage relationships between models (one-to-many, many-to-many)
- **Class and Instance Methods**: Implement custom methods to manipulate data and perform operations
- **Active Record Querying**: Perform database queries using Active Record methods to filter, sort, and retrieve data efficiently

## Overview

You're going to build a simplified version of Airbnb using ActiveRecord! This lab focuses purely on the data layer - you'll create models, migrations, associations, and custom methods without getting distracted by Rails complexity.

## Getting Started

1. **Install dependencies:**

   ```bash
   bundle install
   ```

2. **Set up the database:**
   ```bash
   rake db:create
   ```

## Part 1: Database Migrations

You need to create migrations for six related models. Think carefully about the relationships between these entities:

- **Users** can be both hosts (who list properties) and guests (who make reservations)
- **Cities** contain multiple neighborhoods
- **Neighborhoods** belong to cities and contain multiple listings
- **Listings** belong to neighborhoods and are hosted by users
- **Reservations** connect guests (users) to listings
- **Reviews** are written by guests about their reservations

### Step 1: Create Migration Files

Create migration files for each model. Use descriptive names that follow Rails conventions:

```bash
rake db:create_migration NAME=create_users
rake db:create_migration NAME=create_cities
rake db:create_migration NAME=create_neighborhoods
rake db:create_migration NAME=create_listings
rake db:create_migration NAME=create_reservations
rake db:create_migration NAME=create_reviews
```

### Step 2: Define Your Schema

Think about what attributes each model needs and their data types:

#### Users Table

- `name` (string) - The user's name
- `created_at` and `updated_at` (datetime) - Rails timestamps

#### Cities Table

- `name` (string) - The city name
- `created_at` and `updated_at` (datetime)

#### Neighborhoods Table

- `name` (string) - The neighborhood name
- `city_id` (integer) - Foreign key to cities table
- `created_at` and `updated_at` (datetime)

#### Listings Table

- `title` (string) - The listing title
- `description` (text) - Longer description text
- `address` (string) - The street address
- `listing_type` (string) - e.g., "private room", "entire home"
- `price` (decimal) - Price per night
- `neighborhood_id` (integer) - Foreign key to neighborhoods
- `host_id` (integer) - Foreign key to users (the host)
- `created_at` and `updated_at` (datetime)

#### Reservations Table

- `checkin` (date) - Check-in date
- `checkout` (date) - Check-out date
- `listing_id` (integer) - Foreign key to listings
- `guest_id` (integer) - Foreign key to users (the guest)
- `created_at` and `updated_at` (datetime)

#### Reviews Table

- `description` (text) - The review text
- `rating` (integer) - Rating from 1-5
- `guest_id` (integer) - Foreign key to users (who wrote the review)
- `reservation_id` (integer) - Foreign key to reservations
- `created_at` and `updated_at` (datetime)

### Step 3: Run Your Migrations

```bash
rake db:migrate
```

**Tip**: If you make a mistake, you can rollback and fix it:

```bash
rake db:rollback
# Edit your migration file
rake db:migrate
```

## Part 2: Model Associations

Now implement the ActiveRecord associations in your model files. Consider these relationships:

### User Model (`app/models/user.rb`)

A user can be both a host and a guest:

- As a host: has many listings
- As a host: has many reservations through their listings
- As a guest: has many reservations (called "trips")
- As a guest: has many reviews

### City Model (`app/models/city.rb`)

- Has many neighborhoods
- Has many listings through neighborhoods

### Neighborhood Model (`app/models/neighborhood.rb`)

- Belongs to a city
- Has many listings

### Listing Model (`app/models/listing.rb`)

- Belongs to a neighborhood
- Belongs to a host (user)
- Has many reservations
- Has many reviews through reservations
- Has many guests through reservations

### Reservation Model (`app/models/reservation.rb`)

- Belongs to a listing
- Belongs to a guest (user)
- Has many reviews

### Review Model (`app/models/review.rb`)

- Belongs to a guest (user)
- Belongs to a reservation

**Key Challenge**: Notice how `User` has multiple relationships - they can be both hosts and guests. You'll need to use `class_name` and `foreign_key` options for some associations.

## Part 3: Seed Your Database

Once you've created your models and associations, populate your database with the comprehensive seed data:

```bash
rake db:seed
```

This will create a rich dataset including:

- **4 cities** (NYC, San Francisco, Los Angeles, Chicago)
- **9 neighborhoods** across those cities
- **6 users** who act as both hosts and guests
- **8 listings** with different types and price ranges
- **9 reservations** spanning past, present, and future dates
- **6 reviews** with varying ratings

The seed data is designed to help you practice complex queries and understand the relationships between models. You'll have:

- **Prolific hosts** (like Alice with 3 listings)
- **Frequent travelers** (like Charlie with multiple trips)
- **Cross-relationships** (users who are both hosts and guests)
- **Realistic data patterns** for testing your custom methods

### Test Your Associations

After seeding, test your associations in the console:

```bash
rake console
```

Try these example queries to verify your associations work:

```ruby
# Basic associations
User.first.listings                    # Should return listings hosted by the first user
City.find_by(name: "New York City").neighborhoods  # Should return NYC neighborhoods
Listing.first.host                     # Should return the user who hosts this listing

# More complex associations
alice = User.find_by(name: "Alice Johnson")
alice.listings.count                   # Should show Alice's 3 listings
alice.guests                          # Should show all guests who stayed at Alice's places

# Cross-model queries
Listing.joins(:reviews).where('reviews.rating >= 4')  # Highly rated listings
User.joins(:listings).distinct.count  # Count of users who are hosts
```

The comprehensive seed data will give you plenty of material to practice with when implementing your custom methods!

## Part 4: Custom Methods

Now add custom methods to your models that leverage the associations and demonstrate different ActiveRecord concepts:

### User Methods

Add these **instance methods** to the User class:

1. **`#host?`** - Returns true if the user has any listings
2. **`#guests`** - Returns all unique guests who have stayed at this host's listings
3. **`#host_reviews`** - Returns all reviews for this host's listings
4. **`#trip_count`** - Returns the number of trips this user has taken as a guest
5. **`#top_three_destinations`** - Returns the top 3 cities this user has visited most (as a guest)
6. **`#favorite_neighborhood`** - Returns the neighborhood this user has visited most as a guest
7. **`#total_earnings`** - Returns total earnings from all of this user's listings
8. **`#average_listing_price`** - Returns the average price of this user's listings

Add these **class methods** to the User class:

1. **`.hosts`** - Returns all users who have at least one listing
2. **`.guests`** - Returns all users who have made at least one reservation
3. **`.top_host`** - Returns the user with the most listings
4. **`.most_traveled`** - Returns the user with the most trips

### Listing Methods

Add these **instance methods** to the Listing class:

1. **`#average_review_rating`** - Returns the average rating for this listing (or 0 if no reviews)
2. **`#booked?`** - Returns true if the listing has any reservations
3. **`#total_earnings`** - Calculates total earnings from all reservations
4. **`#most_recent_review`** - Returns the most recent review for this listing
5. **`#available_on?(date)`** - Returns true if the listing is available on a given date
6. **`#booking_count`** - Returns the total number of reservations for this listing

Add these **class methods** to the Listing class:

1. **`.highest_rated`** - Returns listings with an average rating of 4 or higher
2. **`.most_expensive`** - Returns the listing with the highest price
3. **`.by_city(city_name)`** - Returns all listings in a given city
4. **`.available_between(start_date, end_date)`** - Returns listings available in a date range
5. **`.top_earners`** - Returns the top 3 listings by total earnings

### City Methods

Add these **class methods** to the City class:

1. **`.most_reservations`** - Returns the city with the most reservations
2. **`.biggest_host`** - Returns the city where the host with the most listings is located
3. **`.highest_rated`** - Returns the city with the highest average review rating
4. **`.most_listings`** - Returns the city with the most listings

### Neighborhood Methods

Add these **instance methods** to the Neighborhood class:

1. **`#most_popular_listing`** - Returns the listing with the most reservations in this neighborhood
2. **`#average_price`** - Returns the average listing price in this neighborhood
3. **`#reservation_count`** - Returns total number of reservations in this neighborhood

Add these **class methods** to the Neighborhood class:

1. **`.highest_earner`** - Returns the neighborhood with the highest total earnings
2. **`.most_expensive`** - Returns the neighborhood with the highest average listing price

### Reservation Methods

Add these **instance methods** to the Reservation class:

1. **`#duration`** - Returns the number of nights for this reservation
2. **`#total_cost`** - Returns the total cost (price per night \* duration)

Add these **class methods** to the Reservation class:

1. **`.most_recent(limit = 5)`** - Returns the most recent reservations (default 5)
2. **`.highest_grossing`** - Returns the reservation with the highest total cost
3. **`.by_month(month, year)`** - Returns reservations for a specific month/year
4. **`.current_guests`** - Returns users who are currently checked in (today's date is between checkin/checkout)

### Review Methods

Add these **class methods** to the Review class:

1. **`.highest_rated`** - Returns reviews with a rating of 5
2. **`.lowest_rated`** - Returns reviews with a rating of 1 or 2
3. **`.most_recent(limit = 10)`** - Returns the most recent reviews (default 10)
4. **`.average_rating`** - Returns the overall average rating across all reviews

## Part 5: Testing Your Work

Run the test suite to check your implementation:

```bash
bundle exec rspec
```

The tests will verify:

- ✅ Your migrations created the correct tables and columns
- ✅ Your associations work properly
- ✅ Your custom methods return expected results

## Part 6: Interactive Testing

Use the console to test your methods interactively:

```bash
rake console
```

Try these examples:

```ruby
# Test associations
user = User.first
user.listings
user.trips

# Test custom methods
user.host?
user.trip_count
Listing.highest_rateds
City.most_res

# Test queries
User.hosts.count
Listing.by_city("NYC")
```

## Final Tips

- **Write clean, modular code** with clear functions for each task
- **Test your code frequently** to catch and fix errors early
- **Use `rake console`** to test methods interactively
- **Prioritize getting things working** before optimizing or refactoring
- **Read error messages carefully** - they often tell you exactly what's wrong
- **Use `binding.pry`** to debug when you're stuck

## Common Gotchas

1. **Foreign Key Names**: Make sure your foreign keys follow the convention (`model_id`)
2. **Association Names**: Use descriptive names when you have multiple relationships to the same model
3. **Class vs Instance Methods**: Remember the difference between `self.method_name` (class) and `method_name` (instance)
4. **Nil Checks**: Always consider what happens when associations return `nil` or empty collections

Good luck building your ActiveRecord skills! 🏠✨
