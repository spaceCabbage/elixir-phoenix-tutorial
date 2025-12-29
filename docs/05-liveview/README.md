# LiveView

LiveView enables rich, real-time user experiences with server-rendered HTML. No JavaScript required for most features.

---

## What You'll Learn

| File                                     | Topic             | Key Concepts                    |
| ---------------------------------------- | ----------------- | ------------------------------- |
| [01. How It Works](./01-how-it-works.md) | The magic         | WebSocket, diffing, state       |
| [02. Lifecycle](./02-lifecycle.md)       | Callbacks         | mount, render, handle_event     |
| [03. Events](./03-events.md)             | User interaction  | phx-click, phx-change, JS hooks |
| [04. PubSub](./04-pubsub.md)             | Real-time updates | Broadcasting, subscribing       |
| [05. Components](./05-components.md)     | Reusable UI       | Function & stateful components  |
| [06. Forms](./06-forms.md)               | Form handling     | Validation, changesets          |

---

## What is LiveView?

LiveView is a Phoenix feature that allows you to build interactive, real-time web UIs without writing JavaScript.

### Traditional Web Apps

```
User clicks → Browser sends HTTP request → Server renders new page → Full page reload
```

### LiveView

```
User clicks → WebSocket sends event → Server updates state → Server sends HTML diff → DOM updates
```

---

## Why LiveView?

| Feature             | Traditional     | SPA (React/Vue)  | LiveView |
| ------------------- | --------------- | ---------------- | -------- |
| Real-time updates   | Polling/refresh | WebSocket + JS   | Built-in |
| JavaScript required | Minimal         | Heavy            | Minimal  |
| SEO                 | Easy            | Hard             | Easy     |
| First paint         | Fast            | Slow (JS bundle) | Fast     |
| Complexity          | Low             | High             | Low      |
| State management    | Server          | Client (Redux)   | Server   |

---

## The Chat App

This codebase is a LiveView app. Look at `lib/chatroom_web/live/chat_live.ex`:

```elixir
defmodule ChatroomWeb.ChatLive do
  use ChatroomWeb, :live_view

  alias Chatroom.Chat

  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe()

    messages = Chat.list_messages()
    {:ok, assign(socket, messages: messages, form: to_form(%{}))}
  end

  def handle_event("send_message", %{"body" => body}, socket) do
    case Chat.create_message(%{username: socket.assigns.username, body: body}) do
      {:ok, _message} -> {:noreply, assign(socket, form: to_form(%{}))}
      {:error, _} -> {:noreply, socket}
    end
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, &(&1 ++ [message]))}
  end

  def render(assigns) do
    ~H"""
    <div class="chat-container">
      <div :for={msg <- @messages}>
        <strong><%= msg.username %>:</strong> <%= msg.body %>
      </div>

      <.simple_form for={@form} phx-submit="send_message">
        <.input field={@form[:body]} placeholder="Type a message..." />
        <.button>Send</.button>
      </.simple_form>
    </div>
    """
  end
end
```

Everything is server-side. The form submits via WebSocket. New messages appear instantly via PubSub.

---

## The Socket

LiveView uses a `socket` instead of `conn`:

```elixir
# Controller (conn)
def show(conn, %{"id" => id}) do
  user = get_user!(id)
  render(conn, :show, user: user)
end

# LiveView (socket)
def mount(%{"id" => id}, _session, socket) do
  user = get_user!(id)
  {:ok, assign(socket, user: user)}
end
```

The socket holds state that persists across interactions.

---

## Prerequisites

Before starting:

1. Complete [Phoenix Framework](../03-phoenix-framework/)
2. Understand [HEEx templates](../03-phoenix-framework/06-templates.md)
3. Have the chat app running

---

## Time Estimate

- **Quick pass**: 1-2 hours
- **Thorough study**: 2-3 hours
- **Building features**: Practice time

---

## Key Files to Reference

| File                                                                           | Purpose             |
| ------------------------------------------------------------------------------ | ------------------- |
| [lib/chatroom_web/live/chat_live.ex](../../lib/chatroom_web/live/chat_live.ex) | Main LiveView       |
| [lib/chatroom/chat.ex](../../lib/chatroom/chat.ex)                             | Context with PubSub |

---

**Start:** [How It Works →](./01-how-it-works.md)
