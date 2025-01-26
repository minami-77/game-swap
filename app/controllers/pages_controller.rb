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

    @query = params.dig(:search, :query)
    if @query.present?
      normalized_query = @query.gsub(/[^a-z0-9]/i, '').downcase
      @listings = Listing.joins(:game).where('games.search_name LIKE ?', "%#{normalized_query}%")
    else
      @listings = Listing.all
    end
  end
end
