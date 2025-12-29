# Controllers

Controllers handle HTTP requests and return responses. They're the traditional request/response pattern (as opposed to LiveView's real-time approach).

---

## Basic Controller

```elixir
defmodule ChatroomWeb.PageController do
  use ChatroomWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def show(conn, %{"id" => id}) do
    page = Content.get_page!(id)
    render(conn, :show, page: page)
  end
end
```

### The Pattern

1. Receive `conn` (connection) and `params`
2. Do something (usually call a context)
3. Return a response (render, redirect, or send)

---

## Actions

Each public function is an action:

```elixir
defmodule ChatroomWeb.UserController do
  use ChatroomWeb, :controller

  alias Chatroom.Accounts
  alias Chatroom.Accounts.User

  # GET /users
  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  # GET /users/:id
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  # GET /users/new
  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, :new, changeset: changeset)
  end

  # POST /users
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  # GET /users/:id/edit
  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, :edit, user: user, changeset: changeset)
  end

  # PUT /users/:id
  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  # DELETE /users/:id
  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: ~p"/users")
  end
end
```

---

## Response Types

### Render HTML

```elixir
def index(conn, _params) do
  render(conn, :index)
  # Renders index.html.heex with conn.assigns
end

def show(conn, %{"id" => id}) do
  user = get_user!(id)
  render(conn, :show, user: user)
  # user is available as @user in template
end
```

### Render JSON

```elixir
def index(conn, _params) do
  users = list_users()
  json(conn, %{data: users})
end

# Or with explicit status
def show(conn, %{"id" => id}) do
  case get_user(id) do
    {:ok, user} ->
      conn
      |> put_status(:ok)
      |> json(%{data: user})

    {:error, :not_found} ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "User not found"})
  end
end
```

### Redirect

```elixir
def create(conn, params) do
  # ... create user ...
  redirect(conn, to: ~p"/users/#{user}")
end

def logout(conn, _params) do
  redirect(conn, external: "https://example.com")
end
```

### Send Response Directly

```elixir
def download(conn, %{"id" => id}) do
  file = get_file!(id)

  conn
  |> put_resp_content_type("application/pdf")
  |> put_resp_header("content-disposition", "attachment; filename=\"#{file.name}\"")
  |> send_resp(200, file.data)
end

def health(conn, _params) do
  send_resp(conn, 200, "OK")
end
```

---

## Parameters

```elixir
# URL: /users/123?sort=name
def show(conn, params) do
  params
  # %{"id" => "123", "sort" => "name"}
end

# Pattern match what you need
def show(conn, %{"id" => id}) do
  # id = "123"
end

# Nested params from forms
# <input name="user[name]" value="Alice">
def create(conn, %{"user" => user_params}) do
  user_params
  # %{"name" => "Alice", ...}
end
```

---

## Flash Messages

```elixir
def create(conn, params) do
  conn
  |> put_flash(:info, "Success!")      # Blue/info
  |> put_flash(:error, "Failed!")      # Red/error
  |> redirect(to: ~p"/")
end
```

Display in templates:

```heex
<.flash_group flash={@flash} />
```

---

## Plugs in Controllers

Add plugs that run before actions:

```elixir
defmodule ChatroomWeb.AdminController do
  use ChatroomWeb, :controller

  plug :require_admin

  def dashboard(conn, _params) do
    render(conn, :dashboard)
  end

  defp require_admin(conn, _opts) do
    if conn.assigns[:current_user]&.admin do
      conn
    else
      conn
      |> put_flash(:error, "Admin access required")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
```

Limit plug to specific actions:

```elixir
plug :require_admin when action in [:delete, :update]
plug :load_resource when action not in [:index, :new]
```

---

## Controller HTML Module

Controllers pair with HTML modules for templates:

```elixir
# lib/chatroom_web/controllers/user_controller.ex
defmodule ChatroomWeb.UserController do
  use ChatroomWeb, :controller
  # ...
end

# lib/chatroom_web/controllers/user_html.ex
defmodule ChatroomWeb.UserHTML do
  use ChatroomWeb, :html

  embed_templates "user_html/*"
end

# lib/chatroom_web/controllers/user_html/index.html.heex
<h1>All Users</h1>
<ul>
  <%= for user <- @users do %>
    <li><%= user.name %></li>
  <% end %>
</ul>
```

---

## Error Handling

```elixir
# Ecto.NoResultsError raises 404
def show(conn, %{"id" => id}) do
  user = Repo.get!(User, id)  # Raises if not found
  render(conn, :show, user: user)
end

# Handle errors explicitly
def show(conn, %{"id" => id}) do
  case Accounts.get_user(id) do
    {:ok, user} ->
      render(conn, :show, user: user)

    {:error, :not_found} ->
      conn
      |> put_status(:not_found)
      |> put_view(ChatroomWeb.ErrorHTML)
      |> render(:"404")
  end
end
```

---

## Try It

Create a simple page controller:

```elixir
# lib/chatroom_web/controllers/page_controller.ex
defmodule ChatroomWeb.PageController do
  use ChatroomWeb, :controller

  def about(conn, _params) do
    render(conn, :about, app_name: "Chatroom")
  end
end

# lib/chatroom_web/controllers/page_html.ex
defmodule ChatroomWeb.PageHTML do
  use ChatroomWeb, :html

  embed_templates "page_html/*"
end
```

```heex
<!-- lib/chatroom_web/controllers/page_html/about.html.heex -->
<h1>About <%= @app_name %></h1>
<p>A real-time chat application built with Phoenix.</p>
```

Add route:

```elixir
get "/about", PageController, :about
```

---

## Controllers vs LiveView

| Controller                 | LiveView                       |
| -------------------------- | ------------------------------ |
| Request → Response         | Persistent connection          |
| Page reload on interaction | UI updates in-place            |
| Good for static content    | Good for interactive features  |
| Forms POST to server       | Forms update via WebSocket     |
| Simpler for CRUD           | More complex but more powerful |

Use controllers for:

- API endpoints
- Simple pages
- File downloads
- Redirects

Use LiveView for:

- Interactive UI
- Real-time features
- Forms with validation
- Dynamic content

---

## Key Takeaways

1. **Actions are functions** - Receive `conn`, `params`
2. **Pattern match params** - `%{"id" => id}`
3. **Three response types** - `render`, `redirect`, `json`
4. **Flash messages** - `put_flash(:info, "msg")`
5. **Plugs filter actions** - `plug :auth when action in [:edit]`
6. **Pair with HTML module** - Templates in `controller_html/`

---

**Next:** [Contexts →](./05-contexts.md)
