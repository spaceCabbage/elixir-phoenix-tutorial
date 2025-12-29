# Key Files Deep Dive

A closer look at the most important files in the codebase.

---

## `lib/chatroom/application.ex`

The OTP Application - everything starts here.

```elixir
defmodule Chatroom.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChatroomWeb.Telemetry,
      Chatroom.Repo,
      {DNSCluster, query: Application.get_env(:chatroom, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chatroom.PubSub},
      ChatroomWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Chatroom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChatroomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
```

### Key Points

1. **`use Application`** - This module IS your application
2. **`children`** - Processes that start when the app boots
3. **`:one_for_one`** - Restart strategy: if one child crashes, only restart that one
4. **Order matters** - Repo starts before Endpoint (database before web server)

### The Supervision Tree

```
Chatroom.Supervisor
    |
    +-- Telemetry (metrics)
    +-- Repo (database pool)
    +-- DNSCluster (optional clustering)
    +-- PubSub (message broadcasting)
    +-- Endpoint (HTTP server)
```

Try it:

```elixir
:observer.start()  # Opens GUI showing all processes
```

---

## `lib/chatroom/chat.ex`

The Context - your public API for chat functionality.

```elixir
defmodule Chatroom.Chat do
  import Ecto.Query, warn: false
  alias Chatroom.Repo
  alias Chatroom.Chat.Message

  def list_messages do
    Message
    |> order_by(desc: :inserted_at)
    |> limit(50)
    |> Repo.all()
    |> Enum.reverse()
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:new_message)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Chatroom.PubSub, "chat:lobby")
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(Chatroom.PubSub, "chat:lobby", {event, message})
    {:ok, message}
  end

  defp broadcast({:error, _changeset} = error, _event), do: error
end
```

### Key Points

1. **Public API** - `list_messages`, `create_message`, `subscribe`
2. **Composable queries** - `|> order_by |> limit |> Repo.all`
3. **Pattern matching on results** - `{:ok, message}` vs `{:error, changeset}`
4. **PubSub integration** - Broadcasting after successful insert

### Why Contexts?

Contexts create boundaries. If you later add authentication:

```elixir
# Bad - web layer knows about database
def handle_event("send", _, socket) do
  Repo.insert(Message.changeset(...))  # Don't do this
end

# Good - web layer uses context
def handle_event("send", _, socket) do
  Chat.create_message(...)  # Context handles the details
end
```

---

## `lib/chatroom/chat/message.ex`

The Schema - your data structure and validation.

```elixir
defmodule Chatroom.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :username, :string
    field :body, :string
    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:username, :body])
    |> validate_required([:username, :body])
    |> validate_length(:body, min: 1, max: 500)
    |> validate_length(:username, min: 1, max: 50)
  end
end
```

### Key Points

1. **`schema "messages"`** - Maps to the `messages` database table
2. **`timestamps()`** - Adds `inserted_at` and `updated_at`
3. **`cast/3`** - Whitelists allowed fields from external input
4. **Validations** - Run before database insert

### Try It

```elixir
alias Chatroom.Chat.Message

# Valid changeset
cs = Message.changeset(%Message{}, %{username: "test", body: "hello"})
cs.valid?  # => true

# Invalid changeset
cs = Message.changeset(%Message{}, %{username: "", body: ""})
cs.valid?  # => false
cs.errors  # => [username: {"can't be blank", ...}, body: {...}]
```

---

## `lib/chatroom_web/live/chat_live.ex`

The LiveView - real-time UI.

```elixir
defmodule ChatroomWeb.ChatLive do
  use ChatroomWeb, :live_view

  alias Chatroom.Chat

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe()

    {:ok,
     socket
     |> assign(:messages, Chat.list_messages())
     |> assign(:username, nil)
     |> assign(:form, to_form(%{"body" => ""}))}
  end

  @impl true
  def handle_event("join", %{"username" => username}, socket) do
    {:noreply, assign(socket, :username, username)}
  end

  @impl true
  def handle_event("send_message", %{"body" => body}, socket) do
    Chat.create_message(%{
      username: socket.assigns.username,
      body: body
    })
    {:noreply, assign(socket, :form, to_form(%{"body" => ""}))}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, &(&1 ++ [message]))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <%= if @username do %>
        <div class="messages">
          <%= for message <- @messages do %>
            <div class="message">
              <strong><%= message.username %>:</strong>
              <%= message.body %>
            </div>
          <% end %>
        </div>

        <.form for={@form} phx-submit="send_message">
          <input type="text" name="body" placeholder="Type a message..." />
          <button type="submit">Send</button>
        </.form>
      <% else %>
        <.form for={%{}} phx-submit="join">
          <input type="text" name="username" placeholder="Enter username" />
          <button type="submit">Join Chat</button>
        </.form>
      <% end %>
    </div>
    """
  end
end
```

### Key Points

1. **`mount/3`** - Initial setup, runs twice (static HTML, then WebSocket)
2. **`connected?(socket)`** - Only subscribe when WebSocket is connected
3. **`handle_event/3`** - User interactions (button clicks, form submits)
4. **`handle_info/2`** - Messages from other processes (PubSub broadcasts)
5. **`~H"..."`** - HEEx template syntax

### The Lifecycle

```
Browser requests page
        |
        v
    mount/3 (connected? = false)
        |
        v
    render/1 -> HTML sent to browser
        |
        v
    Browser loads JS, opens WebSocket
        |
        v
    mount/3 (connected? = true)
        |
        v
    Chat.subscribe()
        |
        v
    User interacts -> handle_event/3
        |
        v
    PubSub message -> handle_info/2
        |
        v
    assigns change -> render/1 -> diff sent
```

---

## `lib/chatroom_web/router.ex`

URL routing.

```elixir
defmodule ChatroomWeb.Router do
  use ChatroomWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChatroomWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ChatroomWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/chat", ChatLive
  end
end
```

### Key Points

1. **Pipelines** - Middleware stacks
2. **`pipe_through`** - Apply a pipeline to routes
3. **`get`** - Traditional controller route
4. **`live`** - LiveView route

---

## Next

Continue to [Exercises](04-exercises.md) for hands-on practice.
