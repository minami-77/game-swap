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

  async refreshMessages() {
    // These have to all be let otherwise it breaks
    let activeTarget = this.chatsSidebarTarget.querySelector(".active")
    if (activeTarget) {
      let chatId = this.chatsSidebarTarget.querySelector(".active").dataset.id;
      let response = await fetch(`/refresh_messages?id=${chatId}`);
      let data = await response.json();
      this.renderRefresh(data.messages, chatId);
    }
    let response = await fetch(`/get_chats_refresh`);
    let data = await response.json();
    this.refreshChats(data);
  }

  refreshChats(data) {
    console.log(data);

    data.chats.forEach((chat) => {
      const sidebarChat = document.querySelector(`[data-id="${chat.id}"]`);
      sidebarChat.querySelector(".last-message-text-i").innerText = chat.message;
      sidebarChat.querySelector(".last-message-time").innerText = chat.last_message
    })
    const sortedChats = this.sortChats(document.querySelectorAll(".chats-sidebar-btn"));
    sortedChats.forEach(chat => document.querySelector(".chats-sidebar").append(chat));
  }

  sortChats(chats) {
    return [...chats].sort((a, b) => {
      const aTime = a.querySelector(".last-message-time").innerText;
      const bTime = b.querySelector(".last-message-time").innerText;
      return new Date(bTime) - new Date(aTime);
    })
  }

  renderRefresh(data, chatId) {
    // Comparisons to see if a new message has been received
    const messages = document.querySelectorAll(".message-container");
    const newMessage = document.createElement("div");
    newMessage.innerHTML = data;
    const lastMessage = messages[messages.length - 1];
    if (lastMessage.querySelector(".created-at-text").innerText !== newMessage.querySelector(".created-at-text").innerText) {
      this.messagesTarget.insertAdjacentHTML("beforeend", newMessage.innerHTML);
      // this.insertUnreadArrow();
      if (this.observer) {
        this.observer.disconnect();
      }
      // const target = document.querySelector('.messages-section');
      this.observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            // const unreadArrow = document.querySelector(".unread-arrow");
            // if (unreadArrow) unreadArrow.remove();
            this.updateSidebarUnreadMessagesCountOnObserve();
          }
        });
      }, { threshold: 0 })
      const messages = document.querySelectorAll(".message-container");
      this.observer.observe(messages[messages.length - 1]);
    }
  }

  // insertUnreadArrow() {
  //   const unreadArrow = document.createElement("div");
  //   unreadArrow.classList.add("new-message-indicator", "position-absolute")
  //   unreadArrow.innerHTML = `
  //     <button class="" type="button">
  //       <span class="material-symbols-outlined">arrow_downward</span>
  //     </button>
  //   `
  //   this.messagesSectionTarget.append(unreadArrow);
  // }

  async updateSidebarUnreadMessagesCountOnObserve() {
    const active = this.chatsSidebarTarget.querySelector('.active');
    active.querySelector(".sidebar-unread-counter").remove();
    await fetch(`/update_read_on_observe`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify({id: active.dataset.id}),  // Convert data to JSON string
    });
  }

  renderChatsRefresh(data) {
    const chats = document.querySelectorAll(".chats-sidebar-btn")[0];
    const newChatSection = document.createElement("div");
    newChatSection.innerHTML = data;
    if (chats.querySelector(".last-message-time").innerText.trim() !== newChatSection.querySelector(".last-message-time").innerText.trim()) {
      const activeChatId = this.chatsSidebarTarget.querySelector(".active").dataset.id;
      this.chatsSidebarTarget.innerHTML = data;
      document.querySelector(`[data-id="${activeChatId}"]`).classList.add("active");
    }
  }

  async selectChat(event) {
    const activeChat = document.querySelector(".chats-sidebar-btn.active");
    if (activeChat) {
      activeChat.classList.remove("active");
    }
    event.target.closest(".chats-sidebar-btn").classList.add("active");
    const chatId = event.target.closest(".chats-sidebar-btn").dataset.id;

    const response = await fetch(`/get_messages?id=${chatId}`);
    const data = await response.json();
    this.renderMessagesPartial(data.messages, chatId);
    this.updateUnreadMessagesCount();
    this.updateSidebarUnreadMessagesCount(event);
  }

  handleIntersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        console.log("Element is in view");
        // You can trigger other actions here, like adding a class
        this.element.classList.add("in-view");
      }
    });
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
    if (data.unread && unreadCounterElement) {
      unreadCounterElement.innerText = data.unread > 9 ? "9+" : data.unread;
    } else {
      if (unreadCounterElement) {
        unreadCounterElement.closest(".unread-counter-container").remove();
      }
    }
  }

  async newMessage(event) {
    event.preventDefault();
    const chatId = this.chatsSidebarTarget.querySelector(".active").dataset.id;
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
    this.scrollToLastMessage();
    this.messageInputTarget.select();
  }

  async renderChatsPartial(data) {
    const activeChatId = this.chatsSidebarTarget.querySelector(".active").dataset.id;
    this.chatsSidebarTarget.innerHTML = data;

    document.querySelector(`[data-id="${activeChatId}"]`).classList.add("active");
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
