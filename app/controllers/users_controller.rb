class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update]
  def edit
  end

  def update
    if @user.valid_password?(user_params[:current_password])
      if @user.update(user_params.except(:current_password))
        bypass_sign_in(@user)
        redirect_to dashboard_path, notice: 'Your information has been updated successfully.'
      else
        render :edit
      end
    else
      @user.errors.add(:current_password, "is incorrect")
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:photo, :location_address, :current_password)
  end
end
