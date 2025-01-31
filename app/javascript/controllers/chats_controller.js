import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chats"
export default class extends Controller {
  static targets = ["messageInput", "messageForm", "messagesSection", "messages", "chatsSidebar", "chats"]

  connect() {
    this.interval = setInterval(() => {
      this.refreshMessages();
    }, 1000);
    const selected_chat = this.chatsSidebarTarget.querySelector(".active");
    if (selected_chat) selected_chat.scrollIntoView({ behaviour: "smooth", block: "start" });
  }

  async selectChat(event) {
    const activeChat = document.querySelector(".active");
    if (activeChat) {
      activeChat.classList.remove("active");
    }
    event.currentTarget.classList.add("active");
    const chatId = event.currentTarget.dataset.id;
    const response = await fetch(`/get_messages?id=${chatId}`);
    const data = await response.json();
    this.renderMessagesPartial(data.messages, chatId);
    this.updateUnreadMessagesCount();
    this.updateSidebarUnreadMessagesCount(event, chatId);
  }

  async updateSidebarUnreadMessagesCount(event, chatId) {
    event.target.querySelector(".sidebar-unread-counter").remove();
  }

  async updateUnreadMessagesCount() {
    const response = await fetch(`/update_unread_messages_in_frontend`);
    const data = await response.json();
    const unreadCounterElement = document.querySelector(".unread-counter");
    unreadCounterElement.innerText = data.unread;
  }

  async refreshMessages() {
    if (document.querySelector(".active").dataset.id) {
      const chatId = document.querySelector(".active").dataset.id;
      const response = await fetch(`/refresh_messages?id=${chatId}`);
      const data = await response.json();
      this.renderRefresh(data.messages, chatId);
      this.renderChatsRefresh(data.chats, chatId);
    }
  }

  renderChatsRefresh(data, chatId) {
    const chats = document.querySelectorAll(".chats-sidebar-btn")[0];
    const newChatSection = document.createElement("div");
    newChatSection.innerHTML = data;
    if (chats.querySelector(".last-message-time").innerText.trim() !== newChatSection.querySelector(".last-message-time").innerText.trim()) {
      const activeChatId = document.querySelector(".active").dataset.id;
      this.chatsSidebarTarget.innerHTML = data;
      document.querySelector(`[data-id="${activeChatId}"]`).classList.add("active");
    }
  }

  renderRefresh(data, chatId) {
    // Comparisons to see if a new message has been received
    const messages = document.querySelectorAll(".message-container");
    const newMessage = document.createElement("div");
    newMessage.innerHTML = data;
    const lastMessage = messages[messages.length - 1];
    if (lastMessage.querySelector(".created-at-text").innerText !== newMessage.querySelector(".created-at-text").innerText) {
      this.messagesTarget.insertAdjacentHTML("beforeend", newMessage.innerHTML);
    }
  }

  async newMessage(event, chatId) {
    event.preventDefault();
    const params = { id: chatId, message: this.messageInputTarget.value }
    const response = await fetch(`/new_message`, {
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify(params)
    });
    const data = await response.json();
    this.renderMessagesPartial(data.messages, chatId);
    this.renderChatsPartial(data.chats, chatId);
  }

  async renderMessagesPartial(data, chatId) {
    this.messagesSectionTarget.innerHTML = data;
    this.messageFormTarget.addEventListener("submit", (event) => this.newMessage(event, chatId))
    this.scrollToLastMessage();
    this.messageInputTarget.select();
  }

  async renderChatsPartial(data) {
    const activeChatId = document.querySelector(".active").dataset.id;
    this.chatsSidebarTarget.innerHTML = data;

    document.querySelector(`[data-id="${activeChatId}"]`).classList.add("active");

    // const selected_chat = this.chatsSidebarTarget.querySelector(".chats-sidebar-btn");
    // selected_chat.classList.add("active");
  }

  scrollToLastMessage() {
    const lastMessage = this.messagesTarget.lastElementChild;
    if (lastMessage) {
      lastMessage.scrollIntoView();
    }
  }

  disconnect() {
    clearInterval(this.interval);
  }
}
