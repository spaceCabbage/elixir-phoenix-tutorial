# Templates & HEEx

Phoenix uses HEEx (HTML + Embedded Elixir) for templates. It's like EEx but with HTML-aware features and compile-time checks.

---

## HEEx Basics

### Outputting Values

```heex
<%# Escaped output (safe) %>
<p><%= @username %></p>

<%# Raw output (dangerous - only for trusted HTML) %>
<p><%= raw(@trusted_html) %></p>

<%# Evaluated but not output %>
<% x = 1 + 1 %>
```

### Control Flow

```heex
<%# Conditionals %>
<%= if @user do %>
  <p>Hello, <%= @user.name %>!</p>
<% else %>
  <p>Please log in.</p>
<% end %>

<%# Unless %>
<%= unless @loading do %>
  <div>Content loaded</div>
<% end %>

<%# Loops %>
<ul>
  <%= for item <- @items do %>
    <li><%= item.name %></li>
  <% end %>
</ul>

<%# Case %>
<%= case @status do %>
  <% :loading -> %><p>Loading...</p>
  <% :error -> %><p>Error occurred</p>
  <% :success -> %><p>Success!</p>
<% end %>
```

---

## Components

Components are reusable UI pieces. There are two types:

### Function Components

```elixir
# In a component module
defmodule ChatroomWeb.CoreComponents do
  use Phoenix.Component

  attr :type, :string, default: "info"
  attr :message, :string, required: true

  def alert(assigns) do
    ~H"""
    <div class={"alert alert-#{@type}"}>
      <%= @message %>
    </div>
    """
  end
end
```

Usage:

```heex
<.alert type="error" message="Something went wrong!" />
```

### Slots

```elixir
slot :inner_block, required: true
slot :header

def card(assigns) do
  ~H"""
  <div class="card">
    <div :if={@header != []} class="card-header">
      <%= render_slot(@header) %>
    </div>
    <div class="card-body">
      <%= render_slot(@inner_block) %>
    </div>
  </div>
  """
end
```

Usage:

```heex
<.card>
  <:header>My Title</:header>
  <p>Card content goes here.</p>
</.card>
```

---

## Core Components

Phoenix generates `core_components.ex` with common components:

```heex
<%# Buttons %>
<.button>Click me</.button>
<.button phx-click="save">Save</.button>

<%# Links %>
<.link navigate={~p"/users"}>Users</.link>
<.link href="https://example.com">External</.link>
<.link patch={~p"/users/#{@user}/edit"}>Edit</.link>

<%# Forms %>
<.simple_form for={@form} phx-submit="save">
  <.input field={@form[:name]} label="Name" />
  <.input field={@form[:email]} type="email" label="Email" />
  <:actions>
    <.button>Save</.button>
  </:actions>
</.simple_form>

<%# Tables %>
<.table id="users" rows={@users}>
  <:col :let={user} label="Name"><%= user.name %></:col>
  <:col :let={user} label="Email"><%= user.email %></:col>
</.table>

<%# Flash messages %>
<.flash_group flash={@flash} />

<%# Modal %>
<.modal :if={@show_modal} id="confirm-modal">
  <p>Are you sure?</p>
</.modal>
```

---

## Layouts

### Root Layout

The outermost wrapper (`root.html.heex`):

```heex
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <.live_title suffix=" · Chatroom">
      <%= assigns[:page_title] || "Home" %>
    </.live_title>
    <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
    <script defer phx-track-static src={~p"/assets/app.js"}></script>
  </head>
  <body>
    <%= @inner_content %>
  </body>
</html>
```

### App Layout

Inner wrapper (`app.html.heex`):

```heex
<header>
  <nav>
    <.link href={~p"/"}>Home</.link>
    <.link href={~p"/about"}>About</.link>
  </nav>
</header>

<main class="container">
  <.flash_group flash={@flash} />
  <%= @inner_content %>
</main>

<footer>
  <p>© 2024 Chatroom</p>
</footer>
```

---

## Assigns

Data passed to templates via assigns:

