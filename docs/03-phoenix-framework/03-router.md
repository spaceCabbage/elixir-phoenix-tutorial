# Router

The Router matches URLs to controllers or LiveViews and applies pipelines of plugs.

---

## Basic Routing

```elixir
# lib/chatroom_web/router.ex
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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatroomWeb do
    pipe_through :browser

    live "/", ChatLive
  end
end
```

---

## Routes

### LiveView Routes

```elixir
live "/chat", ChatLive                    # Mount LiveView
live "/chat/:room_id", ChatLive           # With URL parameter
live "/chat", ChatLive, :index            # With action (live_action)
```

### Controller Routes

```elixir
get "/about", PageController, :about      # GET /about → PageController.about
post "/login", SessionController, :create
put "/users/:id", UserController, :update
delete "/users/:id", UserController, :delete
```

### Resources (RESTful)

```elixir
resources "/users", UserController
# Creates:
#   GET    /users          → index
#   GET    /users/new      → new
#   POST   /users          → create
#   GET    /users/:id      → show
#   GET    /users/:id/edit → edit
#   PUT    /users/:id      → update
#   DELETE /users/:id      → delete

# Limit actions
resources "/posts", PostController, only: [:index, :show]
resources "/comments", CommentController, except: [:delete]
```

### Nested Resources

```elixir
resources "/users", UserController do
  resources "/posts", PostController
end
# Creates: /users/:user_id/posts/:id
```

---

## Pipelines

Pipelines are groups of plugs that process requests:

```elixir
pipeline :browser do
  plug :accepts, ["html"]           # Accept HTML
  plug :fetch_session               # Load session
  plug :fetch_live_flash            # Flash messages for LiveView
  plug :put_root_layout, html: {ChatroomWeb.Layouts, :root}
  plug :protect_from_forgery        # CSRF protection
  plug :put_secure_browser_headers  # Security headers
end

pipeline :api do
  plug :accepts, ["json"]           # Accept JSON only
end

pipeline :authenticated do
  plug ChatroomWeb.Plugs.RequireAuth
end
```

### Using Pipelines

```elixir
scope "/", ChatroomWeb do
  pipe_through :browser  # All routes use browser pipeline
  # ...
end

scope "/api", ChatroomWeb.Api do
  pipe_through :api  # All routes use api pipeline
  # ...
end

scope "/admin", ChatroomWeb.Admin do
  pipe_through [:browser, :authenticated]  # Multiple pipelines
  # ...
end
```

---

## Scopes

Scopes group routes with common prefixes and modules:

```elixir
# All routes prefixed with /admin
# All controllers in ChatroomWeb.Admin namespace
scope "/admin", ChatroomWeb.Admin do
  pipe_through [:browser, :authenticated]

  live "/dashboard", DashboardLive
  resources "/users", UserController
end

# API routes
scope "/api", ChatroomWeb.Api, as: :api do
  pipe_through :api

  resources "/messages", MessageController, only: [:index, :create]
end
```

---

## Path Helpers

Phoenix generates helper functions for routes:

```elixir
# In router
live "/chat", ChatLive
resources "/users", UserController

# Generated helpers
~p"/chat"                        # "/chat"
~p"/users"                       # "/users"
~p"/users/#{user}"               # "/users/123"
~p"/users/#{user}/edit"          # "/users/123/edit"
```

In templates:

```heex
<.link navigate={~p"/chat"}>Chat</.link>
<.link href={~p"/users/#{@user}"}>Profile</.link>
```

---

## Viewing Routes

```bash
mix phx.routes
```

Output:

```
  GET  /                                      ChatroomWeb.ChatLive :index
  GET  /users                                 ChatroomWeb.UserController :index
  GET  /users/:id                             ChatroomWeb.UserController :show
  ...
```

In IEx:

```elixir
iex> ChatroomWeb.Router.__routes__()
```

---

## Live Routes with Actions

```elixir
live "/posts", PostLive.Index, :index
live "/posts/new", PostLive.Index, :new
live "/posts/:id/edit", PostLive.Index, :edit
live "/posts/:id", PostLive.Show, :show
```

In LiveView, access via `socket.assigns.live_action`:

```elixir
def mount(_params, _session, socket) do
  {:ok, socket}
end

def handle_params(params, _url, socket) do
  {:noreply, apply_action(socket, socket.assigns.live_action, params)}
end

defp apply_action(socket, :index, _params) do
  assign(socket, :page_title, "All Posts")
end

defp apply_action(socket, :new, _params) do
  assign(socket, :page_title, "New Post")
end

defp apply_action(socket, :edit, %{"id" => id}) do
  post = Blog.get_post!(id)
  assign(socket, :page_title, "Edit Post", post: post)
end
```

---

## Forward

Send requests to another plug or router:

```elixir
# Forward all /admin/* to AdminRouter
forward "/admin", AdminRouter

# Forward to a plug (like Phoenix LiveDashboard)
forward "/dashboard", Phoenix.LiveDashboard,
  metrics: ChatroomWeb.Telemetry
```

---

## This Codebase

```elixir
# lib/chatroom_web/router.ex
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

    live "/", ChatLive
  end
end
```

Simple: One route that serves the chat interface at `/`.

---

## Try It

```bash
# See all routes
mix phx.routes

# In IEx
iex> ChatroomWeb.Router.__routes__()
```

Add a new route:

```elixir
scope "/", ChatroomWeb do
  pipe_through :browser

  live "/", ChatLive
  get "/about", PageController, :about  # Add this
end
```

Then create `lib/chatroom_web/controllers/page_controller.ex`:

```elixir
defmodule ChatroomWeb.PageController do
  use ChatroomWeb, :controller

  def about(conn, _params) do
    render(conn, :about)
  end
end
```

---

## Key Takeaways

1. **Routes match URLs** - `live`, `get`, `post`, `resources`
2. **Pipelines group plugs** - `:browser`, `:api`, custom
3. **Scopes group routes** - Common prefix and module
4. **Path helpers via `~p`** - Type-safe URL generation
5. **`mix phx.routes`** - See all routes
6. **LiveView actions** - Handle multiple views in one LiveView

---

**Next:** [Controllers →](./04-controllers.md)
