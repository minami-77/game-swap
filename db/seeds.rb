# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'net/https'
require 'open-uri'
require 'json'
require 'faker'

### Gets the bearer token needed. May be inefficient since we need to get a new one every time we seed (which would be done all in one go anyway, but still)

url = URI.parse("https://id.twitch.tv/oauth2/token")
params = {
  client_id: ENV['CLIENT_ID'],
  client_secret: ENV['CLIENT_SECRET'],
  grant_type: 'client_credentials'
}

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
request = Net::HTTP::Post.new(url.path, {'Content-Type' => 'application/x-www-form-urlencoded'})
request.set_form_data(params)
response = http.request(request)
token_json = JSON.parse(response.body)
BEARER_TOKEN = token_json["access_token"]

# puts BEARER_TOKEN

### Gets the list of games

HTTP_REQUEST = Net::HTTP.new('api.igdb.com',443)
HTTP_REQUEST.use_ssl = true

# IGDB seems to only allow 50 limit per request, so pagination with offset is the key
LIMIT = 50

def get_query(offset, fields_array, additional_game_parameters = "", order_by_clause = "")
  # category_optional is there for when importing games only. Otherwise should be empty string ""
  return <<~QUERY
      fields #{fields_array.join(", ")};
      #{additional_game_parameters}
      #{order_by_clause}
      limit #{LIMIT};
      offset #{offset};
      QUERY
end

# The import order of tables should always be platforms > games > covers


#### Testing seed methods
def seed_dev
  def get_games
    request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/games'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

    5.times do |i|
      offset = i * LIMIT
      request.body = get_query(offset, ["name", "platforms", "summary", "url", "cover", "id", "total_rating", "total_rating_count", "genres"], "where category = 0 & platforms = [167];", "sort total_rating_count desc;")
      games_data = JSON.parse(HTTP_REQUEST.request(request).body)
      break if games_data.empty?

      games_data.each do |game|
        igdb_id = game["id"]
        next if Game.find_by(igdb_id: igdb_id)

        name = game["name"]
        platforms = JSON.generate(game["platforms"])
        genres = JSON.generate(game["genres"])
        search_name = name.gsub(/[^a-z0-9]/i, '').downcase
        summary = game["summary"]
        url = game["url"]
        cover_id = game["cover"]
        total_rating = game["total_rating"].round(1)
        total_rating_count = game["total_rating_count"]
        Game.create!(igdb_id:, name:, platforms:, search_name:, summary:, url:, cover_id:, total_rating:, total_rating_count:, genres:)
      end
    end
    # query notes
    # category 0 is a main game (i.e. not dlc, addon, mod etc)
    # status 0 is a released game
    puts "Games import complete"
  end

  def get_covers
    request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/covers'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

    Game.all.each_with_index do |game, index|
      id = game.igdb_id
      offset = 0
      request.body = get_query(offset, ["url", "id", "game"], "where game = #{id};")
      covers_data = JSON.parse(HTTP_REQUEST.request(request).body)
      next if covers_data.empty?

      #### THE OFFSET IS THE ISSUE
      covers_data.each do |cover|
        cover_id = cover["id"]
        next if Cover.find_by(cover_id: cover_id)

        url = cover["url"]
        url = url.gsub("t_thumb", "t_original")
        new_cover = Cover.new(cover_id:, url:)

        game_id = cover["game"]
        game = Game.find_by(igdb_id: game_id)
        new_cover.game = game
        if !new_cover.save
          puts new_cover.errors.full_messages
        end
      end
    end
    puts "Covers import complete"
  end


  def get_platforms
    request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/platforms'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

    0.upto(Float::INFINITY) do |i|
      offset = i * LIMIT
      request.body = get_query(offset, ["name", "id"])
      platforms_data = JSON.parse(HTTP_REQUEST.request(request).body)
      break if platforms_data.empty?

      platforms_data.each do |platform|
        platform_id = platform["id"]
        next if Platform.find_by(platform_id: platform_id)

        name = platform["name"]
        search_name = name.gsub(/[^a-z0-9]/i, '').downcase
        Platform.create!(platform_id:, name:, search_name:)
      end
    end
    puts "Platforms import complete"
  end

  def get_genres
    request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/genres'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

    0.upto(Float::INFINITY) do |i|
      offset = i * LIMIT
      request.body = get_query(offset, ["name", "id"])
      genres_data = JSON.parse(HTTP_REQUEST.request(request).body)
      break if genres_data.empty?

      genres_data.each do |genre|
        genre_id = genre["id"]
        next if Genre.find_by(genre_id: genre_id)

        name = genre["name"]
        search_name = name.gsub(/[^a-z0-9]/i, '').downcase
        Genre.create!(genre_id:, name:, search_name:)
      end
    end
    puts "Genres import complete"
  end

  Platform.destroy_all
  Genre.destroy_all
  # Cover destroy has to be before game because of dependencies
  Cover.destroy_all
  Game.destroy_all
  get_platforms
  get_genres
  get_games
  get_covers
