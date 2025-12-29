# Contexts

Contexts are the boundary between your web layer and business logic. They're Phoenix's answer to "where should this code go?"

---

## What is a Context?

A context is a module that groups related functionality:

```elixir
# lib/chatroom/chat.ex
defmodule Chatroom.Chat do
  @moduledoc """
  The Chat context - all chat-related operations.
  """

  import Ecto.Query
  alias Chatroom.Repo
  alias Chatroom.Chat.Message

  def list_messages do
    Message
    |> order_by(asc: :inserted_at)
    |> limit(50)
    |> Repo.all()
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:new_message)
  end

  # ... more chat operations
end
```

---

## Why Contexts?

### Without Contexts

```elixir
# In controller - BAD
def create(conn, %{"message" => params}) do
  %Message{}
  |> Message.changeset(params)
  |> Repo.insert()
  |> case do
    {:ok, message} ->
      Phoenix.PubSub.broadcast(Chatroom.PubSub, "chat:lobby", {:new_message, message})
      redirect(conn, to: ~p"/")

    {:error, changeset} ->
      render(conn, :new, changeset: changeset)
  end
end
```

Problems:

- Controller knows too much
- Logic duplicated if needed elsewhere
- Hard to test
- Tightly coupled to web layer

### With Contexts

```elixir
# In context - GOOD
def create_message(attrs) do
  %Message{}
  |> Message.changeset(attrs)
  |> Repo.insert()
  |> broadcast(:new_message)
end

# In controller
def create(conn, %{"message" => params}) do
  case Chat.create_message(params) do
    {:ok, _message} ->
      redirect(conn, to: ~p"/")

    {:error, changeset} ->
      render(conn, :new, changeset: changeset)
  end
end
```

Benefits:

- Controller is thin
- Logic reusable (API, LiveView, IEx)
- Easy to test
- Clear boundaries

---

## The Context Pattern

```
Web Layer                      Business Layer
────────────                   ──────────────

Controller/LiveView ──────────→ Context
                                    │
                                    ▼
                               Functions
                                    │
                                    ▼
                              Schema + Repo
```

### Rules of Thumb

1. **Controllers call contexts** - Never call `Repo` directly
2. **Contexts hide implementation** - Web layer doesn't know about Ecto queries
3. **Contexts return results** - `{:ok, item}` or `{:error, changeset}`
4. **One context per domain** - Chat, Accounts, Billing, etc.

---

## This Codebase: Chat Context

```elixir
# lib/chatroom/chat.ex
defmodule Chatroom.Chat do
  import Ecto.Query
  alias Chatroom.Repo
  alias Chatroom.Chat.Message

  @topic "chat:lobby"

  # Query operations
  def list_messages do
    Message
    |> order_by(asc: :inserted_at)
    |> limit(50)
    |> Repo.all()
  end

  # Create operations
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:new_message)
  end

  # PubSub operations
  def subscribe do
    Phoenix.PubSub.subscribe(Chatroom.PubSub, @topic)
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(Chatroom.PubSub, @topic, {event, message})
    {:ok, message}
  end

  defp broadcast({:error, _} = error, _event), do: error
end
```

Notice:

- Single module for all chat operations
- Hides Ecto queries
- Hides PubSub details
- Returns standard `{:ok, _}` / `{:error, _}` tuples

---

## Generating Contexts

```bash
# Generate context + schema
mix phx.gen.context Accounts User users name:string email:string

# Creates:
# - lib/chatroom/accounts.ex (context)
# - lib/chatroom/accounts/user.ex (schema)
# - priv/repo/migrations/*_create_users.exs

# Generate with HTML
mix phx.gen.html Accounts User users name:string email:string

# Generate with LiveView
mix phx.gen.live Accounts User users name:string email:string
```

---

## Context Structure

