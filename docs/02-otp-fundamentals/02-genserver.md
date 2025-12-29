# GenServer

GenServer is the workhorse of OTP. It's a process that:

- Maintains state
- Handles synchronous requests (calls)
- Handles asynchronous requests (casts)
- Handles arbitrary messages (info)

---

## Basic GenServer

```elixir
defmodule Counter do
  use GenServer

  # Client API

  def start_link(initial_value \\ 0) do
    GenServer.start_link(__MODULE__, initial_value)
  end

  def increment(pid) do
    GenServer.call(pid, :increment)
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  # Server Callbacks

  @impl true
  def init(initial_value) do
    {:ok, initial_value}
  end

  @impl true
  def handle_call(:increment, _from, state) do
    new_state = state + 1
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
```

### Using It

```elixir
iex> {:ok, pid} = Counter.start_link(0)
{:ok, #PID<0.123.0>}

iex> Counter.get(pid)
0

iex> Counter.increment(pid)
1

iex> Counter.increment(pid)
2

iex> Counter.get(pid)
2
```

---

## The Callback Flow

```
Client                          GenServer Process
  │                                    │
  │  GenServer.call(pid, :get)         │
  │ ──────────────────────────────────>│
  │                                    │ handle_call(:get, from, state)
  │                                    │ returns {:reply, value, new_state}
  │<────────────────────────────────── │
  │  returns value                     │
```

---

## Key Callbacks

### `init/1` - Initialize State

```elixir
@impl true
def init(args) do
  # Called when GenServer starts
  # args comes from start_link

  {:ok, initial_state}           # Success
  {:ok, state, {:continue, :do_something}}  # Continue with another callback
  {:stop, reason}                # Stop immediately
end
```

### `handle_call/3` - Synchronous Requests

```elixir
@impl true
def handle_call(request, from, state) do
  # Client waits for response

  {:reply, response, new_state}           # Reply and continue
  {:reply, response, new_state, timeout}  # Reply with timeout
  {:noreply, new_state}                   # Don't reply yet (reply later)
  {:stop, reason, response, new_state}    # Stop after replying
end
```

### `handle_cast/2` - Asynchronous Requests

```elixir
@impl true
def handle_cast(request, state) do
  # Fire and forget - no response

  {:noreply, new_state}           # Continue
  {:noreply, new_state, timeout}  # Continue with timeout
  {:stop, reason, new_state}      # Stop
end
```

### `handle_info/2` - Other Messages

```elixir
@impl true
def handle_info(msg, state) do
  # Handles non-call/cast messages
  # Process.send_after, :timer messages, etc.

  {:noreply, new_state}
end
```

---

## Call vs Cast

|          | Call (`GenServer.call`) | Cast (`GenServer.cast`) |
| -------- | ----------------------- | ----------------------- |
| Returns  | Response value          | `:ok` immediately       |
| Blocking | Yes (waits for reply)   | No (fire and forget)    |
| Use when | Need the result         | Don't need confirmation |
| Example  | `get_value()`           | `log_event(data)`       |

```elixir
# Call - waits for response
def get(pid), do: GenServer.call(pid, :get)

# Cast - returns immediately
def reset(pid), do: GenServer.cast(pid, :reset)
```

---

## Named GenServers

Instead of passing PIDs around, register with a name:

```elixir
defmodule Counter do
  use GenServer

  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def increment do
    GenServer.call(__MODULE__, :increment)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  # ... callbacks
end
```

```elixir
iex> Counter.start_link(0)
iex> Counter.increment()
1
iex> Counter.get()
1
```

---

## Real-World Example: Cache

```elixir
defmodule Cache do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def put(key, value, ttl \\ :infinity) do
    GenServer.cast(__MODULE__, {:put, key, value, ttl})
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  # Server Callbacks

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_cast({:put, key, value, ttl}, state) do
    if ttl != :infinity do
      Process.send_after(self(), {:expire, key}, ttl)
    end
    {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  @impl true
  def handle_info({:expire, key}, state) do
    {:noreply, Map.delete(state, key)}
  end
end
```

```elixir
iex> Cache.start_link(name: Cache)
iex> Cache.put(:user_1, %{name: "Alice"}, 5000)  # Expires in 5s
iex> Cache.get(:user_1)
%{name: "Alice"}

# Wait 5 seconds...
iex> Cache.get(:user_1)
nil
```

---

## Handling Timeouts

### Reply Timeout

```elixir
# Default timeout is 5000ms (5 seconds)
GenServer.call(pid, :request)

# Custom timeout
GenServer.call(pid, :request, 10_000)  # 10 seconds
GenServer.call(pid, :request, :infinity)
```

### Process Timeout

```elixir
@impl true
def init(state) do
  {:ok, state, 5000}  # Timeout after 5 seconds of inactivity
end

@impl true
def handle_info(:timeout, state) do
  # Called when no messages for 5 seconds
  {:noreply, state, 5000}  # Reset timeout
end
```

---

## Child Spec for Supervisors

GenServers need a child spec to be supervised:

```elixir
defmodule Counter do
  use GenServer

  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  # Customize child_spec if needed
  def child_spec(initial) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [initial]},
      restart: :permanent
    }
  end

  # ... callbacks
end
```

Then in supervisor:

```elixir
children = [
  {Counter, 0}  # Calls Counter.start_link(0)
]
```

---

## Debugging GenServers

```elixir
# Get state (for debugging only!)
:sys.get_state(pid)

# Trace calls
:sys.trace(pid, true)

# Get status
:sys.get_status(pid)

# In Observer
:observer.start()
```

---

## Try It

```elixir
# Build a Stack GenServer
defmodule Stack do
  use GenServer

  def start_link(initial \\ []) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def push(item), do: GenServer.cast(__MODULE__, {:push, item})
  def pop, do: GenServer.call(__MODULE__, :pop)
  def peek, do: GenServer.call(__MODULE__, :peek)

  @impl true
  def init(initial), do: {:ok, initial}

  @impl true
  def handle_cast({:push, item}, stack) do
    {:noreply, [item | stack]}
  end

  @impl true
  def handle_call(:pop, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_call(:peek, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:peek, _from, [head | _] = stack) do
    {:reply, head, stack}
  end
end

iex> Stack.start_link()
iex> Stack.push(1)
iex> Stack.push(2)
iex> Stack.push(3)
iex> Stack.pop()
3
iex> Stack.peek()
2
```

---

## Common Patterns

### Periodic Work

```elixir
@impl true
def init(state) do
  schedule_work()
  {:ok, state}
end

@impl true
def handle_info(:work, state) do
  # Do periodic work
  new_state = do_work(state)
  schedule_work()
  {:noreply, new_state}
end

defp schedule_work do
  Process.send_after(self(), :work, 60_000)  # Every minute
end
```

### State Recovery

```elixir
@impl true
def init(_) do
  # Recover state from database/file
  state = load_from_db()
  {:ok, state}
end

@impl true
def terminate(_reason, state) do
  # Save state before stopping
  save_to_db(state)
  :ok
end
```

---

## Key Takeaways

1. **`use GenServer`** - Brings in all the machinery
2. **Client API** - Functions that call GenServer.call/cast
3. **Server callbacks** - `init`, `handle_call`, `handle_cast`, `handle_info`
4. **Call = synchronous** - Client waits for response
5. **Cast = asynchronous** - Fire and forget
6. **Name registration** - Use atoms instead of PIDs
7. **State in return tuples** - `{:reply, response, new_state}`

---

**Next:** [Supervisors →](./03-supervisors.md)
