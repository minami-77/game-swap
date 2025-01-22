class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    @query = params.dig(:search, :query)
    if @query.present?
      @listings = Listing.joins(:game).where('games.name LIKE ?', "%#{@query}%")
    else
      @listings = Listing.all
    end
  end
end