```elixir
# In controller
def show(conn, %{"id" => id}) do
  user = Accounts.get_user!(id)
  render(conn, :show,
    user: user,
    page_title: "User Profile"
  )
end

# In LiveView
def mount(_params, _session, socket) do
  {:ok, assign(socket,
    user: get_user(),
    page_title: "Dashboard"
  )}
end
```

Access in templates:

```heex
<h1><%= @page_title %></h1>
<p>Name: <%= @user.name %></p>
```

---

## HEEx Features

### Special Attributes

```heex
<%# Conditional rendering %>
<div :if={@show}>Only shown if @show is truthy</div>

<%# Loop rendering %>
<li :for={item <- @items}><%= item.name %></li>

<%# Combined %>
<p :for={error <- @errors} :if={@show_errors} class="error">
  <%= error %>
</p>
```

### Dynamic Attributes

```heex
<%# Dynamic class %>
<div class={["base-class", @active && "active", @error && "error"]}>

<%# Spread attributes %>
<input {@input_attrs} />
```

### HTML Escaping

HEEx automatically escapes output:

```heex
<%# This is safe - HTML entities escaped %>
<%= "<script>alert('xss')</script>" %>
<%# Renders: &lt;script&gt;alert('xss')&lt;/script&gt; %>

<%# This is dangerous - use only with trusted content %>
<%= raw("<b>Bold</b>") %>
```

---

## This Codebase

```heex
<%# lib/chatroom_web/live/chat_live.ex - embedded template %>
def render(assigns) do
  ~H"""
  <div class="max-w-2xl mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4 text-slate-800">Chat Room</h1>

    <%# Messages list %>
    <div id="messages" class="space-y-2 mb-4 h-96 overflow-y-auto bg-slate-100 p-4 rounded">
      <div :for={msg <- @messages} id={"msg-#{msg.id}"} class="p-2 bg-white rounded shadow-sm">
        <span class="font-semibold text-slate-700"><%= msg.username %>:</span>
        <span class="text-slate-600"><%= msg.body %></span>
      </div>
    </div>

    <%# Message form %>
    <.simple_form for={@form} phx-submit="send_message">
      <.input field={@form[:body]} placeholder="Type a message..." />
      <:actions>
        <.button>Send</.button>
      </:actions>
    </.simple_form>
  </div>
  """
end
```

---

## Template vs Embedded

### Separate Template File

```elixir
# lib/chatroom_web/controllers/page_html.ex
defmodule ChatroomWeb.PageHTML do
  use ChatroomWeb, :html

  embed_templates "page_html/*"
end
```

```heex
<%# lib/chatroom_web/controllers/page_html/index.html.heex %>
<h1>Welcome!</h1>
```

### Embedded Template (LiveView)

```elixir
defmodule ChatroomWeb.ChatLive do
  use ChatroomWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Chat</h1>
    """
  end
end
```

Both work - separate files are better for larger templates.

---

## Sigils

```elixir
# HEEx template
~H"""
<div>HTML-aware template</div>
"""

# Regular string (not HTML-aware)
~s"""
Just a string
"""
```

---

## Try It

Add a component:

```elixir
# In lib/chatroom_web/components/core_components.ex

attr :timestamp, :any, required: true
def time_ago(assigns) do
  ~H"""
  <time datetime={@timestamp}>
    <%= Calendar.strftime(@timestamp, "%B %d, %Y at %H:%M") %>
  </time>
  """
end
```

Use it:

```heex
<.time_ago timestamp={@message.inserted_at} />
```

---

## Key Takeaways

1. **HEEx = HTML + Elixir** - Compile-time checked templates
2. **`<%= %>` outputs escaped** - Safe by default
3. **`:if` and `:for` attributes** - Cleaner conditionals/loops
4. **Components with `attr` and `slot`** - Reusable, documented
5. **Layouts wrap content** - Root → App → Page
6. **`@assigns` in templates** - Data from controller/LiveView

---

**You've completed Phoenix Framework!**

**Next section:** [Ecto Database →](../04-ecto-database/)
