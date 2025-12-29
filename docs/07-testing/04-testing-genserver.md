# Testing GenServer

Test stateful processes without flaky tests.

---

## Basic GenServer Test

```elixir
defmodule Chatroom.Examples.CounterTest do
  use ExUnit.Case, async: true

  alias Chatroom.Examples.Counter

  describe "Counter" do
    test "starts with initial value" do
      {:ok, pid} = Counter.start_link(initial: 5)

      assert Counter.get(pid) == 5
    end

    test "increments the value" do
      {:ok, pid} = Counter.start_link(initial: 0)

      Counter.increment(pid)

      assert Counter.get(pid) == 1
    end

    test "increments by specific amount" do
      {:ok, pid} = Counter.start_link(initial: 10)

      Counter.increment_by(pid, 5)

      assert Counter.get(pid) == 15
    end

    test "resets to zero" do
      {:ok, pid} = Counter.start_link(initial: 100)

      Counter.reset(pid)

      assert Counter.get(pid) == 0
    end
  end
end
```

---

## Using `start_supervised!/1`

Better process management in tests:

```elixir
defmodule CounterTest do
  use ExUnit.Case, async: true

  alias Chatroom.Examples.Counter

  setup do
    # Automatically stops the process after each test
    counter = start_supervised!({Counter, initial: 0})
    {:ok, counter: counter}
  end

  test "increment works", %{counter: counter} do
    Counter.increment(counter)
    assert Counter.get(counter) == 1
  end

  test "each test gets a fresh counter", %{counter: counter} do
    # This counter starts at 0, not affected by previous test
    assert Counter.get(counter) == 0
  end
end
```

---

## Testing Async Operations

### Testing `handle_cast`

Cast is async - you need to wait for it:

```elixir
test "async increment" do
  {:ok, pid} = Counter.start_link(initial: 0)

  # Cast is async
  Counter.async_increment(pid)

  # Bad: might check before the cast is processed
  # assert Counter.get(pid) == 1

  # Good: wait for the state to update
  assert eventually(fn -> Counter.get(pid) == 1 end)
end

defp eventually(func, attempts \\ 10) do
  if attempts == 0 do
    func.()
  else
    if func.() do
      true
    else
      Process.sleep(10)
      eventually(func, attempts - 1)
    end
  end
end
```

### Testing `handle_info`

```elixir
test "handles scheduled tick" do
  {:ok, pid} = TickingCounter.start_link(initial: 0)

  # Send a tick message directly
  send(pid, :tick)

  # Use sync call to ensure the message was processed
  assert TickingCounter.get(pid) == 1
end
```

---

## Testing Process Communication

```elixir
test "notifies subscribers" do
  {:ok, counter} = Counter.start_link(initial: 0)

  # Subscribe current test process
  Counter.subscribe(counter)

  # Trigger notification
  Counter.increment(counter)

  # Check we received the message
  assert_receive {:counter_updated, 1}, 1000
end
```

---

## Testing Crashes and Recovery

```elixir
test "restarts after crash" do
  # Start under a supervisor
  {:ok, sup} = Supervisor.start_link(
    [{Counter, name: :test_counter, initial: 100}],
    strategy: :one_for_one
  )

  # Verify initial state
  assert Counter.get(:test_counter) == 100

  # Kill the process
  Process.exit(Process.whereis(:test_counter), :kill)

  # Wait for restart
  Process.sleep(50)

  # Should be back with initial state
  assert Counter.get(:test_counter) == 100

  Supervisor.stop(sup)
end
```

---

## Testing with Mocks

Using Mox for dependency injection:

```elixir
# In config/test.exs
config :chatroom, :pubsub_module, Chatroom.MockPubSub

# Define mock
Mox.defmock(Chatroom.MockPubSub, for: Chatroom.PubSubBehaviour)

# In test
test "broadcasts on increment" do
  expect(Chatroom.MockPubSub, :broadcast, fn topic, message ->
    assert topic == "counter:updates"
    assert message == {:incremented, 1}
    :ok
  end)

  {:ok, counter} = Counter.start_link(initial: 0)
  Counter.increment(counter)

  verify!()
end
```

---

## Testing State Persistence

```elixir
test "loads state from storage" do
  # Setup: save state
  Storage.save(:counter, 42)

  # Start should load from storage
  {:ok, pid} = PersistentCounter.start_link(name: :counter)

  assert PersistentCounter.get(pid) == 42
end

test "saves state on update" do
  {:ok, pid} = PersistentCounter.start_link(name: :counter, initial: 0)

  PersistentCounter.increment(pid)

  # Verify saved
  assert Storage.load(:counter) == 1
end
```

---

## Avoiding Flaky Tests

### Don't Use Fixed Sleeps

```elixir
# Bad
Counter.async_increment(pid)
Process.sleep(100)
assert Counter.get(pid) == 1

# Good - use sync operations
Counter.increment(pid)  # sync call
assert Counter.get(pid) == 1

# Or poll with timeout
assert eventually(fn -> Counter.get(pid) == 1 end)
```

### Use Monitors Instead of Sleep

```elixir
test "process terminates" do
  {:ok, pid} = Counter.start_link(initial: 0)
  ref = Process.monitor(pid)

  Counter.stop(pid)

  assert_receive {:DOWN, ^ref, :process, ^pid, :normal}, 1000
end
```

### Isolate State

```elixir
# Bad - shared name
{:ok, _} = Counter.start_link(name: :counter)

# Good - unique per test
{:ok, pid} = Counter.start_link([])
# Or use start_supervised!
```

---

## Testing Tips

1. **Use `async: true`** when tests don't share state
2. **Use `start_supervised!/1`** for automatic cleanup
3. **Avoid fixed sleeps** - use sync calls or polling
4. **Test the public API** - not internal callbacks
5. **Use monitors** to detect process termination

---

## Next

Return to [This Codebase](../06-this-codebase/) to apply what you've learned with exercises.
