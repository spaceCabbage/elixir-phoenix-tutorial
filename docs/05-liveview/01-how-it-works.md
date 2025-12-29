# How LiveView Works

Understanding the magic behind LiveView helps you use it effectively.

---

## The Two-Phase Render

When you visit a LiveView page:

### Phase 1: HTTP (Static HTML)

```
Browser → GET /chat → Phoenix Router → LiveView.mount() → HTML Response
```

1. Browser requests the page
2. Router matches to LiveView
3. `mount/3` is called (disconnected)
4. `render/1` generates HTML
5. Full HTML page sent to browser

### Phase 2: WebSocket (Interactive)

```
Browser → WebSocket /live → LiveView.mount() → Persistent Connection
```

1. JavaScript establishes WebSocket
2. `mount/3` is called again (connected)
3. LiveView enters interactive mode
4. Events flow over WebSocket
5. Only diffs are sent for updates

---

## The Mount Lifecycle

```elixir
def mount(_params, _session, socket) do
  IO.puts("connected? #{connected?(socket)}")

  # This runs TWICE:
  # 1. First for static HTML (connected? = false)
  # 2. Again for WebSocket (connected? = true)

  {:ok, socket}
end
```

### Why Two Mounts?

1. **SEO & Speed**: First mount generates static HTML immediately
2. **Interactivity**: Second mount enables real-time features

### Pattern: Subscribe Only When Connected

```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    Chat.subscribe()  # Only subscribe on WebSocket mount
  end

  {:ok, assign(socket, messages: [])}
end
```

---

## The Socket

The socket is your state container:

```elixir
%Phoenix.LiveView.Socket{
  assigns: %{
    messages: [...],
    current_user: %User{},
    live_action: :index
  },
  # ... internal fields
}
```

### Assigns

Data stored in the socket:

```elixir
# Set assigns
socket = assign(socket, name: "Alice", age: 30)
socket = assign(socket, %{name: "Alice", age: 30})

# Access in template
@name  # "Alice"

# Update existing
socket = update(socket, :count, &(&1 + 1))
```

---

## Rendering & Diffing

LiveView only sends what changed:

```elixir
# Initial render
def render(assigns) do
  ~H"""
  <h1>Hello <%= @name %></h1>
  <p>Count: <%= @count %></p>
  """
end
```

When `@count` changes from 5 to 6:

- LiveView computes the diff
- Only `<p>Count: 6</p>` is sent (not entire page)
- JavaScript patches the DOM

### Efficient Updates

```heex
<%# Each message has stable ID - efficient updates %>
<div :for={msg <- @messages} id={"msg-#{msg.id}"}>
  <%= msg.body %>
</div>
```

The `id` attribute helps LiveView track which elements changed.

---

## Event Flow

```
User Click
    │
    ▼
JavaScript captures event
    │
    ▼
Event sent via WebSocket
    │
    ▼
handle_event/3 called on server
    │
    ▼
Socket state updated
    │
    ▼
render/1 called
    │
    ▼
Diff computed
    │
    ▼
Diff sent via WebSocket
    │
    ▼
JavaScript patches DOM
```

All in **milliseconds** - feels like a native app.

---

## Memory Usage

Each LiveView is a process:

```elixir
# Each connected user = one process
# Process memory ≈ size of assigns

def mount(_params, _session, socket) do
  # Don't load entire database!
  messages = Chat.list_messages() |> Enum.take(50)
  {:ok, assign(socket, messages: messages)}
end
```

### Best Practices

1. **Limit data in assigns** - Only what's needed
2. **Paginate long lists** - Use streams for infinite scroll
3. **Clean up on terminate** - Unsubscribe, close resources

---

## JavaScript Integration

LiveView includes minimal JavaScript that:

- Establishes WebSocket
- Captures DOM events
- Applies patches
- Handles focus, scroll preservation

For custom JavaScript, use **hooks**:

```javascript
// assets/js/app.js
let Hooks = {};
Hooks.AutoScroll = {
  mounted() {
    this.el.scrollTop = this.el.scrollHeight;
  },
  updated() {
    this.el.scrollTop = this.el.scrollHeight;
  },
};

let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks });
```

```heex
<div id="messages" phx-hook="AutoScroll">
  <%= for msg <- @messages do %>
    ...
  <% end %>
</div>
```

---

## Compared to SPAs

| Aspect         | React/Vue SPA     | LiveView         |
| -------------- | ----------------- | ---------------- |
| State location | Client (browser)  | Server (process) |
| Data fetching  | API calls + state | Direct DB access |
| Bundle size    | Large (100kb+)    | Small (~20kb)    |
| First render   | Client-side       | Server-side      |
| SEO            | Requires SSR      | Built-in         |
| Real-time      | Extra setup       | Built-in         |
| Offline        | Possible          | Limited          |

---

## When to Use LiveView

### Great for:

- Dashboards & admin panels
- Real-time features (chat, notifications)
- Forms with instant validation
- Data-heavy CRUD apps
- Interactive tables & lists

### Consider alternatives for:

- Offline-first apps
- Heavy client-side computation
- Complex animations
- Mobile apps

---

## Try It

Open your browser's Network tab (WebSocket section):

1. Visit `http://localhost:4000`
2. See the WebSocket connection to `/live`
3. Send a chat message
4. Watch the small payloads (diffs only!)

```elixir
# In IEx, send a message
Chatroom.Chat.create_message(%{username: "IEx", body: "Hello from server!"})
# Watch it appear in browser instantly!
```

---

## Key Takeaways

1. **Two-phase render** - Static HTML first, then WebSocket
2. **Socket holds state** - Like a persistent process
3. **Only diffs sent** - Efficient updates
4. **Each user = one process** - Mind your memory
5. **`connected?/1`** - Know which phase you're in
6. **Server state** - No client-side state management

---

**Next:** [Lifecycle →](./02-lifecycle.md)
