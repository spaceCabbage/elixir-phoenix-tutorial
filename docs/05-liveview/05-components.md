# Components

Components are reusable UI pieces. There are two types: function components (stateless) and live components (stateful).

---

## Function Components

Simple, stateless components defined as functions:

```elixir
defmodule MyAppWeb.Components do
  use Phoenix.Component

  attr :type, :string, default: "info"
  attr :message, :string, required: true

  def alert(assigns) do
    ~H"""
    <div class={"alert alert-#{@type}"} role="alert">
      <%= @message %>
    </div>
    """
  end
end
```

### Usage

```heex
<MyAppWeb.Components.alert message="Success!" type="success" />

<%# Or with import %>
<.alert message="Success!" type="success" />
```

---

## Declaring Attributes

```elixir
# Required attribute
attr :title, :string, required: true

# With default
attr :type, :string, default: "primary"

# Atom values
attr :size, :atom, values: [:small, :medium, :large], default: :medium

# Boolean
attr :disabled, :boolean, default: false

# List of items
attr :items, :list, default: []

# Map/struct
attr :user, :map, required: true

# Any type
attr :data, :any

# Global attributes (class, id, etc.)
attr :rest, :global
```

### Using Global Attributes

```elixir
attr :rest, :global, include: ~w(class id)

def button(assigns) do
  ~H"""
  <button {@rest}>
    <%= render_slot(@inner_block) %>
  </button>
  """
end
```

```heex
<.button class="btn-primary" id="submit-btn">Submit</.button>
```

---

## Slots

Slots allow passing content into components:

```elixir
slot :inner_block, required: true

def card(assigns) do
  ~H"""
  <div class="card">
    <%= render_slot(@inner_block) %>
  </div>
  """
end
```

```heex
<.card>
  <p>Card content here</p>
</.card>
```

### Named Slots

```elixir
slot :header
slot :inner_block, required: true
slot :footer

def card(assigns) do
  ~H"""
  <div class="card">
    <div :if={@header != []} class="card-header">
      <%= render_slot(@header) %>
    </div>
    <div class="card-body">
      <%= render_slot(@inner_block) %>
    </div>
    <div :if={@footer != []} class="card-footer">
      <%= render_slot(@footer) %>
    </div>
  </div>
  """
end
```

```heex
<.card>
  <:header>Card Title</:header>
  Main content goes here
  <:footer>
    <button>Save</button>
  </:footer>
</.card>
```

### Slot with Arguments

```elixir
slot :col, required: true do
  attr :label, :string, required: true
end

def table(assigns) do
  ~H"""
  <table>
    <thead>
      <tr>
        <th :for={col <- @col}><%= col.label %></th>
      </tr>
    </thead>
    <tbody>
      <tr :for={row <- @rows}>
        <td :for={col <- @col}>
          <%= render_slot(col, row) %>
        </td>
      </tr>
    </tbody>
  </table>
  """
end
```

```heex
<.table rows={@users}>
  <:col :let={user} label="Name"><%= user.name %></:col>
  <:col :let={user} label="Email"><%= user.email %></:col>
  <:col :let={user} label="Actions">
    <.link navigate={~p"/users/#{user}"}>View</.link>
  </:col>
</.table>
```

---

## Core Components

Phoenix generates `core_components.ex` with common components. Key ones:

```heex
<%# Button %>
<.button>Click me</.button>
<.button phx-click="save" class="bg-blue-500">Save</.button>

<%# Link %>
<.link navigate={~p"/users"}>Users</.link>
<.link patch={~p"/users/#{@user}/edit"}>Edit</.link>

<%# Input %>
<.input field={@form[:email]} type="email" label="Email" />

<%# Simple Form %>
<.simple_form for={@form} phx-submit="save">
  <.input field={@form[:name]} label="Name" />
  <:actions>
    <.button>Submit</.button>
  </:actions>
</.simple_form>

<%# Modal %>
<.modal id="confirm-modal" show={@show_modal}>
  <p>Are you sure?</p>
</.modal>

<%# Flash %>
<.flash_group flash={@flash} />

<%# Table %>
<.table id="users" rows={@users}>
  <:col :let={user} label="Name"><%= user.name %></:col>
</.table>
```

---

## Live Components (Stateful)

For components that need their own state:

```elixir
defmodule MyAppWeb.Components.Counter do
  use MyAppWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("increment", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p>Count: <%= @count %></p>
      <button phx-click="increment" phx-target={@myself}>+</button>
    </div>
    """
  end
end
```

### Usage

```heex
<.live_component module={MyAppWeb.Components.Counter} id="counter-1" />
```

### Passing Data

```heex
<.live_component
  module={MyAppWeb.Components.UserCard}
  id={"user-#{@user.id}"}
  user={@user}
  on_delete={fn user -> send(self(), {:delete_user, user}) end}
/>
```

```elixir
defmodule MyAppWeb.Components.UserCard do
  use MyAppWeb, :live_component

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("delete", _, socket) do
    socket.assigns.on_delete.(socket.assigns.user)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p><%= @user.name %></p>
      <button phx-click="delete" phx-target={@myself}>Delete</button>
    </div>
    """
  end
end
```

---

## `phx-target`

Important for live components:

```heex
<%# Targets parent LiveView %>
<button phx-click="action">Click</button>

<%# Targets this live component %>
<button phx-click="action" phx-target={@myself}>Click</button>
```

Without `phx-target={@myself}`, events go to the parent LiveView!

---

## Function vs Live Component

| Feature        | Function Component | Live Component        |
| -------------- | ------------------ | --------------------- |
| State          | No                 | Yes                   |
| Event handling | Parent handles     | Self handles          |
| Lifecycle      | None               | mount, update         |
| Syntax         | `.component`       | `.live_component`     |
| Performance    | Fastest            | More overhead         |
| Use when       | Stateless UI       | Isolated state needed |

### Rule of Thumb

Start with function components. Only use live components when you need isolated state or event handling.

---

## Organizing Components

```
lib/my_app_web/
├── components/
│   ├── core_components.ex     # Generated by Phoenix
│   ├── icons.ex               # Icon components
│   ├── forms.ex               # Form components
│   └── ui.ex                  # General UI components
├── live/
│   ├── components/            # Live components
│   │   ├── user_card.ex
│   │   └── search.ex
│   └── page_live.ex
└── my_app_web.ex              # Import helpers
```

---

## Key Takeaways

1. **Function components** - Stateless, fast, use most of the time
2. **`attr` and `slot`** - Declare inputs with docs and validation
3. **`render_slot/1`** - Render slot content
4. **Live components** - For isolated state/events
5. **`phx-target={@myself}`** - Target live component's own handler
6. **Core components** - Phoenix provides common ones

---

**Next:** [Forms →](./06-forms.md)
