class ReviewsController < ApplicationController
  def create
    @offer = Offer.find(params[:offer_id])
    @review = Review.new(review_params)
    @review.user = @offer.listing.user
    if @review.save
      flash.now[:notice] = 'Thank you for Rating.'
    else
      puts @review.errors.full_messages
    end
  end

private

  def review_params
    params.require(:review).permit(:rating)
  end

end
