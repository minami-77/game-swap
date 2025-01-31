class ReviewsController < ApplicationController
  def create
    # Find the offer made by the borrower
    @offer = Offer.find(params[:review][:offer_id])
    @review = Review.new(review_params)
    # Associate the review with the offer
    @review.offer_id = @offer.id
    # Associate the review with the owner
    @review.user = @offer.listing.user
    if @review.save
      render turbo_stream: turbo_stream.update('flash', partial: 'shared/flashes')
      # flash.now[:notice] = 'Thank you for Rating.'
      # redirect_to dashboard_path, notice: 'Thank you for Rating.'
    else
      puts @review.errors.full_messages
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating)
  end

end
