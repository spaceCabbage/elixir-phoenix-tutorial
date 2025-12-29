# Events

LiveView handles user interactions through special `phx-*` attributes.

---

## Click Events

```heex
<button phx-click="increment">+1</button>
```

```elixir
def handle_event("increment", _params, socket) do
  {:noreply, update(socket, :count, &(&1 + 1))}
end
```

### With Values

```heex
<button phx-click="delete" phx-value-id={@item.id}>Delete</button>
```

```elixir
def handle_event("delete", %{"id" => id}, socket) do
  item = Items.get_item!(id)
  {:ok, _} = Items.delete_item(item)
  {:noreply, update(socket, :items, &Enum.reject(&1, fn i -> i.id == item.id end))}
end
```

---

## Form Events

### Submit

```heex
<form phx-submit="save">
  <input name="name" type="text" />
  <button>Save</button>
</form>
```

```elixir
def handle_event("save", %{"name" => name}, socket) do
  # Handle form submission
  {:noreply, socket}
end
```

### Change (Live Validation)

```heex
<form phx-change="validate" phx-submit="save">
  <input name="user[email]" value={@changeset.changes[:email]} />
  <button>Save</button>
</form>
```

```elixir
def handle_event("validate", %{"user" => params}, socket) do
  changeset =
    %User{}
    |> User.changeset(params)
    |> Map.put(:action, :validate)

  {:noreply, assign(socket, :changeset, changeset)}
end
```

---

## Focus & Blur

```heex
<input phx-focus="input-focus" phx-blur="input-blur" />
```

```elixir
def handle_event("input-focus", _params, socket) do
  {:noreply, assign(socket, :focused, true)}
end

def handle_event("input-blur", _params, socket) do
  {:noreply, assign(socket, :focused, false)}
end
```

---

## Key Events

```heex
<div phx-window-keydown="keydown">
  Press any key
</div>
```

```elixir
def handle_event("keydown", %{"key" => key}, socket) do
  case key do
    "Escape" -> {:noreply, assign(socket, :modal_open, false)}
    "Enter" -> {:noreply, handle_enter(socket)}
    _ -> {:noreply, socket}
  end
end
```

### Key Filtering

```heex
<%# Only fires for Enter key %>
<input phx-keydown="submit" phx-key="Enter" />

<%# Only fires for Escape %>
<div phx-window-keyup="close" phx-key="Escape"></div>
```

---

## Debounce & Throttle

### Debounce

Wait until user stops typing:

```heex
<input phx-change="search" phx-debounce="300" />
```

### Throttle

Fire at most once per interval:

```heex
<div phx-click="update" phx-throttle="1000">
  Click (max once per second)
</div>
```

### Blur Debounce

```heex
<input phx-change="validate" phx-debounce="blur" />
```

Only fires when input loses focus.

---

## Loading States

Show feedback during events:

```heex
<button phx-click="save" phx-disable-with="Saving...">
  Save
</button>
```

### CSS Classes

```heex
<button phx-click="save" class="phx-click-loading:opacity-50">
  Save
</button>
```

Phoenix adds classes during events:

- `phx-click-loading` - During click event
- `phx-submit-loading` - During form submit
- `phx-change-loading` - During change event

---

## Target Specific Components

```heex
<%# Target parent LiveView %>
<button phx-click="action">Click</button>

<%# Target specific component %>
<button phx-click="action" phx-target={@myself}>Click</button>

<%# Target by CSS selector %>
<button phx-click="action" phx-target="#my-component">Click</button>
```

---

## JavaScript Hooks

For custom JavaScript behavior:

```javascript
// assets/js/app.js
let Hooks = {};

Hooks.AutoFocus = {
  mounted() {
    this.el.focus();
  },
};

Hooks.InfiniteScroll = {
  mounted() {
    this.observer = new IntersectionObserver((entries) => {
      if (entries[0].isIntersecting) {
        this.pushEvent("load-more", {});
      }
    });
    this.observer.observe(this.el);
  },
  destroyed() {
    this.observer.disconnect();
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});
```

```heex
<input phx-hook="AutoFocus" id="search-input" />

<div phx-hook="InfiniteScroll" id="scroll-trigger"></div>
```

### Hook Callbacks

```javascript
Hooks.MyHook = {
  mounted() {}, // Element added to DOM
  beforeUpdate() {}, // Before DOM patch
  updated() {}, // After DOM patch
  destroyed() {}, // Element removed from DOM
  disconnected() {}, // WebSocket disconnected
  reconnected() {}, // WebSocket reconnected
};
```

### Push Events from Hooks

```javascript
Hooks.MyHook = {
  mounted() {
    this.pushEvent("hook-mounted", { value: this.el.value });
    this.pushEventTo("#other-component", "event", {});
  },
};
```

---

## JS Commands

Client-side interactions without server round-trip:

```heex
<button phx-click={JS.toggle(to: "#menu")}>Toggle Menu</button>
<div id="menu" class="hidden">Menu content</div>
```

### Available Commands

```elixir
import Phoenix.LiveView.JS

# Show/Hide
JS.show(to: "#modal")
JS.hide(to: "#modal")
JS.toggle(to: "#dropdown")

# CSS
JS.add_class("active", to: "#tab")
JS.remove_class("active", to: "#tab")
JS.toggle_class("hidden", to: "#panel")

# Attributes
JS.set_attribute({"aria-expanded", "true"}, to: "#menu")
JS.remove_attribute("disabled", to: "#button")

# Focus
JS.focus(to: "#input")
JS.focus_first(to: "#modal")

# Navigation
JS.push("event")  # Push event to server
JS.navigate(~p"/path")
JS.patch(~p"/path")

# Chaining
JS.hide(to: "#dropdown")
|> JS.show(to: "#modal")
|> JS.push("modal-opened")
```

---

## This Codebase

```elixir
# lib/chatroom_web/live/chat_live.ex
def handle_event("send_message", %{"body" => body}, socket) do
  case Chat.create_message(%{username: socket.assigns.username, body: body}) do
    {:ok, _message} ->
      {:noreply, assign(socket, form: to_form(%{}))}

    {:error, _changeset} ->
      {:noreply, socket}
  end
end
```

```heex
<.simple_form for={@form} phx-submit="send_message">
  <.input field={@form[:body]} placeholder="Type a message..." />
  <.button>Send</.button>
</.simple_form>
```

---

## Key Takeaways

1. **`phx-click`** - Handle clicks
2. **`phx-submit`** - Handle form submissions
3. **`phx-change`** - Live validation
4. **`phx-debounce`** - Delay events
5. **`phx-value-*`** - Pass data with events
6. **JS Commands** - Client-side without server
7. **Hooks** - Custom JavaScript when needed

---

**Next:** [PubSub →](./04-pubsub.md)
