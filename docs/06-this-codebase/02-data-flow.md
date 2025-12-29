# Data Flow

Follow a chat message from the user's keyboard to every connected browser.

---

## The Journey of a Message

```
User types "Hello!" and hits Enter
                |
                v
+---------------------------------------+
| 1. Browser                            |
|    phx-submit="send_message"          |
|    Sends event over WebSocket         |
+---------------------------------------+
                |
                v
+---------------------------------------+
| 2. ChatLive.handle_event/3            |
|    Receives the event                 |
|    Calls Chat.create_message/1        |
+---------------------------------------+
                |
                v
+---------------------------------------+
| 3. Chat.create_message/1              |
|    Creates changeset                  |
|    Inserts into database              |
|    Broadcasts via PubSub              |
+---------------------------------------+
                |
     +----------+-----------+
     |          |           |
     v          v           v
+--------+ +--------+ +--------+
| User A | | User B | | User C |
| handle | | handle | | handle |
| _info  | | _info  | | _info  |
+--------+ +--------+ +--------+
     |          |           |
     v          v           v
+---------------------------------------+
| 4. Each ChatLive updates assigns      |
|    Phoenix diffs the HTML             |
|    Sends minimal patch to browser     |
+---------------------------------------+
                |
                v
+---------------------------------------+
| 5. Browser patches DOM                |
|    User sees the new message          |
+---------------------------------------+
```

---

## Step 1: Browser Event

In the template (`chat_live.ex`):

```heex
<form phx-submit="send_message">
  <input type="text" name="body" />
  <button type="submit">Send</button>
</form>
```

When the form submits:

- Browser doesn't do a page refresh
- Instead, sends `{"event": "send_message", "value": {"body": "Hello!"}}` over WebSocket

---

## Step 2: LiveView Receives Event

```elixir
# lib/chatroom_web/live/chat_live.ex

def handle_event("send_message", %{"body" => body}, socket) do
  Chat.create_message(%{
    username: socket.assigns.username,
    body: body
  })
  {:noreply, socket}
end
```

Notice: we don't update `socket.assigns` here. Why? Because we'll receive the message back via PubSub - this ensures all users (including the sender) get the same update path.

---

## Step 3: Context Creates and Broadcasts

```elixir
# lib/chatroom/chat.ex

def create_message(attrs) do
  %Message{}
  |> Message.changeset(attrs)
  |> Repo.insert()
  |> broadcast(:new_message)
end

defp broadcast({:ok, message}, event) do
  Phoenix.PubSub.broadcast(
    Chatroom.PubSub,     # The PubSub server
    "chat:lobby",        # Topic name
    {event, message}     # The payload
  )
  {:ok, message}
end

defp broadcast({:error, _} = error, _event), do: error
```

Key pattern: `broadcast/2` pattern matches on `{:ok, message}` - if the insert fails, we don't broadcast.

---

## Step 4: All LiveViews Receive Broadcast

Every connected ChatLive process subscribed to "chat:lobby" receives the message:

```elixir
# In mount/3
def mount(_params, _session, socket) do
  if connected?(socket), do: Chat.subscribe()
  # ...
end

# The subscription
def subscribe do
  Phoenix.PubSub.subscribe(Chatroom.PubSub, "chat:lobby")
end

# Handling the broadcast
def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, &(&1 ++ [message]))}
end
```

---

## Step 5: Phoenix Diffs and Patches

When `socket.assigns.messages` changes:

1. Phoenix calls `render/1` to generate new HTML
2. Compares it against the previous HTML
3. Computes the minimal diff
4. Sends only the changed parts over WebSocket
5. Browser applies the patch to the DOM

This is why LiveView feels instant - we're not sending full pages.

---

## The Database Layer

The message goes through Ecto:

```elixir
# Schema defines structure
schema "messages" do
  field :username, :string
  field :body, :string
  timestamps()
end

# Changeset validates
def changeset(message, attrs) do
  message
  |> cast(attrs, [:username, :body])
  |> validate_required([:username, :body])
  |> validate_length(:body, max: 500)
end
```

If validation fails, `Repo.insert()` returns `{:error, changeset}` and we don't broadcast.

---

## The PubSub System

PubSub is started in the supervision tree:

```elixir
# lib/chatroom/application.ex
children = [
  # ...
  {Phoenix.PubSub, name: Chatroom.PubSub},
  # ...
]
```

It's an in-memory pub/sub. For distributed systems, you'd configure a Redis or PostgreSQL adapter.

---

## Try It Yourself

1. Open two browser windows to `localhost:4000`
2. Open IEx and watch the messages:

```elixir
# Subscribe to the topic
Phoenix.PubSub.subscribe(Chatroom.PubSub, "chat:lobby")

# Now send a message from the browser
# You'll see:
receive do
  msg -> IO.inspect(msg)
end
# => {:new_message, %Chatroom.Chat.Message{...}}
```

3. Broadcast a message from IEx:

```elixir
Phoenix.PubSub.broadcast(
  Chatroom.PubSub,
  "chat:lobby",
  {:new_message, %{id: 999, username: "System", body: "Hello from IEx!"}}
)
```

Watch it appear in both browsers!

---

## Key Takeaways

1. **Events flow through WebSocket** - no page refreshes
2. **Context handles business logic** - LiveView just coordinates
3. **PubSub enables real-time** - all subscribers get updates
4. **Diffs minimize bandwidth** - only changes are sent
5. **Pattern matching handles errors** - bad data doesn't broadcast

---

## Next

Continue to [Key Files](03-key-files.md) for a deeper look at the most important files.