```
lib/chatroom/
├── accounts.ex              # Accounts context
├── accounts/
│   ├── user.ex              # User schema
│   └── credential.ex        # Credential schema
├── chat.ex                  # Chat context
├── chat/
│   └── message.ex           # Message schema
├── billing.ex               # Billing context
└── billing/
    ├── subscription.ex
    └── invoice.ex
```

---

## Standard Context Functions

Generated contexts follow patterns:

```elixir
defmodule Chatroom.Accounts do
  alias Chatroom.Repo
  alias Chatroom.Accounts.User

  # List all
  def list_users do
    Repo.all(User)
  end

  # Get one (raises if not found)
  def get_user!(id) do
    Repo.get!(User, id)
  end

  # Get one (returns nil if not found)
  def get_user(id) do
    Repo.get(User, id)
  end

  # Create
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # Update
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  # Delete
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  # Changeset for forms
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
```

---

## Cross-Context Operations

When operations span contexts:

```elixir
# Option 1: Call one context from another
defmodule Chatroom.Orders do
  alias Chatroom.Accounts

  def place_order(user_id, items) do
    user = Accounts.get_user!(user_id)
    # ... create order with user
  end
end

# Option 2: Facade/orchestration in web layer
def create(conn, params) do
  user = Accounts.get_user!(params["user_id"])
  case Orders.create_order(user, params) do
    {:ok, order} ->
      Notifications.send_confirmation(user, order)
      redirect(conn, to: ~p"/orders/#{order}")
  end
end
```

---

## Testing Contexts

Contexts are easy to test without the web layer:

```elixir
# test/chatroom/chat_test.exs
defmodule Chatroom.ChatTest do
  use Chatroom.DataCase

  alias Chatroom.Chat

  describe "messages" do
    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chat.list_messages() == [message]
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{username: "test", body: "hello"}
      assert {:ok, %Message{} = message} = Chat.create_message(valid_attrs)
      assert message.username == "test"
      assert message.body == "hello"
    end

    test "create_message/1 with invalid data returns error changeset" do
      invalid_attrs = %{username: nil, body: nil}
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(invalid_attrs)
    end
  end
end
```

---

## Common Patterns

### Query Composition

```elixir
def list_messages(opts \\ []) do
  Message
  |> apply_filters(opts)
  |> order_by(asc: :inserted_at)
  |> Repo.all()
end

defp apply_filters(query, opts) do
  Enum.reduce(opts, query, fn
    {:username, username}, query ->
      where(query, [m], m.username == ^username)

    {:since, datetime}, query ->
      where(query, [m], m.inserted_at >= ^datetime)

    _, query ->
      query
  end)
end

# Usage
Chat.list_messages(username: "alice", since: ~U[2024-01-01 00:00:00Z])
```

### Transaction Wrapping

```elixir
def transfer_funds(from_account, to_account, amount) do
  Repo.transaction(fn ->
    with {:ok, from} <- debit(from_account, amount),
         {:ok, to} <- credit(to_account, amount) do
      {:ok, %{from: from, to: to}}
    else
      {:error, reason} -> Repo.rollback(reason)
    end
  end)
end
```

---

## Try It

```elixir
# In IEx
iex> alias Chatroom.Chat

# Use context functions
iex> Chat.list_messages()
[]

iex> Chat.create_message(%{username: "test", body: "Hello from IEx!"})
{:ok, %Message{...}}

iex> Chat.list_messages()
[%Message{username: "test", body: "Hello from IEx!", ...}]

# Check the browser - message appeared!
```

---

## Key Takeaways

1. **Contexts group related functions** - One per domain area
2. **Hide implementation details** - Web layer doesn't know about Ecto
3. **Return standard tuples** - `{:ok, value}` or `{:error, changeset}`
4. **Controllers stay thin** - Call contexts, handle responses
5. **Easy to test** - No web layer needed
6. **Generators help** - `mix phx.gen.context`

---

**Next:** [Templates →](./06-templates.md)
