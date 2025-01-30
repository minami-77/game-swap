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
    # This check is needed for when you do a search on the home page, it shouldn't do any filter checks. Platforms is the arbitrary params to look at, any of the other filter checks can be used
    if params["platforms"]
      @listings = filter_checks(params, @listings)
    end
    @listings = @listings.limit(30)

    # params instance variable is needed to render the view with the selected filters in place
    @params = params

    @platform_checkboxes = get_platform_checkboxes
    @sort_methods = [
      "Price (low to high)",
      "Price (high to low)",
      # "Location",
      "Maximum rental period",
      # "Owner reviews",
      # "Date posted (newest to oldest)",
      # "Rating",
      # "Most popular"
    ]

    @filter_methods = [

    ]
  end

  def filter_checks(params, listings)
    listings = platform_check(params, listings)
    listings = duration_check(params, listings)
    listings = distance_check(params, listings)
    listings = price_check(params, listings)
    return listings
  end

  def duration_check(params, listings)
    min_duration = params["minDuration"] == "" ? 0 : params["minDuration"]
    max_duration = params["maxDuration"] == "" ? 10000000 : params["maxDuration"]
    listings = listings.where("max >= ? AND max <= ?", min_duration, max_duration)
    return listings
  end

  def price_check(params, listings)
    listings = listings.where("price <= ?", params["price"].to_i * 100)
    puts params["price"]
    return listings
  end

  def distance_check(params, listings)
    locations = Location.near(current_user.location.address, params["distance"] ? params["distance"] : 30, order: false)
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
    params.require(:new_listing).permit(:description, :price, :max, photos: [])
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
