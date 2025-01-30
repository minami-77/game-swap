class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    @listings = Listing.includes(:game).all.shuffle # Randomize the order of listings for carousel display
    @carousel_groups = @listings.each_slice(6).to_a
    # Ensure each group has 6 items by filling with items from the beginning
    @carousel_groups.each do |group|
      while group.size < 6
        group << @listings[group.size % @listings.size]
      end
    end

    @query = params[:query]
    if @query.present?
      normalized_query = @query.gsub(/[^a-z0-9]/i, '').downcase
      @listings = Listing.joins(:game).where('games.search_name LIKE ?', "%#{normalized_query}%")
    else
      @listings = Listing.all
    end

    # Get only genres from games that are actually listed
    listed_games = Game.joins(:listings).distinct
    genres_from_listings = listed_games.pluck(:genres).map { |genre| genre.gsub(/\[|\]/, '').split(',').map(&:to_i) }.flatten.uniq

    # Select two random genres from listed games
    if genres_from_listings.any?
      selected_genres = genres_from_listings.sample(2)
      @genre1, @genre2 = selected_genres
    else
      @genre1, @genre2 = nil, nil
    end

    # Debugging output
    puts "Selected genres: #{@genre1}, #{@genre2}"

    # Fetch listings for selected genres based on genre_id from Genre table
    if @genre1
      @genre1_id = Genre.find_by(search_name: @genre1)&.genre_id
      puts "Genre 1 ID: #{@genre1_id}"  # Debugging output
      if @genre1_id
        @listings_genre1 = Listing.joins(:game).where("CAST(games.genres AS TEXT) LIKE ?", "%#{@genre1_id}%").limit(10)
      else
        @listings_genre1 = []
      end
    else
      @listings_genre1 = []
    end

    if @genre2
      @genre2_id = Genre.find_by(search_name: @genre2)&.genre_id
      puts "Genre 2 ID: #{@genre2_id}"  # Debugging output
      if @genre2_id
        @listings_genre2 = Listing.joins(:game).where("CAST(games.genres AS TEXT) LIKE ?", "%#{@genre2_id}%").limit(10)
      else
        @listings_genre2 = []
      end
    else
      @listings_genre2 = []
    end
  end
end
