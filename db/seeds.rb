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

### Gets the list of games

HTTP_REQUEST = Net::HTTP.new('api.igdb.com',443)
HTTP_REQUEST.use_ssl = true

# IGDB seems to only allow 50 limit
LIMIT = 50

def get_query(offset, fields_array, additional_game_parameters = "")
  # category_optional is there for when importing games only. Otherwise should be empty string ""
  return <<~QUERY
      fields #{fields_array.join(", ")};
      #{additional_game_parameters}
      limit #{LIMIT};
      offset #{offset};
      QUERY
end

# The import order of tables should always be platforms > games > covers


#### Testing seed methods

def get_platforms
  request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/platforms'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

  0.upto(Float::INFINITY) do |i|
    puts i
    offset = (i + 1) * LIMIT
    request.body = get_query(offset, ["name", "slug", "id"])
    platforms_data = JSON.parse(HTTP_REQUEST.request(request).body)
    break if platforms_data.empty?

    platforms_data.each do |platform|
      platform_id = platform["id"]
      next if Platform.find_by(platform_id: platform_id)

      name = platform["name"]
      slug = platform["slug"]
      Platform.create!(platform_id:, name:, slug:)
    end
  end
  puts "Platforms import complete"
end

get_platforms

def get_games
  request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/games'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

  30 times do |i|
    puts i
    offset = (i + 1) * LIMIT
    request.body = get_query(offset, ["name", "platforms", "slug", "summary", "url", "cover", "id"], "where category = 0 & platforms = [73];")
    games_data = JSON.parse(http.request(request).body)
    break if games_data.empty?

    games_data.each do |game|
      igdb_id = game["id"]
      next if Game.find_by(igdb_id: igdb_id)

      name = game["name"]
      platforms = JSON.generate(game["platforms"])
      slug = game["slug"]
      summary = game["summary"]
      url = game["url"]
      cover_id = game["cover"]
      Game.create!(igdb_id:, name:, platforms:, slug:, summary:, url:, cover_id:)
      puts Game.count
    end
  end
  # query notes
  # category 0 is a main game (i.e. not dlc, addon, mod etc)
  # status 0 is a released game
  puts "Games import complete"
end

get_games

def get_covers
  request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/covers'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

  Game.all.each do |game|
    puts i

    id = game.igdb_id
    offset = (i + 1) * LIMIT
    request.body = get_query(offset, ["url", "id", "game"], "where id = #{id};")
    covers_data = JSON.parse(HTTP_REQUEST.request(request).body)
    break if covers_data.empty?

    covers_data.each do |cover|
      cover_id = cover["id"]
      next if Cover.find_by(cover_id: cover_id)

      url = cover["url"]
      cover = Cover.new(cover_id:, url:)

      game_id = cover["game"]
      game = Game.find_by(igdb_id: game_id)
      cover.game = game

      cover.save
    end
  end
  puts "Covers import complete"
end

get_covers




#### Production seed methods

# The reason why platform is not linked to games is because games do not have a singular platform id. Each has an array of ids instead, which will be stored in the db as a json object rather than a singular id, which most games do not have. Even ones who do will still be in an array anyway
# def get_platforms
#   request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/platforms'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{BEARER_TOKEN}"})

#   0.upto(Float::INFINITY) do |i|
#     puts i
#     offset = (i + 1) * LIMIT
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
#     offset = (i + 1) * LIMIT
#     request.body = get_query(offset, ["name", "platforms", "slug", "summary", "url", "cover", "id"], "where category = 0;")
#     games_data = JSON.parse(http.request(request).body)
#     break if games_data.empty?

#     games_data.each do |game|
#       igdb_id = game["id"]
#       next if Game.find_by(igdb_id: igdb_id)

#       name = game["name"]
#       platforms = JSON.generate(game["platforms"])
#       slug = game["slug"]
#       summary = game["summary"]
#       url = game["url"]
#       cover_id = game["cover"]
#       Game.create!(igdb_id:, name:, platforms:, slug:, summary:, url:, cover_id:)
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
#     offset = (i + 1) * LIMIT
#     request.body = get_query(offset, ["url", "id", "game"])
#     covers_data = JSON.parse(HTTP_REQUEST.request(request).body)
#     break if covers_data.empty?

#     covers_data.each do |cover|
#       cover_id = cover["id"]
#       next if Cover.find_by(cover_id: cover_id)

#       url = cover["url"]
#       cover = Cover.new(cover_id:, url:)

#       game_id = cover["game"]
#       game = Game.find_by(igdb_id: game_id)
#       cover.game = game

#       cover.save
#     end
#   end
#   puts "Covers import complete"
# end

# get_covers
