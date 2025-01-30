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

    # Fetch two random genres to display on the home page
    genres = Game.pluck(:name).sample(2)

    @genre1 = genres[0]
    @genre2 = genres[1]

    @listings_genre1 = Listing.joins(:game).where('games.genres LIKE ?', "%#{@genre1}%").sample(10)
    @listings_genre2 = Listing.joins(:game).where('games.genres LIKE ?', "%#{@genre2}%").sample(10)
  end
end
