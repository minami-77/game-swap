class OffersController < ApplicationController
  def for_listing
    @listing = Listing.find(params[:id])
    @offers = @listing.offers
  end

  def create
    @listing = Listing.find(params[:listing_id])
    @offer = @listing.offers.new(offer_params)
    @offer.user_id = current_user_id
    if @offer.save
      redirect_to listing_path(@listing)
    else
      puts @offer.errors.full_messages
    end
  end

  def destroy
  end

  def update
  end

  private

  def offer_params
    params.require(:offer).permit(:comments)
  end
end
