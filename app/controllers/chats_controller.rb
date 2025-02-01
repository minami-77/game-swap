class ChatsController < ApplicationController
  def index
    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
    .order(last_message: :desc)

    # The below is for when someone clicks on the "chat with person" button on the offers acceptance page and gets redirected to the chats page
    # This will allow for the chat messages to be immediately shown and the chat selected on the sidebar
    @selected_chat_id = session[:selected_chat]
    session.delete(:selected_chat)
    @messages
    if @selected_chat_id
      @messages = Chat.find(@selected_chat_id).messages.order(created_at: :asc)
    end
  end

  def update_unread_messages_in_frontend
    @chats = Chat.where(first_user_id: current_user.id)
    .or(Chat.where(second_user_id: current_user.id))

    @unread_messages_count = 0
    @chats.each do |chat|
      @unread_messages_count += chat.messages.where.not(user: current_user).where(read: false).count
    end
    render json: { unread: @unread_messages_count }
  end

  def get_messages
    id = params[:id]
    @messages = Chat.find(id).messages.order(created_at: :asc)
    message_partial = render_to_string(partial: "chats/messages", locals: { messages: @messages })

    update_read(@messages)
    render json: { messages: message_partial }
  end

  def new_message
    chat_id = params[:id]
    @chat = Chat.find(chat_id)
    new_message = @chat.messages.create!(
      message: params[:message],
      user: current_user
    )

    @chat.update(last_message: new_message.created_at)
    @messages = @chat.messages.order(created_at: :asc)

    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)

    message_partial = render_to_string(partial: "chats/messages", locals: { messages: @messages })
    chats_partial = render_to_string(partial: "chats/chats", locals: { chats: @chats })

    render json: { chats: chats_partial, messages: message_partial }
    # render partial: "chats/messages", locals: { chat: @messages }
  end

  def refresh_messages
    chat_id = params[:id]
    @chat = Chat.find(chat_id)
    @message = @chat.messages.order(created_at: :asc).last

    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)

    message_partial = render_to_string(partial: "chats/new_message", locals: { messages: @message })
    chats_partial = render_to_string(partial: "chats/chats", locals: { chats: @chats })

    render json: { chats: chats_partial, messages: message_partial }
  end

  def get_chats
    @chats = Chat.where(first_user_id: current_user.id).or(
      Chat.where(second_user_id: current_user.id)
    )
      .order(last_message: :desc)
    render partial: "chats/chats", locals: { chat: @chats }
  end

  def update_read(messages)
    @other_user_messages = messages.where.not(user: current_user)
    @other_user_messages.update_all(read: true)
  end

  def new_chat
    second_user_id = params[:id]
    @existing_chat = Chat.where(first_user_id: current_user.id, second_user_id: second_user_id)
      .or(Chat.where(second_user_id: current_user.id, first_user_id: second_user_id))
    if !@existing_chat.exists?
      new_chat = Chat.create(first_user_id: current_user.id, second_user_id:)
      new_chat.update(last_message: new_chat.created_at)
      session[:selected_chat] = new_chat.id
      redirect_to chats_path
    else
      @existing_chat[0].messages.where.not(user: current_user).update_all(read: true)
      session[:selected_chat] = @existing_chat[0].id
      redirect_to chats_path
    end
  end
end
