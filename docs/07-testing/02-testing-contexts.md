# Testing Contexts

Test your business logic in isolation.

---

## Setting Up Context Tests

```elixir
# test/chatroom/chat_test.exs
defmodule Chatroom.ChatTest do
  use Chatroom.DataCase

  alias Chatroom.Chat
  alias Chatroom.Chat.Message

  describe "messages" do
    @valid_attrs %{username: "testuser", body: "Hello, world!"}
    @invalid_attrs %{username: nil, body: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chat.list_messages() == [message]
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Chat.create_message(@valid_attrs)
      assert message.username == "testuser"
      assert message.body == "Hello, world!"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end
  end

  defp message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Chat.create_message()

    message
  end
end
```

---

## DataCase Explained

`test/support/data_case.ex` provides:

```elixir
defmodule Chatroom.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Chatroom.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Chatroom.DataCase
    end
  end

  setup tags do
    Chatroom.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Chatroom.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  def errors_on(changeset) do
    # ... returns map of field => [error messages]
  end
end
```

The sandbox ensures:

- Each test runs in a transaction
- The transaction is rolled back after the test
- Tests are isolated from each other

---

## Testing CRUD Operations

### Create

```elixir
describe "create_message/1" do
  test "creates message with valid attributes" do
    attrs = %{username: "alice", body: "Hello!"}

    assert {:ok, message} = Chat.create_message(attrs)
    assert message.username == "alice"
    assert message.body == "Hello!"
    assert message.id != nil
    assert message.inserted_at != nil
  end

  test "fails with missing username" do
    attrs = %{body: "Hello!"}

    assert {:error, changeset} = Chat.create_message(attrs)
    assert "can't be blank" in errors_on(changeset).username
  end

  test "fails with empty body" do
    attrs = %{username: "alice", body: ""}

    assert {:error, changeset} = Chat.create_message(attrs)
    assert "can't be blank" in errors_on(changeset).body
  end

  test "fails with body too long" do
    attrs = %{username: "alice", body: String.duplicate("a", 501)}

    assert {:error, changeset} = Chat.create_message(attrs)
    assert "should be at most 500 character(s)" in errors_on(changeset).body
  end
end
```

### Read

```elixir
describe "list_messages/0" do
  test "returns empty list when no messages" do
    assert Chat.list_messages() == []
  end

  test "returns all messages" do
    msg1 = message_fixture(body: "First")
    msg2 = message_fixture(body: "Second")

    messages = Chat.list_messages()

    assert length(messages) == 2
    assert msg1 in messages
    assert msg2 in messages
  end

  test "returns messages in order" do
    msg1 = message_fixture(body: "First")
    # Ensure different timestamp
    :timer.sleep(10)
    msg2 = message_fixture(body: "Second")

    [first, second] = Chat.list_messages()

    assert first.id == msg1.id
    assert second.id == msg2.id
  end
end
```

### Update

```elixir
describe "update_message/2" do
  test "updates with valid attributes" do
    message = message_fixture()

    assert {:ok, updated} = Chat.update_message(message, %{body: "Updated"})
    assert updated.body == "Updated"
    assert updated.id == message.id
  end

  test "fails with invalid attributes" do
    message = message_fixture()

    assert {:error, changeset} = Chat.update_message(message, %{body: ""})
    refute changeset.valid?
  end
end
```

### Delete

```elixir
describe "delete_message/1" do
  test "deletes the message" do
    message = message_fixture()

    assert {:ok, deleted} = Chat.delete_message(message)
    assert deleted.id == message.id
    assert Chat.list_messages() == []
  end
end
```

---

## Testing with Associations

```elixir
describe "messages with users" do
  test "creates message with user association" do
    user = user_fixture()
    attrs = %{body: "Hello!", user_id: user.id}

    assert {:ok, message} = Chat.create_message(attrs)
    assert message.user_id == user.id
  end

  test "preloads user" do
    user = user_fixture()
    {:ok, message} = Chat.create_message(%{body: "Hello!", user_id: user.id})

    loaded = Chat.get_message!(message.id)
    assert loaded.user.id == user.id
  end
end
```

---

## Testing Business Rules

```elixir
describe "business rules" do
  test "users can only delete their own messages" do
    user1 = user_fixture()
    user2 = user_fixture()
    message = message_fixture(user_id: user1.id)

    assert {:error, :unauthorized} = Chat.delete_message(message, user2)
    assert {:ok, _} = Chat.delete_message(message, user1)
  end

  test "limits messages to 50 per request" do
    for _ <- 1..60, do: message_fixture()

    messages = Chat.list_messages()

    assert length(messages) == 50
  end
end
```

---

## Fixtures vs Factories

### Fixtures (simple)

```elixir
defp message_fixture(attrs \\ %{}) do
  {:ok, message} =
    attrs
    |> Enum.into(%{username: "test", body: "Hello"})
    |> Chat.create_message()

  message
end
```

### Factories (with ex_machina)

```elixir
# test/support/factory.ex
defmodule Chatroom.Factory do
  use ExMachina.Ecto, repo: Chatroom.Repo

  def message_factory do
    %Chatroom.Chat.Message{
      username: sequence(:username, &"user#{&1}"),
      body: "Test message"
    }
  end
end

# In tests
message = insert(:message, body: "Custom body")
```

---

## Next

Continue to [Testing LiveView](03-testing-liveview.md) to test real-time UI.
