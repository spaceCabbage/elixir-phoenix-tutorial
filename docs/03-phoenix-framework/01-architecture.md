# Phoenix Architecture

Phoenix follows a layered architecture that keeps concerns separated and code organized.

---

## The Layers

```
┌─────────────────────────────────────────────────────┐
│                      Web Layer                       │
│         (chatroom_web - handles HTTP/WebSocket)      │
├─────────────────────────────────────────────────────┤
│    Endpoint → Router → Controller/LiveView          │
│                   ↓                                 │
│              Templates/Components                    │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                  Business Layer                      │
│            (chatroom - your domain logic)           │
├─────────────────────────────────────────────────────┤
│              Contexts → Schemas                     │
│                   ↓                                 │
│               Repo (Ecto)                           │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                    Database                          │
│               (SQLite in our case)                  │
└─────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
lib/
├── chatroom/                      # Business Layer
│   ├── application.ex             # OTP app startup
│   ├── repo.ex                    # Database connection
│   ├── chat.ex                    # Context: Chat operations
│   └── chat/
│       └── message.ex             # Schema: Message struct + validation
│
├── chatroom_web/                  # Web Layer
│   ├── endpoint.ex                # HTTP entry point
│   ├── router.ex                  # URL → controller/live mapping
│   ├── telemetry.ex               # Metrics
│   │
│   ├── controllers/               # Traditional request/response
│   │   ├── page_controller.ex
│   │   └── page_html.ex
│   │
│   ├── live/                      # Real-time UI
│   │   └── chat_live.ex
│   │
│   ├── components/                # Reusable UI pieces
│   │   ├── core_components.ex
│   │   └── layouts.ex
│   │
│   └── templates/                 # HTML templates
│       └── layouts/
│           ├── app.html.heex
│           └── root.html.heex
│
├── chatroom_web.ex                # Web module helpers
└── chatroom.ex                    # App module helpers
```

---

## Request Lifecycle

### 1. HTTP Request Arrives

```
GET /chat HTTP/1.1
Host: localhost:4000
```

### 2. Endpoint (First Stop)

`lib/chatroom_web/endpoint.ex` processes the request through plugs:

```elixir
# Serve static files
plug Plug.Static, at: "/", from: :chatroom

# Parse body
plug Plug.Parsers

# Session handling
plug Plug.Session

# Finally, send to router
plug ChatroomWeb.Router
```

### 3. Router (Matching)

`lib/chatroom_web/router.ex` matches the URL:

```elixir
scope "/", ChatroomWeb do
  pipe_through :browser

  live "/", ChatLive    # Match "/" to ChatLive
end
```

### 4. LiveView/Controller (Processing)

`lib/chatroom_web/live/chat_live.ex` handles the request:

```elixir
def mount(_params, _session, socket) do
  messages = Chat.list_messages()  # Call context
  {:ok, assign(socket, :messages, messages)}
end
```

### 5. Context (Business Logic)

`lib/chatroom/chat.ex` interacts with data:

```elixir
def list_messages do
  Message
  |> order_by(asc: :inserted_at)
  |> Repo.all()
end
```

### 6. Response

LiveView renders HTML and sends it back (or upgrades to WebSocket).

---

## The Two Namespaces

Phoenix generators create two namespaces:

### `Chatroom` - Business Logic

```elixir
# lib/chatroom.ex
defmodule Chatroom do
  # Boundary module - delegates to contexts
end

# lib/chatroom/chat.ex
defmodule Chatroom.Chat do
  # Chat context - all chat-related operations
end

# lib/chatroom/chat/message.ex
defmodule Chatroom.Chat.Message do
  # Message schema - database mapping
end
```

### `ChatroomWeb` - Web Interface

```elixir
# lib/chatroom_web.ex
defmodule ChatroomWeb do
  # Provides helpers for controllers, views, etc.
end

# lib/chatroom_web/live/chat_live.ex
defmodule ChatroomWeb.ChatLive do
  # Web interface for chat
end
```

---

## Why Separate Web and Business?

| Web Layer                  | Business Layer            |
| -------------------------- | ------------------------- |
| HTTP-specific              | HTTP-agnostic             |
| Handles requests/responses | Handles business rules    |
| Uses conn, sockets         | Uses data structures      |
| Can change presentation    | Core logic stable         |
| Easy to test in isolation  | Easy to test in isolation |

You could have multiple web interfaces (API, admin panel) sharing the same business logic.

---

## The `conn` Struct

Every HTTP request becomes a `%Plug.Conn{}` struct:

```elixir
%Plug.Conn{
  host: "localhost",
  method: "GET",
  path_info: ["chat"],
  params: %{},
  assigns: %{},
  status: nil,
  resp_body: nil,
  ...
}
```

Plugs transform the conn through the pipeline:

```elixir
conn
|> put_session(:user_id, user.id)
|> put_flash(:info, "Welcome!")
|> redirect(to: "/dashboard")
```

---

## Configuration

Phoenix apps configure via `config/`:

```
config/
├── config.exs      # Shared config (imports others)
├── dev.exs         # Development settings
├── test.exs        # Test settings
├── prod.exs        # Production defaults
└── runtime.exs     # Runtime config (env vars)
```

```elixir
# config/dev.exs
config :chatroom, ChatroomWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true

# Access in code
Application.get_env(:chatroom, ChatroomWeb.Endpoint)[:http][:port]
# => 4000
```

---

## Mix Tasks

Phoenix provides helpful mix tasks:

```bash
# Routes
mix phx.routes          # List all routes

# Generators
mix phx.gen.html        # Generate HTML resource
mix phx.gen.json        # Generate JSON API
mix phx.gen.live        # Generate LiveView
mix phx.gen.context     # Generate context
mix phx.gen.schema      # Generate schema only

# Server
mix phx.server          # Start server
iex -S mix phx.server   # Start with IEx

# Digest (production assets)
mix phx.digest          # Compress and tag assets
```

---

## Try It

```elixir
# With server running (iex -S mix phx.server)

# See all routes
iex> ChatroomWeb.Router.__routes__()

# Inspect the endpoint config
iex> Application.get_env(:chatroom, ChatroomWeb.Endpoint)

# See supervision tree
iex> Supervisor.which_children(Chatroom.Supervisor)
```

---

## Key Takeaways

1. **Two namespaces** - `Chatroom` (business) and `ChatroomWeb` (web)
2. **Request flows through**: Endpoint → Router → Controller/LiveView
3. **Contexts separate concerns** - Web layer calls contexts, not Repo
4. **Plugs are composable** - Each transforms the connection
5. **Config in `config/`** - Environment-specific settings

---

**Next:** [Endpoint →](./02-endpoint.md)
