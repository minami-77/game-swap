class ListingsController < ApplicationController
  def index
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
