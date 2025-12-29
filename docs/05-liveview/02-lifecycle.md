# LiveView Lifecycle

Understanding the lifecycle callbacks helps you know where to put your code.

---

## Callback Overview

```
mount/3 ──→ handle_params/3 ──→ render/1
                                    │
                                    ▼
                            User interacts
                                    │
              ┌─────────────────────┼─────────────────────┐
              ▼                     ▼                     ▼
        handle_event/3       handle_info/2        handle_params/3
              │                     │                     │
              └─────────────────────┴─────────────────────┘
                                    │
                                    ▼
                               render/1
```

---

## `mount/3`

Called when LiveView starts (twice - static and connected):

```elixir
def mount(params, session, socket) do
  # params: URL params (%{"id" => "123"})
  # session: Session data (%{"user_id" => 1})
  # socket: The LiveView socket

  {:ok, socket}
end
```

### Common Patterns

```elixir
def mount(%{"id" => id}, _session, socket) do
  user = Accounts.get_user!(id)

  socket =
    socket
    |> assign(:user, user)
    |> assign(:page_title, user.name)

  {:ok, socket}
end

# With subscriptions
def mount(_params, _session, socket) do
  if connected?(socket) do
    Chat.subscribe()
    Process.send_after(self(), :tick, 1000)
  end

  {:ok, assign(socket, count: 0)}
end
```

### Return Values

```elixir
{:ok, socket}
{:ok, socket, temporary_assigns: [messages: []]}
{:ok, socket, layout: false}
```

---

## `render/1`

Returns the HTML to display:

```elixir
def render(assigns) do
  ~H"""
  <h1>Hello <%= @name %></h1>
  """
end
```

Or use a separate template file:

```elixir
# lib/chatroom_web/live/chat_live.ex
defmodule ChatroomWeb.ChatLive do
  use ChatroomWeb, :live_view
  # Will look for chat_live.html.heex in same directory
end
```

---

## `handle_params/3`

Called when URL changes (including initial mount):

```elixir
def handle_params(params, uri, socket) do
  # params: URL params
  # uri: Full URL string

  {:noreply, apply_action(socket, socket.assigns.live_action, params)}
end

defp apply_action(socket, :index, _params) do
  assign(socket, :page_title, "All Posts")
end

defp apply_action(socket, :show, %{"id" => id}) do
  post = Blog.get_post!(id)
  assign(socket, :page_title, post.title, post: post)
end
```

### Live Navigation

```heex
<%# patch - same LiveView, different params %>
<.link patch={~p"/posts/#{@post.id}/edit"}>Edit</.link>

<%# navigate - different LiveView %>
<.link navigate={~p"/users"}>Users</.link>
```

- `patch` → Only calls `handle_params/3`
- `navigate` → Full mount of new LiveView

---

## `handle_event/3`

Handles events from the client:

```elixir
def handle_event(event, params, socket) do
  # event: String event name ("click", "submit", etc.)
  # params: Event data from client

  {:noreply, socket}
end
```

### Examples

```elixir
# Button click
def handle_event("increment", _params, socket) do
  {:noreply, update(socket, :count, &(&1 + 1))}
end

# Form submit
def handle_event("save", %{"user" => user_params}, socket) do
  case Accounts.create_user(user_params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, "User created!")
       |> push_navigate(to: ~p"/users/#{user}")}

    {:error, changeset} ->
      {:noreply, assign(socket, :changeset, changeset)}
  end
end

# Form change (validation)
def handle_event("validate", %{"user" => params}, socket) do
  changeset =
    %User{}
    |> Accounts.change_user(params)
    |> Map.put(:action, :validate)

  {:noreply, assign(socket, :changeset, changeset)}
end
```

---

## `handle_info/2`

Handles messages from other processes (PubSub, timers, etc.):

```elixir
def handle_info(message, socket) do
  # message: Any Erlang term

  {:noreply, socket}
end
```

### Examples

```elixir
# PubSub message
def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, &(&1 ++ [message]))}
end

# Timer
def handle_info(:tick, socket) do
  Process.send_after(self(), :tick, 1000)
  {:noreply, update(socket, :time, fn _ -> DateTime.utc_now() end)}
end

# Task result
def handle_info({ref, result}, socket) do
  Process.demonitor(ref, [:flush])
  {:noreply, assign(socket, :result, result)}
end
```

---

## `terminate/2`

Called when LiveView is shutting down:

```elixir
def terminate(reason, socket) do
  # Cleanup: unsubscribe, close connections, etc.
  :ok
end
```

Note: Not always called (e.g., browser crash). Don't rely on it for critical cleanup.

---

## Temporary Assigns

For large lists, use temporary assigns to free memory after render:

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket, messages: []), temporary_assigns: [messages: []]}
end

def handle_info({:new_message, message}, socket) do
  {:noreply, assign(socket, messages: [message])}
end
```

```heex
<div id="messages" phx-update="append">
  <div :for={msg <- @messages} id={"msg-#{msg.id}"}>
    <%= msg.body %>
  </div>
</div>
```

With `phx-update="append"`, new messages are added without re-sending old ones.

---

## Complete Example

```elixir
defmodule MyAppWeb.CounterLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign(socket, count: 0, time: DateTime.utc_now())}
  end

  def handle_event("increment", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("decrement", _, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, :time, DateTime.utc_now())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Count: <%= @count %></h1>
      <button phx-click="decrement">-</button>
      <button phx-click="increment">+</button>
      <p>Time: <%= @time %></p>
    </div>
    """
  end
end
```

---

## Key Takeaways

1. **`mount/3`** - Initialize state, subscribe to PubSub
2. **`render/1`** - Return HTML template
3. **`handle_params/3`** - URL changes (patch navigation)
4. **`handle_event/3`** - User interactions
5. **`handle_info/2`** - Messages from other processes
6. **Temporary assigns** - For large/streaming data

---

**Next:** [Events →](./03-events.md)
