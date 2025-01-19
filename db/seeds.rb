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
bearer_token = token_json["access_token"]

### Gets the list of games

http = Net::HTTP.new('api.igdb.com',443)
http.use_ssl = true
request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/games'), {'Client-ID' => "#{ENV['CLIENT_ID']}", 'Authorization' => "Bearer #{bearer_token}"})
request.body = <<~QUERY
  fields name, category, franchises, genres, involved_companies, platforms, player_perspectives, release_dates, remakes, remasters, similar_games, slug, status, total_rating, total_rating_count, url, videos;
  where category = 0
  & name ~ "%assassin's creed%";
  limit 50;
QUERY
puts http.request(request).body
