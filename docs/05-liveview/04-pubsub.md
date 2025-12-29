# PubSub

Phoenix PubSub enables real-time features by broadcasting messages to all subscribers.

---

## How It Works

```
User A sends message
        │
        ▼
  Chat.create_message()
        │
        ▼
  PubSub.broadcast("chat:lobby", {:new_message, msg})
        │
        ├──────────────────────────────┐
        ▼                              ▼
  User A LiveView              User B LiveView
  handle_info({:new_message})  handle_info({:new_message})
        │                              │
        ▼                              ▼
  UI updates                    UI updates
```

---

## Setup

Phoenix includes PubSub. It's started in your application supervisor:

```elixir
# lib/chatroom/application.ex
children = [
  # ...
  {Phoenix.PubSub, name: Chatroom.PubSub},
  # ...
]
```

---

## Basic Usage

### Subscribe

```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(Chatroom.PubSub, "chat:lobby")
  end

  {:ok, socket}
end
```

### Broadcast

```elixir
Phoenix.PubSub.broadcast(Chatroom.PubSub, "chat:lobby", {:new_message, message})
```

### Receive

```elixir
def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, &(&1 ++ [message]))}
end
```

---

## This Codebase

### Context (lib/chatroom/chat.ex)

```elixir
defmodule Chatroom.Chat do
  @topic "chat:lobby"

  def subscribe do
    Phoenix.PubSub.subscribe(Chatroom.PubSub, @topic)
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:new_message)
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(Chatroom.PubSub, @topic, {event, message})
    {:ok, message}
  end

  defp broadcast({:error, _} = error, _event), do: error
end
```

### LiveView (lib/chatroom_web/live/chat_live.ex)

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Chat.subscribe()

  messages = Chat.list_messages()
  {:ok, assign(socket, messages: messages)}
end

def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, &(&1 ++ [message]))}
end
```

---

## Dynamic Topics

For per-user or per-room topics:

```elixir
# Subscribe to user-specific topic
def mount(%{"user_id" => user_id}, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(Chatroom.PubSub, "user:#{user_id}")
  end

  {:ok, assign(socket, user_id: user_id)}
end

# Broadcast to specific user
Phoenix.PubSub.broadcast(Chatroom.PubSub, "user:#{user_id}", {:notification, notif})
```

### Chat Rooms Example

```elixir
defmodule Chatroom.Rooms do
  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(Chatroom.PubSub, "room:#{room_id}")
  end

  def unsubscribe(room_id) do
    Phoenix.PubSub.unsubscribe(Chatroom.PubSub, "room:#{room_id}")
  end

  def broadcast_message(room_id, message) do
    Phoenix.PubSub.broadcast(Chatroom.PubSub, "room:#{room_id}", {:new_message, message})
  end
end
```

```elixir
def mount(%{"room_id" => room_id}, _session, socket) do
  if connected?(socket) do
    Rooms.subscribe(room_id)
  end

  {:ok, assign(socket, room_id: room_id, messages: [])}
end

def handle_params(%{"room_id" => new_room_id}, _url, socket) do
  # Switching rooms
  old_room_id = socket.assigns.room_id

  if old_room_id != new_room_id do
    Rooms.unsubscribe(old_room_id)
    Rooms.subscribe(new_room_id)
  end

  {:noreply, assign(socket, room_id: new_room_id, messages: Rooms.list_messages(new_room_id))}
end
```

---

## Common Patterns

### Broadcast from Context

Keep PubSub logic in contexts:

```elixir
defmodule MyApp.Blog do
  @topic "blog:posts"

  def subscribe, do: Phoenix.PubSub.subscribe(MyApp.PubSub, @topic)

  def create_post(attrs) do
    case Repo.insert(Post.changeset(%Post{}, attrs)) do
      {:ok, post} ->
        broadcast({:post_created, post})
        {:ok, post}

      error ->
        error
    end
  end

  def update_post(post, attrs) do
    case Repo.update(Post.changeset(post, attrs)) do
      {:ok, post} ->
        broadcast({:post_updated, post})
        {:ok, post}

      error ->
        error
    end
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(MyApp.PubSub, @topic, message)
  end
end
```

### Handle Multiple Events

```elixir
def handle_info({:post_created, post}, socket) do
  {:noreply, update(socket, :posts, &[post | &1])}
end

def handle_info({:post_updated, post}, socket) do
  {:noreply, update(socket, :posts, fn posts ->
    Enum.map(posts, fn p -> if p.id == post.id, do: post, else: p end)
  end)}
end

def handle_info({:post_deleted, post}, socket) do
  {:noreply, update(socket, :posts, &Enum.reject(&1, fn p -> p.id == post.id end))}
end
```

---

## Presence

For tracking who's online:

```elixir
defmodule ChatroomWeb.Presence do
  use Phoenix.Presence,
    otp_app: :chatroom,
    pubsub_server: Chatroom.PubSub
end
```

```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    {:ok, _} = Presence.track(self(), "room:lobby", socket.assigns.user_id, %{
      online_at: System.system_time(:second),
      username: socket.assigns.username
    })

    Phoenix.PubSub.subscribe(Chatroom.PubSub, "room:lobby")
  end

  users = Presence.list("room:lobby")
  {:ok, assign(socket, users: users)}
end

def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
  {:noreply, assign(socket, users: Presence.list("room:lobby"))}
end
```

---

## Testing PubSub

```elixir
test "broadcasts on message creation" do
  Chat.subscribe()

  {:ok, message} = Chat.create_message(%{username: "test", body: "hello"})

  assert_receive {:new_message, ^message}
end
```

---

## Try It

```elixir
# In IEx with Phoenix running
iex> Chat.subscribe()
:ok

# In another terminal/IEx
iex> Chat.create_message(%{username: "test", body: "Hello!"})

# Back in first terminal - you'll see the message arrive!
```

Open two browser windows:

1. Send a message in one
2. Watch it appear in both instantly!

---

## Key Takeaways

1. **PubSub is built-in** - Part of Phoenix
2. **Subscribe in mount** - Only when `connected?(socket)`
3. **Broadcast from contexts** - Keep logic together
4. **Dynamic topics** - `"room:#{room_id}"`, `"user:#{user_id}"`
5. **`handle_info/2` receives** - Pattern match the message
6. **Presence for online users** - Track who's connected

---

**Next:** [Components →](./05-components.md)
