class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    @query = params[:query]
    puts query
    if @query.present?
      @listings = Listing.where('name LIKE ?', "%#{query}%")
    else
      @listings = Listing.all
    end
  end
end
