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

  # Step 1: Randomly select two genres
  @selected_genres = Genre.order("RANDOM()").limit(2)
  @selected_genre1, @selected_genre2 = @selected_genres

  # Step 2: Retrieve games that contain the genre_id in the string format
  @games_genre1 = Game.where("genres LIKE ?", "%#{@selected_genre1.genre_id}%")
  @games_genre2 = Game.where("genres LIKE ?", "%#{@selected_genre2.genre_id}%")

  # Step 3: Filter only the games that are in listings
  @listings_genre1 = Listing.includes(:game).where(game_id: @games_genre1.pluck(:id))
  @listings_genre2 = Listing.includes(:game).where(game_id: @games_genre2.pluck(:id))

  def prepare_carousel(listings)
    groups = listings.in_groups_of(6, false)

    groups.each do |group|
      while group.size < 6
        group << listings[group.size % listings.size] if listings.any?
      end
    end
  end

  # Step 4: Organize listings into groups of 6 for the carousel
  @carousel_groups_genre1 = prepare_carousel(@listings_genre1)
  @carousel_groups_genre2 = prepare_carousel(@listings_genre2)

  # Step 5: Filter out genres with no listings
  @valid_carousels = []
  @valid_carousels << { genre: @selected_genres.first, groups: @carousel_groups_genre1 } unless @carousel_groups_genre1.empty?
  @valid_carousels << { genre: @selected_genres.last, groups: @carousel_groups_genre2 } unless @carousel_groups_genre2.empty?
  end
end