end

#### Production seed methods
# **** Currently not complete, as seeding methods have slightly changed since the dev seeding was implemented. Covers will need to be done better prior to being able to do a full DB migration. Currently seeding covers through find_by to connect to a game is too slow

# The reason why platform is not linked to games is because games do not have a singular platform id. Each has an array of ids instead, which will be stored in the db as a json object rather than a singular id, which most games do not have. Even ones who do will still be in an array anyway
# def get_platforms
#   request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/platforms'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

#   0.upto(Float::INFINITY) do |i|
#     puts i
#     offset = i * LIMIT
#     request.body = get_query(offset, ["name", "slug", "id"])
#     platforms_data = JSON.parse(HTTP_REQUEST.request(request).body)
#     break if platforms_data.empty?

#     platforms_data.each do |platform|
#       platform_id = platform["id"]
#       next if Platform.find_by(platform_id: platform_id)

#       name = platform["name"]
#       slug = platform["slug"]
#       Platform.create!(platform_id:, name:, slug:)
#     end
#   end
#   puts "Platforms import complete"
# end

# # get_platforms

# def get_games
#   request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/games'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

#   0.upto(Float::INFINITY) do |i|
#     puts i
#     offset = i * LIMIT
#     request.body = get_query(offset, ["name", "platforms", "slug", "summary", "url", "cover", "id"], "where category = 0;")
#     games_data = JSON.parse(HTTP_REQUEST.request(request).body)
#     break if games_data.empty?

#     games_data.each do |game|
#       igdb_id = game["id"]
#       next if Game.find_by(igdb_id: igdb_id)

#       name = game["name"]
#       platforms = JSON.generate(game["platforms"])
#       search_name = name.gsub(/[^a-zA-Z0-9]/, '').downcase
#       summary = game["summary"]
#       url = game["url"]
#       cover_id = game["cover"]
#       Game.create!(igdb_id:, name:, platforms:, search_name:, summary:, url:, cover_id:)
#       puts Game.count
#     end
#   end
#   # query notes
#   # category 0 is a main game (i.e. not dlc, addon, mod etc)
#   # status 0 is a released game
#   puts "Games import complete"
# end

# # get_games

# def get_covers
#   request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/covers'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

#   0.upto(Float::INFINITY) do |i|
#     puts i
#     offset = i * LIMIT
#     request.body = get_query(offset, ["url", "id", "game"])
#     covers_data = JSON.parse(HTTP_REQUEST.request(request).body)
#     break if covers_data.empty?

#     covers_data.each do |cover|
#       cover_id = cover["id"]
#       next if Cover.find_by(cover_id: cover_id)

#       url = cover["url"]
#       new_cover = Cover.new(cover_id:, url:)

#       game_id = cover["game"]
#       game = Game.find_by(igdb_id: game_id)
#       new_cover.game = game
#       if new_cover.save
#         puts new_cover.errors.full_messages
#       end
#     end
#   end
#   puts "Covers import complete"
# end

