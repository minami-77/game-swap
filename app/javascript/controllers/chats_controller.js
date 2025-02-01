import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chats"
export default class extends Controller {
  static targets = ["messageInput", "messageForm", "messagesSection", "messages", "chatsSidebar", "chats"]

  connect() {
    this.interval = setInterval(() => {
      // this.refreshMessages();
    }, 1000);
    const selected_chat = this.chatsSidebarTarget.querySelector(".active");
    if (selected_chat) selected_chat.scrollIntoView({ behaviour: "smooth", block: "start" });
    // if (this.messageFormTarget) {
    //   this.messageFormTarget.addEventListener("submit", (event) => this.newMessage(event, chatId));
    // }
  }

  async selectChat(event) {
    const activeChat = document.querySelector(".chats-sidebar-btn.active");
    if (activeChat) {
      activeChat.classList.remove("active");
    }
    event.currentTarget.classList.add("active");
    const chatId = event.target.closest(".chats-sidebar-btn").dataset.id;

    const response = await fetch(`/get_messages?id=${chatId}`);
    const data = await response.json();
    this.renderMessagesPartial(data.messages, chatId);
    this.updateUnreadMessagesCount();
    this.updateSidebarUnreadMessagesCount(event);
  }

  async updateSidebarUnreadMessagesCount(event) {
    // The conditional is for the edge case where the person clicks on the unread messages counter element instead of the main chats sidebar button element
    const closestUnreadCounter = event.target.closest(".chats-sidebar-btn").querySelector(".sidebar-unread-counter") || event.target.closest(".sidebar-unread-counter");
    if (closestUnreadCounter) {
      if (event.target.classList.contains("unread-counter")) {
        event.target.closest(".sidebar-unread-counter").remove();
      } else {
        event.target.closest(".chats-sidebar-btn").querySelector(".unread-counter").parentElement.remove();
      }
    }
  }

  async updateUnreadMessagesCount() {
    const response = await fetch(`/update_unread_messages_in_frontend`);
    const data = await response.json();
    const unreadCounterElement = document.querySelector(".unread-counter");
    if (data.unread) {
      unreadCounterElement.innerText = data.unread > 9 ? "9+" : data.unread;
    } else {
      if (unreadCounterElement) {
        unreadCounterElement.closest(".unread-counter-container").remove();
      }
    }
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

  async newMessage(event) {
    event.preventDefault();
    const chatId = this.chatsSidebarTarget.querySelector(".active").dataset.id;
    const params = { id: chatId, message: this.messageInputTarget.value }
    console.log(params);

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
    // this.messageFormTarget.addEventListener("submit", (event) => this.newMessage(event, chatId))
    this.scrollToLastMessage();
    this.messageInputTarget.select();
  }

  async renderChatsPartial(data) {
    const activeChatId = this.chatsSidebarTarget.querySelector(".active").dataset.id;
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
