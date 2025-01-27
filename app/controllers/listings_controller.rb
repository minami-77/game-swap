class ListingsController < ApplicationController
  def index
    @query = params["name"]
    @listings
    if @query.present?
      search_name = @query.gsub(/[^a-z0-9]/i, '').downcase
      @listings = Listing.joins(:game).where('games.search_name LIKE ?', "%#{search_name}%")
      unless params["platforms"].empty?
        platforms = params["platforms"].split(",").map { |platform| platform.to_i }
        @listings = @listings.joins(:platform).where(platforms: { platform_id: platforms })
      end
    else
      @listings = Listing.all
    end

    puts @listings

    @sort_methods = [
      "Price (low to high)",
      "Price (high to low)",
      # "Location",
      "Maximum rental period",
      # "Owner reviews",
      # "Date posted (newest to oldest)",
      "Rating",
      "Most popular"
    ]

    @filter_methods = [

    ]
  end

  def show
    @listing = Listing.find(params[:id])
    @offer = @listing.offers.new
  end

  def create
    param = params["new_listing"]
    game_name = param[:game_name].gsub(/[^a-z0-9]/i, '').downcase
    game = Game.find_by("search_name ILIKE ?", game_name)

    listing = current_user.listings.new(listing_params)
    listing.game = game
    if listing.save
      redirect_to dashboard_path
    else
      puts listing.errors.full_messages
    end
  end

  def destroy
  end

  def update
  end

  private

  def listing_params
    params.require(:new_listing).permit(:description, :price, :max)
  end
end
