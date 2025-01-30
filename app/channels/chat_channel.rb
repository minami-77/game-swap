class ChatChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    steam_from "chat_#{params[:chat_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
