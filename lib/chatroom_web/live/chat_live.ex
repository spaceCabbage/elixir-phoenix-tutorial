defmodule ChatroomWeb.ChatLive do
  use ChatroomWeb, :live_view

  alias Chatroom.Chat

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Chat.subscribe()
    end

    messages = Chat.list_messages()

    {:ok,
     socket
     |> assign(:messages, messages)
     |> assign(:username, "")
     |> assign(:joined, false)
     |> assign(:form, to_form(%{"body" => ""}))}
  end

  @impl true
  def handle_event("join", %{"username" => username}, socket) do
    username = String.trim(username)

    if username != "" do
      {:noreply,
       socket
       |> assign(:username, username)
       |> assign(:joined, true)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("send_message", %{"body" => body}, socket) do
    body = String.trim(body)

    if body != "" do
      Chat.create_message(%{username: socket.assigns.username, body: body})
    end

    {:noreply, assign(socket, :form, to_form(%{"body" => ""}))}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, assign(socket, :messages, socket.assigns.messages ++ [message])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-4 min-h-screen bg-slate-100">
      <h1 class="text-3xl font-bold mb-6 text-center text-slate-800">Chatroom</h1>

      <%= if !@joined do %>
        <!-- Join Form -->
        <div class="bg-white rounded-lg shadow p-6">
          <h2 class="text-xl mb-4 text-slate-700">Enter your username to join</h2>
          <form phx-submit="join" class="flex gap-2">
            <input
              type="text"
              name="username"
              placeholder="Username"
              class="flex-1 border border-slate-300 rounded px-3 py-2 bg-white text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
              maxlength="20"
              autofocus
            />
            <button
              type="submit"
              class="bg-blue-500 text-white px-6 py-2 rounded hover:bg-blue-600 transition"
            >
              Join
            </button>
          </form>
        </div>
      <% else %>
        <!-- Chat Interface -->
        <div class="bg-white rounded-lg shadow">
          <!-- Messages -->
          <div class="h-96 overflow-y-auto p-4 space-y-3" id="messages">
            <%= for message <- @messages do %>
              <div class="flex gap-2 items-baseline" id={"message-#{message.id}"}>
                <span class="font-bold text-blue-600"><%= message.username %>:</span>
                <span class="text-slate-700"><%= message.body %></span>
                <span class="text-xs text-slate-400 ml-auto">
                  <%= Calendar.strftime(message.inserted_at, "%H:%M") %>
                </span>
              </div>
            <% end %>
          </div>

          <!-- Input -->
          <div class="border-t border-slate-200 p-4">
            <.form for={@form} phx-submit="send_message" class="flex gap-2">
              <input
                type="text"
                name="body"
                value={@form[:body].value}
                placeholder="Type a message..."
                class="flex-1 border border-slate-300 rounded px-3 py-2 bg-white text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
                maxlength="500"
                autofocus
                autocomplete="off"
              />
              <button
                type="submit"
                class="bg-blue-500 text-white px-6 py-2 rounded hover:bg-blue-600 transition"
              >
                Send
              </button>
            </.form>
            <p class="text-sm text-slate-500 mt-2">Chatting as <strong class="text-slate-700"><%= @username %></strong></p>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
