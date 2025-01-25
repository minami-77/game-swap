class OffersController < ApplicationController
  def for_listing
    @listing = Listing.find(params[:id])
    @offers = @listing.offers
  end

  def create
  end

  def destroy
  end

  def update
    @offer = Offer.find(params[:id])
    if @offer.update(offer_params)
      redirect_to dashboard_listing_offers_path(@offer.listing)
    else
      render :for_listing
    end
  end

  private

  def offer_params
    params.require(:offer).permit(:status)
  end
end
