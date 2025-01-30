class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :unread_messages_counter


  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :username])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :username])
  end

  def unread_messages_counter
    return if !current_user

    @chats = Chat.where(first_user_id: current_user.id)
      .or(Chat.where(second_user_id: current_user.id))

    @unread_messages_count = 0
    @chats.each do |chat|
      @unread_messages_count += chat.messages.where.not(user: current_user).where(read: false).count
    end
  end
end
