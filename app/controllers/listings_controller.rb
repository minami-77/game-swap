class ListingsController < ApplicationController
  def index
    @query = params["name"]
    @listings

    if @query.present?
      search_name = @query.gsub(/[^a-z0-9]/i, '').downcase
      @listings = Listing.joins(:game)
        .where('games.search_name LIKE ?', "%#{search_name}%")
        .where.not(user_id: current_user.id)
    else
      @listings = Listing.all
        .where.not(user_id: current_user.id)
    end
    @listings = filter_checks(params, @listings)
    @listings = @listings.limit(30)

    @platform_checkboxes = get_platform_checkboxes

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

  def filter_checks(params, listings)
    listings = platform_check(params, listings)
    listings = distance_check(params, listings)
    return listings
  end

  def distance_check(params, listings)
    locations = Location.near(current_user.location.address, params["distance"], order: false)
    location_ids = locations.pluck(:id)
    listings = listings.joins(user: :location).where(users: { location_id: location_ids })
    return listings
  end

  def platform_check(params, listings)
    if params["platforms"]
      unless params["platforms"].empty?
        platforms = params["platforms"].split(",").map { |platform| platform.to_i }
        return listings = listings.joins(:platform).where(platforms: { platform_id: platforms })
      end
    end
    return listings
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

    platform = Platform.find_by(name: param["platform"])
    listing.platform_id = platform.id

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

  def get_platform_checkboxes
    # The fields here do not reflect what is in the database. They reflect what is in the input attributes
    return [
      {
        platform: "PS5",
        name: "167",
        id: "playstation5"
      },
      {
        platform: "Xbox Series X|S",
        name: "169",
        id: "xboxseriesxs"
      },
      {
        platform: "Nintendo Switch",
        name: "130",
        id: "nintendoswitch"
      },
      {
        platform: "PC (Microsoft Windows)",
        name: "6",
        id: "pcmicrosoftwindows"
      },
      {
        platform: "PS4",
        name: "48",
        id: "playstation4"
      },
      {
        platform: "Xbox One",
        name: "49",
        id: "xboxone"
      }
    ]
  end
end
