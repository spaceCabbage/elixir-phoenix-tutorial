# Endpoint

The Endpoint is Phoenix's front door. Every HTTP request enters through it.

---

## What the Endpoint Does

1. Starts the web server (Bandit/Cowboy)
2. Configures the plug pipeline
3. Handles static file serving
4. Sets up WebSocket connections
5. Manages sessions and security

---

## Anatomy of an Endpoint

```elixir
# lib/chatroom_web/endpoint.ex
defmodule ChatroomWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chatroom

  # WebSocket configuration for LiveView
  @session_options [
    store: :cookie,
    key: "_chatroom_key",
    signing_salt: "abc123...",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  # Serve static files from priv/static
  plug Plug.Static,
    at: "/",
    from: :chatroom,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Code reloading in dev
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  # Request logging
  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # Parse request bodies
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  # HTTP method override (for PUT/DELETE from forms)
  plug Plug.MethodOverride

  # Normalize headers
  plug Plug.Head

  # Session handling
  plug Plug.Session, @session_options

  # Finally, send to router
  plug ChatroomWeb.Router
end
```

---

## Plug Pipeline

Requests flow through plugs in order:

```
Request
   │
   ▼
Plug.Static ──→ Serves /assets, /images, etc.
   │              (if matched, stops here)
   ▼
Plug.RequestId ──→ Adds unique ID to each request
   │
   ▼
Plug.Telemetry ──→ Emits metrics events
   │
   ▼
Plug.Parsers ──→ Parses JSON, form data
   │
   ▼
Plug.MethodOverride ──→ Converts _method=PUT to PUT
   │
   ▼
Plug.Head ──→ Converts HEAD to GET
   │
   ▼
Plug.Session ──→ Loads/saves session data
   │
   ▼
Router ──→ Routes to controller/LiveView
```

---

## Static Files

```elixir
plug Plug.Static,
  at: "/",                    # URL path
  from: :chatroom,            # App name (uses priv/static)
  gzip: false,                # Serve .gz versions in prod
  only: ~w(assets fonts images favicon.ico robots.txt)
```

Files in `priv/static/` are served directly:

- `priv/static/images/logo.png` → `/images/logo.png`
- `priv/static/assets/app.js` → `/assets/app.js`

---

## WebSocket Configuration

LiveView uses WebSockets:

```elixir
socket "/live", Phoenix.LiveView.Socket,
  websocket: [connect_info: [session: @session_options]]
```

This means:

- WebSocket connections to `/live` use `Phoenix.LiveView.Socket`
- Session data is available in LiveView `mount/3`

---

## Session Options

```elixir
@session_options [
  store: :cookie,              # Where to store (cookie, ets, etc.)
  key: "_chatroom_key",        # Cookie name
  signing_salt: "abc123...",   # For signing (security)
  same_site: "Lax"             # CSRF protection
]
```

The signing salt is generated when you create the project. Keep it secret in production!

---

## Development Features

Only in dev mode:

```elixir
if code_reloading? do
  # Live reload when files change
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader

  # Recompile on request
  plug Phoenix.CodeReloader
end
```

In production, these are skipped.

---

## Endpoint Configuration

In `config/dev.exs`:

```elixir
config :chatroom, ChatroomWeb.Endpoint,
  # Server settings
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,

  # Debug settings
  debug_errors: true,
  code_reloader: true,

  # Live reload patterns
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/chatroom_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]
```

In `config/prod.exs`:

```elixir
config :chatroom, ChatroomWeb.Endpoint,
  url: [host: "example.com", port: 443, scheme: "https"],
  cache_static_manifest: "priv/static/cache_manifest.json"
```

---

## Accessing Endpoint

```elixir
# Get the configured URL
ChatroomWeb.Endpoint.url()
# "http://localhost:4000"

# Get struct URL
ChatroomWeb.Endpoint.struct_url()
# %URI{host: "localhost", port: 4000, scheme: "http"}

# Check if server is running
ChatroomWeb.Endpoint.server?()
# true

# Get config
ChatroomWeb.Endpoint.config(:http)
# [ip: {127, 0, 0, 1}, port: 4000]
```

---

## Custom Plugs

You can add your own plugs:

```elixir
# After session, before router
plug Plug.Session, @session_options
plug ChatroomWeb.Plugs.LoadUser    # Your custom plug
plug ChatroomWeb.Router
```

A simple plug:

```elixir
# lib/chatroom_web/plugs/load_user.ex
defmodule ChatroomWeb.Plugs.LoadUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      user = Chatroom.Accounts.get_user(user_id)
      assign(conn, :current_user, user)
    else
      conn
    end
  end
end
```

---

## Try It

```elixir
iex> ChatroomWeb.Endpoint.url()
"http://localhost:4000"

iex> ChatroomWeb.Endpoint.config(:http)

# See the endpoint in supervision tree
iex> Supervisor.which_children(Chatroom.Supervisor)
# Look for ChatroomWeb.Endpoint

# Check what server is running
iex> Application.get_env(:chatroom, ChatroomWeb.Endpoint)[:server]
```

---

## Key Takeaways

1. **Endpoint is the HTTP entry point** - All requests start here
2. **Plugs process in order** - Pipeline of transformations
3. **Static files bypass router** - Served directly
4. **WebSockets configured here** - For LiveView and channels
5. **Dev features conditional** - Live reload only in dev
6. **Config in config/\*.exs** - Different per environment

---

**Next:** [Router →](./03-router.md)