# get_covers
def seed_db_details
  Location.destroy_all

  Location.create(address: "Shibuya, Tokyo")
  Location.create(address: "Shinjuku, Tokyo")
  Location.create(address: "Harajuku, Tokyo")
  Location.create(address: "Ueno, Tokyo")
  Location.create(address: "Ginza, Tokyo")
  Location.create(address: "Ikebukuro, Tokyo")
  Location.create(address: "Tokyo Disneyland, Chiba")
  Location.create(address: "Hachioji, Tokyo")
  Location.create(address: "Akihabara, Tokyo")
  Location.create(address: "Roppongi, Tokyo")
  Location.create(address: "Tochigi, Tochigi")
  Location.create(address: "Nishi-Kasai, Tokyo")
  Location.create(address: "Shinagawa, Tokyo")

  puts "Location seeding complete"

  # Clear existing data
  User.destroy_all
  # Seed Users
  30.times do
    User.create!(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email,
      username: Faker::Name.name,
      password: "123456",
      password_confirmation: "123456",
      location_id: Location.all.sample.id
    )
  end
  first_user = User.create!(
    first_name: "Alex",
    last_name: "Wong",
    email: "alex@email.com",
    username: "Munkleson",
    password: "123456",
    password_confirmation: "123456",
    location_id: Location.all.sample.id
  )
  second_user = User.create!(
    first_name: "Cindy",
    last_name: "idk",
    email: "cindy@email.com",
    username: "iLiveInTheMiddleOfNowhere",
    password: "123456",
    password_confirmation: "123456",
    location_id: Location.all.sample.id
  )
  third_user = User.create!(
    first_name: "Minami",
    last_name: "Takayama",
    email: "minami@email.com",
    username: "Minami",
    password: "123456",
    password_confirmation: "123456",
    location_id: Location.all.sample.id
  )
  fourth_user = User.create!(
    first_name: "Allan",
    last_name: "Sechrist",
    email: "allan@email.com",
    username: "Mr Allan",
    password: "123456",
    password_confirmation: "123456",
    location_id: Location.all.sample.id
  )
  puts "User import complete"

  # Clear existing data
  Listing.destroy_all

  array_of_yen = [500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500]
  array_of_platforms = [167, 169, 130, 6, 48, 49]

  # Seed Listings
  User.all.each do |user|
    3.times do |_i|
      random_platform = Platform.find_by(platform_id: array_of_platforms.sample)
      Listing.create!(
        price: array_of_yen[rand(array_of_yen.count)],
        description: "This is a sample listing description.",
        max: rand(5..30),
        user: user,
        game: Game.all[rand(Game.count)],
        platform: random_platform,
      )
    end
  end

  puts "Listings import complete"

  # Clear existing data
  Offer.destroy_all
  # Seed offers
  250.times do |i|
    Offer.create!(
      comments: 'This is a sample offer comment.',
      start_date: Date.today + i,
      price: rand(50..200),
      period: rand(5..30),
      listing: Listing.all.sample,
      user: User.all.sample
    )
  end
  puts "Offers import complete"
end

def seed_messages_and_chats
  seed_amount = 10

  Message.destroy_all
  Chat.destroy_all

  users = User.where.not(username: ["Mr Allan", "Munkleson", "Minami", "iLiveInTheMiddleOfNowhere"]).sample(seed_amount)
  test_users = User.where(username: ["Mr Allan", "Munkleson", "Minami", "iLiveInTheMiddleOfNowhere"])
  test_users.each do |test_user|
    seed_amount.times do |index|
      random_user = users[rand(users.length)]
      # user = User.find_by(username: "asdf1")
      chat_users = [test_user, random_user]
      chat = Chat.create!(
        first_user_id: test_user.id,
        second_user_id: random_user.id
      )

      rand(3..20).times do
        message = chat.messages.create!(
          message: "Hi",
          chat: chat,
          user: chat_users.sample
        )
      end
  end

  end

  Chat.all.each do |chat|
    chat.update(last_message: chat.messages.last.created_at)
  end
  puts "Chats and messages seeding complete"
end

# seed_dev
seed_db_details
seed_messages_and_chats
