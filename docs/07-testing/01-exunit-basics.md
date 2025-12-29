# ExUnit Basics

The fundamentals of testing in Elixir.

---

## Your First Test

```elixir
# test/my_test.exs
defmodule MyTest do
  use ExUnit.Case

  test "basic arithmetic" do
    assert 1 + 1 == 2
  end
end
```

Run it:

```bash
mix test test/my_test.exs
```

---

## Test Structure

```elixir
defmodule Chatroom.ChatTest do
  # Include ExUnit functionality
  use ExUnit.Case

  # For database tests, include DataCase
  use Chatroom.DataCase

  # Describe blocks group related tests
  describe "create_message/1" do
    test "with valid data creates a message" do
      attrs = %{username: "test", body: "Hello!"}
      assert {:ok, message} = Chat.create_message(attrs)
      assert message.username == "test"
      assert message.body == "Hello!"
    end

    test "with invalid data returns error changeset" do
      assert {:error, changeset} = Chat.create_message(%{})
      refute changeset.valid?
    end
  end
end
```

---

## Assertions

```elixir
# Equality
assert 1 + 1 == 2
assert "hello" == "hello"

# Pattern matching (powerful!)
assert {:ok, _message} = Chat.create_message(valid_attrs)
assert [first | _rest] = list

# Refute (opposite of assert)
refute 1 + 1 == 3
refute changeset.valid?

# Assert raise
assert_raise Ecto.NoResultsError, fn ->
  Repo.get!(Message, 999)
end

# Assert receive (for messages)
send(self(), :hello)
assert_receive :hello

# Assert received within timeout
assert_receive {:result, _}, 5000
```

---

## Setup

### Setup Block

Runs before each test in the module:

```elixir
defmodule MyTest do
  use ExUnit.Case

  setup do
    user = create_user()
    {:ok, user: user}
  end

  test "something with user", %{user: user} do
    assert user.name == "Test"
  end
end
```

### Setup All

Runs once for the entire module:

```elixir
setup_all do
  {:ok, pid} = start_supervised(MyServer)
  {:ok, server: pid}
end
```

### Named Setups

```elixir
setup :create_user
setup :create_messages

defp create_user(_context) do
  {:ok, user: %{name: "Test"}}
end

defp create_messages(%{user: user}) do
  {:ok, messages: [%{user: user, body: "Hello"}]}
end
```

---

## Tags

Skip, filter, or configure tests:

```elixir
@tag :slow
test "slow operation" do
  # ...
end

@tag :skip
test "not ready yet" do
  # ...
end

@tag timeout: 60_000
test "needs more time" do
  # ...
end
```

Run tagged tests:

```bash
# Only slow tests
mix test --only slow

# Exclude slow tests
mix test --exclude slow
```

---

## Async Tests

Tests can run in parallel:

```elixir
defmodule MyTest do
  use ExUnit.Case, async: true

  # These tests run concurrently with other async modules
end
```

Note: Database tests with `DataCase` use sandbox mode for isolation.

---

## Common Patterns

### Testing Pattern Matching

```elixir
test "returns {:ok, result} tuple" do
  assert {:ok, %Message{} = message} = Chat.create_message(valid_attrs)
  assert message.body == "Hello"
end
```

### Testing Errors

```elixir
test "returns {:error, changeset} for invalid data" do
  assert {:error, changeset} = Chat.create_message(%{})
  assert "can't be blank" in errors_on(changeset).body
end
```

### Testing Lists

```elixir
test "lists messages in order" do
  msg1 = insert_message(body: "First")
  msg2 = insert_message(body: "Second")

  messages = Chat.list_messages()

  assert [^msg1, ^msg2] = messages  # Pin operator for exact match
end
```

---

## The `errors_on/1` Helper

Defined in `test/support/data_case.ex`:

```elixir
def errors_on(changeset) do
  Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
    Regex.replace(~r"%{(\w+)}", message, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end)
end
```

Usage:

```elixir
errors = errors_on(changeset)
assert "can't be blank" in errors.username
assert "is invalid" in errors.email
```

---

## Running Tests

```bash
# All tests
mix test

# Specific file
mix test test/chatroom/chat_test.exs

# Specific line
mix test test/chatroom/chat_test.exs:15

# Watch mode (rerun on file change)
mix test --listen-on-stdin
# Then press Enter to rerun

# Verbose output
mix test --trace

# Stop on first failure
mix test --max-failures 1

# Only failed tests from last run
mix test --failed
```

---

## Next

Continue to [Testing Contexts](02-testing-contexts.md) to test your business logic.
