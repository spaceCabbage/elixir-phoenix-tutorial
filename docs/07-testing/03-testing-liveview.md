# Testing LiveView

Test real-time UI with confidence.

---

## LiveView Test Setup

```elixir
# test/chatroom_web/live/chat_live_test.exs
defmodule ChatroomWeb.ChatLiveTest do
  use ChatroomWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "ChatLive" do
    test "renders join form initially", %{conn: conn} do
      {:ok, view, html} = live(conn, "/chat")

      assert html =~ "Enter username"
      assert has_element?(view, "input[name='username']")
    end
  end
end
```

---

## The `live/2` Function

```elixir
# Connect and get the view
{:ok, view, html} = live(conn, "/chat")

# view - The LiveView process
# html - Initial rendered HTML
```

---

## Testing Rendered Content

```elixir
test "shows messages", %{conn: conn} do
  message = message_fixture(body: "Hello!")

  {:ok, _view, html} = live(conn, "/chat")

  assert html =~ "Hello!"
end

test "shows username", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/chat")

  # Submit join form
  view
  |> form("form", username: "Alice")
  |> render_submit()

  # Check the view has the username
  assert has_element?(view, "strong", "Alice")
end
```

---

## Testing Events

### Form Submit

```elixir
test "join form sets username", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/chat")

  # Submit the form
  html = view
  |> form("form", username: "Alice")
  |> render_submit()

  # After join, should see message input
  assert html =~ "Type a message"
end
```

### Button Click

```elixir
test "send button submits message", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/chat")

  # First join
  view
  |> form("form", username: "Alice")
  |> render_submit()

  # Then send message
  view
  |> form("form", body: "Hello!")
  |> render_submit()

  # Message should appear
  assert has_element?(view, ".message", "Hello!")
end
```

### Click Event

```elixir
test "delete button removes message", %{conn: conn} do
  message = message_fixture(username: "Alice", body: "Delete me")

  {:ok, view, _html} = live(conn, "/chat")

  # Join as the message author
  view |> form("form", username: "Alice") |> render_submit()

  # Click delete
  view
  |> element("button[phx-click='delete'][phx-value-id='#{message.id}']")
  |> render_click()

  # Message should be gone
  refute has_element?(view, ".message", "Delete me")
end
```

---

## Testing PubSub

```elixir
test "receives new messages in real-time", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/chat")

  # Join
  view |> form("form", username: "Alice") |> render_submit()

  # Simulate another user sending a message
  Phoenix.PubSub.broadcast(
    Chatroom.PubSub,
    "chat:lobby",
    {:new_message, %{id: 1, username: "Bob", body: "Hi Alice!"}}
  )

  # Give LiveView time to process
  :timer.sleep(50)

  # Render and check
  html = render(view)
  assert html =~ "Hi Alice!"
  assert html =~ "Bob"
end
```

---

## Testing Navigation

```elixir
test "navigates to room", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/")

  {:ok, view, html} =
    view
    |> element("a", "Chat Room")
    |> render_click()
    |> follow_redirect(conn, "/chat")

  assert html =~ "Enter username"
end
```

---

## Useful Assertions

```elixir
# Check element exists
assert has_element?(view, "button", "Send")
assert has_element?(view, "#message-123")
assert has_element?(view, "input[name='body']")

# Check element doesn't exist
refute has_element?(view, ".error")

# Get element text
assert element(view, "h1") |> render() =~ "Chat"

# Check multiple elements
assert view
  |> element(".messages")
  |> render() =~ "message1"
```

---

## Testing Forms

```elixir
test "shows validation errors", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/chat")

  # Submit invalid form
  html = view
  |> form("form", username: "")
  |> render_submit()

  assert html =~ "can't be blank"
end

test "form changes trigger validation", %{conn: conn} do
  {:ok, view, _html} = live(conn, "/chat")

  # Change triggers phx-change event
  html = view
  |> form("form", username: "a")
  |> render_change()

  assert html =~ "must be at least 2 characters"
end
```

---

## Testing with Authentication

```elixir
defmodule ChatroomWeb.ChatLiveTest do
  use ChatroomWeb.ConnCase

  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)
    {:ok, conn: conn, user: user}
  end

  test "authenticated user can chat", %{conn: conn, user: user} do
    {:ok, view, html} = live(conn, "/chat")

    # User is already logged in, sees chat directly
    assert html =~ "Welcome, #{user.username}"
  end
end
```

---

## Common Patterns

### Wait for Async Updates

```elixir
test "shows loading then results" do
  {:ok, view, html} = live(conn, "/search")

  # Initial state - loading
  assert html =~ "Loading..."

  # Trigger search
  view |> form("form", query: "elixir") |> render_submit()

  # Wait for results (async)
  assert eventually(fn ->
    render(view) =~ "Results for 'elixir'"
  end)
end

defp eventually(func, timeout \\ 1000) do
  Process.sleep(50)
  if timeout <= 0 do
    func.()
  else
    func.() || eventually(func, timeout - 50)
  end
end
```

### Multiple Connected Clients

```elixir
test "both users see the message" do
  {:ok, alice, _} = live(conn, "/chat")
  {:ok, bob, _} = live(conn, "/chat")

  alice |> form("form", username: "Alice") |> render_submit()
  bob |> form("form", username: "Bob") |> render_submit()

  # Alice sends a message
  alice |> form("form", body: "Hello Bob!") |> render_submit()

  # Both should see it
  assert render(alice) =~ "Hello Bob!"
  assert render(bob) =~ "Hello Bob!"
end
```

---

## Next

Continue to [Testing GenServer](04-testing-genserver.md) to test stateful processes.
