# ActiveRecord Practice: Flatiron BnB Lab

> **Note:** This is a fork of [learn-co-curriculum/active-record-practice-flatiron-bnb-lab](https://github.com/learn-co-curriculum/active-record-practice-flatiron-bnb-lab) that has been adapted to focus specifically on Active Record concepts and practices.

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
   bundle exec rake db:create
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
bundle exec rake db:create_migration NAME=create_users
bundle exec rake db:create_migration NAME=create_cities
...
```

### Step 2: Define Your Schema

Think about what attributes each model needs and their data types:

#### Users Table

- `name` (string) - The user's name
- `email` (string) - User's email address (add unique index)
- `created_at` and `updated_at` (datetime) - Rails timestamps

#### Cities Table

- `name` (string) - The city name
- `state` (string) - State/province abbreviation
- `country` (string) - Country name
- `created_at` and `updated_at` (datetime)

#### Neighborhoods Table

- `name` (string) - The neighborhood name
- `city_id` (integer) - Foreign key to cities table
- `zip_code` (string) - Postal code for the area
- `created_at` and `updated_at` (datetime)

#### Listings Table

- `title` (string) - The listing title
- `description` (text) - Longer description text
- `address` (string) - The street address
- `listing_type` (string) - e.g., "private room", "entire home"
- `price` (decimal, precision: 8, scale: 2) - Price per night
- `max_guests` (integer) - Maximum number of guests
- `neighborhood_id` (integer) - Foreign key to neighborhoods
- `host_id` (integer) - Foreign key to users (the host)
  - For this, you'll need to tell ActiveRecord which table to use:

  - `foreign_key: { to_table: :users }`

- `active` (boolean, default: true) - Whether listing is currently active
- `created_at` and `updated_at` (datetime)

#### Reservations Table

- `checkin` (date) - Check-in date
- `checkout` (date) - Check-out date
- `guest_count` (integer) - Number of guests
- `status` (string, default: 'confirmed') - Reservation status
- `listing_id` (integer) - Foreign key to listings
- `guest_id` (integer) - Foreign key to users (the guest)
  - For this, you'll need to tell ActiveRecord which table to use:
  - `foreign_key: { to_table: :users }`
- `created_at` and `updated_at` (datetime)

#### Reviews Table

- `description` (text) - The review text
- `rating` (integer) - Rating from 1-5
- `cleanliness_rating` (integer) - Specific rating for cleanliness (1-5)
- `communication_rating` (integer) - Host communication rating (1-5)
- `guest_id` (integer) - Foreign key to users (who wrote the review)
- `reservation_id` (integer) - Foreign key to reservations
- `created_at` and `updated_at` (datetime)

### Step 3: Run Your Migrations

After creating your migration files, you need to run them in both development and test environments:

```bash
# Run migrations for development
bundle exec rake db:migrate

# Run migrations for test environment (needed for running specs)
RACK_ENV=test bundle exec rake db:migrate
```

**Important**: The test environment uses a separate database (`db/test.sqlite3`), so you must run migrations in both environments for the specs to work properly.

**Tip**: If you make a mistake, you can rollback and fix it:

```bash
bundle exec rake db:rollback
# Edit your migration file
bundle exec rake db:migrate
```

## Part 2: Model Associations

Now you need to implement the ActiveRecord associations in your model files. This is where you'll define how your models relate to each other. Study your database schema and think carefully about the relationships between entities.

### Understanding Relationships

Look at your foreign keys - they tell a story about how data connects:

- When you see a `_id` column, that model belongs to another model
- The model being referenced likely has many of the models that reference it
- Some models might be connected through intermediate models

### User Model - The Tricky One (`app/models/user.rb`)

The User model is special because users play **two different roles** in your application:

1. **As hosts**: Users can create listings and receive guests
2. **As guests**: Users can make reservations and write reviews

This creates a challenge: how do you handle the same model (User) acting in different capacities?

**Hint for the User model**: You'll need to set up associations that distinguish between these roles. Consider:

- When a user acts as a host, they "own" certain records
- When a user acts as a guest, they're referenced differently in other models
- You might need to use `class_name` and `foreign_key` options to specify which User role you're referring to
- Some associations might need custom names that make the role clear (like "trips" instead of "reservations" for a guest's bookings)

**Think about it**: If you're looking at a reservation record, you need to know both who is hosting (through the listing) and who is staying (the guest). How would you set up associations to make both of these relationships clear?

#### Example: User Model Implementation

Here's a concrete example to get you started with the User model's dual-role challenge:

```ruby
class User < ActiveRecord::Base
  # When a user acts as a HOST:
  has_many :listings, foreign_key: 'host_id'

  # When a user acts as a GUEST:
  has_many :trips, class_name: 'Reservation', foreign_key: 'guest_id'

  # You'll need to figure out the rest...
  # Think about:
  # - How does a host get to their reservations?
  # - How does a host see all their guests?
  # - How does a guest access their reviews?
end
```

**Breaking down this example:**

- `has_many :listings, foreign_key: 'host_id'` - This tells ActiveRecord that when we call `user.listings`, it should look for records in the listings table where `host_id` matches this user's id
- `has_many :trips, class_name: 'Reservation', foreign_key: 'guest_id'` - This creates a custom association name ("trips") that points to the Reservation model, but uses the `guest_id` column to find the right records

**Your turn:** Based on this pattern, can you figure out how to set up associations for:

- A host getting all reservations for their listings?
- A host seeing all the guests who have stayed at their places?
- A guest accessing the reviews they've written?

**Hint**: You might need `has_many :through` for some of these!

### Other Models - Figure These Out

For the remaining models, analyze your schema and think through the relationships:

**City Model (`app/models/city.rb`)**

- Look at which models reference cities (directly or indirectly)
- Consider what you can reach from a city through its immediate connections

**Neighborhood Model (`app/models/neighborhood.rb`)**

- Check your foreign keys - what does a neighborhood belong to?
- What models reference neighborhoods?

**Listing Model (`app/models/listing.rb`)**

- Examine the `host_id` and `neighborhood_id` columns - what do these tell you?
- Think about what gets created "under" a listing
- Consider how guests interact with listings

**Reservation Model (`app/models/reservation.rb`)**

- Look at your foreign keys: `listing_id` and `guest_id`
- What models might reference reservations?

**Review Model (`app/models/review.rb`)**

- Check what foreign keys exist on reviews
- Think about who writes reviews and what they're reviewing

### Testing Your Associations

As you implement each association, test it in the console to make sure it works:

```bash
bundle exec rake console
```

Try queries like:

```ruby
# Does this make sense for your data model?
some_model.other_models.count
other_model.some_models.first
```

**Remember**: The goal is to be able to navigate between related data easily. If you find yourself writing complex queries to get from one model to related data, you might be missing an association!

## Part 3: Seed Your Database

Once you've created your models and associations, populate your database with the comprehensive seed data:

```bash
bundle exec rake db:seed
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
bundle exec rake console
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
5. **`.by_rating(rating)`** - Returns all reviews with a specific rating
6. **`.detailed_ratings`** - Returns a hash with count of each rating (1-5)

## Part 5: Testing Your Work

Run the test suite to check your implementation:

```bash
bundle exec rspec
```

The tests will verify:

- ✅ Your migrations created the correct tables and columns
- ✅ Your associations work properly
- ✅ Your custom methods return expected results

Use the console to test your methods interactively:

```bash
bundle exec rake console
```

## Final Tips & Best Practices

### Debugging Checklist

When your method isn't working:

1. **Check the association** - does `user.listings` return what you expect?
2. **Test the SQL** - use `.to_sql` to see what query is being generated
3. **Check for typos** - method names, column names, association names
4. **Verify data exists** - are there records to work with?
5. **Use `binding.pry`** - step through your method line by line
6. **Check the return value** - methods should return what you expect

### Additional Practice Ideas

Once you've completed the basic requirements, try these challenges:

1. **Build a booking system** - prevent double bookings for the same dates
2. **Add price calculations** - include taxes, fees, and discounts
3. **Create a search system** - find listings by multiple criteria
4. **Build analytics** - track popular destinations, peak seasons, etc.
5. **Add user preferences** - favorite listings, saved searches
6. **Implement a rating system** - beyond simple averages
7. **Create reports** - monthly earnings, occupancy rates, etc.

Good luck building your ActiveRecord skills! 🏠✨
