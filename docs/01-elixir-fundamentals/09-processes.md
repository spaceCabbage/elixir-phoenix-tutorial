# Processes

Processes are the foundation of concurrency in Elixir. Everything runs in processes - even `iex` is a process.

---

## What Are Processes?

- NOT operating system processes
- Extremely lightweight (~2KB initial memory)
- Isolated memory - no shared state
- Communicate via message passing
- Managed by the BEAM VM

```elixir
# See your current process
iex> self()
#PID<0.110.0>

# Count existing processes
iex> length(Process.list())
73
```

---

## Spawning Processes

### Basic Spawn

```elixir
# spawn/1 - run anonymous function in new process
spawn(fn -> IO.puts("Hello from new process!") end)
# Output: Hello from new process!
# Returns: #PID<0.123.0>

# spawn/3 - run module function
spawn(IO, :puts, ["Hello from new process!"])
```

### Process Independence

```elixir
# Processes are independent
spawn(fn ->
  :timer.sleep(5000)
  IO.puts("Done after 5 seconds")
end)

IO.puts("This prints immediately")
# Output:
# This prints immediately
# (5 seconds later)
# Done after 5 seconds
```

---

## Message Passing

Processes communicate by sending and receiving messages.

### Send and Receive

```elixir
# send/2 - send message to process
send(self(), :hello)

# receive/1 - wait for message
receive do
  :hello -> "Got hello!"
  :world -> "Got world!"
after
  1000 -> "Timeout after 1 second"
end
```

### Practical Example

```elixir
# Parent spawns child, child sends back result
parent = self()

spawn(fn ->
  result = expensive_computation()
  send(parent, {:result, result})
end)

# Parent waits for result
receive do
  {:result, value} -> IO.puts("Got: #{value}")
after
  5000 -> IO.puts("Timeout!")
end
```

### Bidirectional Communication

```elixir
defmodule Calculator do
  def start do
    spawn(fn -> loop() end)
  end

  defp loop do
    receive do
      {:add, a, b, caller} ->
        send(caller, {:result, a + b})
        loop()

      {:multiply, a, b, caller} ->
        send(caller, {:result, a * b})
        loop()

      :stop ->
        IO.puts("Stopping")
    end
  end
end

# Usage
iex> calc = Calculator.start()
#PID<0.123.0>

iex> send(calc, {:add, 5, 3, self()})
iex> receive do {:result, x} -> x end
8

iex> send(calc, {:multiply, 4, 7, self()})
iex> receive do {:result, x} -> x end
28

iex> send(calc, :stop)
```

---

## Process State

Processes maintain state through recursion:

```elixir
defmodule Counter do
  def start(initial_value \\ 0) do
    spawn(fn -> loop(initial_value) end)
  end

  defp loop(count) do
    receive do
      :increment ->
        loop(count + 1)

      :decrement ->
        loop(count - 1)

      {:get, caller} ->
        send(caller, {:count, count})
        loop(count)

      :stop ->
        :ok
    end
  end

  # Client API
  def increment(pid), do: send(pid, :increment)
  def decrement(pid), do: send(pid, :decrement)

  def get(pid) do
    send(pid, {:get, self()})
    receive do
      {:count, count} -> count
    end
  end
end
```

```elixir
iex> counter = Counter.start(0)
iex> Counter.increment(counter)
iex> Counter.increment(counter)
iex> Counter.get(counter)
2
iex> Counter.decrement(counter)
iex> Counter.get(counter)
1
```

**Note:** This is exactly what GenServer does - but with better tooling. See [OTP Fundamentals](../02-otp-fundamentals/).

---

## Process Links

Links connect processes - when one dies, linked processes die too:

```elixir
# spawn_link - link child to parent
spawn_link(fn ->
  raise "Crash!"
end)
# Parent crashes too!

# spawn - no link, parent continues
spawn(fn ->
  raise "Crash!"
end)
# Parent is fine
```

### Why Link?

Links are the foundation of supervision. When a worker crashes:

1. Its supervisor is notified (via link)
2. Supervisor decides what to do
3. Usually: restart the worker

---

## Process Monitoring

Monitors are one-way - you watch a process without dying if it crashes:

```elixir
pid = spawn(fn -> :timer.sleep(1000) end)
ref = Process.monitor(pid)

receive do
  {:DOWN, ^ref, :process, ^pid, reason} ->
    IO.puts("Process died: #{inspect(reason)}")
end
```

### Links vs Monitors

| Feature   | Link              | Monitor                     |
| --------- | ----------------- | --------------------------- |
| Direction | Bidirectional     | One-way                     |
| On crash  | Both die          | Receive message             |
| Use case  | Supervision trees | Watching external processes |

---

## Process Registration

Give processes names for easy reference:

```elixir
# Register with atom name
pid = spawn(fn -> loop() end)
Process.register(pid, :my_process)

# Send by name
send(:my_process, :hello)

# Or use name option in spawn
GenServer.start_link(MyServer, [], name: :my_server)
```

---

## Process Dictionary

Each process has a private dictionary (use sparingly):

```elixir
Process.put(:key, "value")
Process.get(:key)  # "value"
Process.delete(:key)
```

**Warning:** Process dictionary is discouraged - use GenServer state instead.

---

## Concurrent Processing

### Parallel Map

```elixir
defmodule Parallel do
  def map(collection, func) do
    collection
    |> Enum.map(&spawn_task(&1, func))
    |> Enum.map(&await_result/1)
  end

  defp spawn_task(item, func) do
    parent = self()
    spawn(fn -> send(parent, {self(), func.(item)}) end)
  end

  defp await_result(pid) do
    receive do
      {^pid, result} -> result
    end
  end
end

# Usage (processes work in parallel)
Parallel.map([1, 2, 3, 4], fn x ->
  :timer.sleep(1000)  # Simulate slow operation
  x * 2
end)
# Returns [2, 4, 6, 8] after ~1 second (not 4 seconds)
```

### Task Module (Better Way)

```elixir
# Simple async/await
task = Task.async(fn -> expensive_computation() end)
# Do other work...
result = Task.await(task)

# Parallel map (built-in)
Task.async_stream([1, 2, 3, 4], fn x ->
  :timer.sleep(1000)
  x * 2
end)
|> Enum.to_list()
# [{:ok, 2}, {:ok, 4}, {:ok, 6}, {:ok, 8}]
```

---

## Process Inspection

```elixir
pid = spawn(fn -> :timer.sleep(60_000) end)

# Get process info
Process.info(pid)
# [current_function: {:timer, :sleep, 1}, ...]

Process.info(pid, :memory)
# {:memory, 2688}

Process.info(pid, :message_queue_len)
# {:message_queue_len, 0}

# Check if alive
Process.alive?(pid)
# true
```

---

## Try It

```elixir
# Basic spawn and message
iex> pid = spawn(fn ->
...>   receive do
...>     {sender, msg} -> send(sender, "Echo: #{msg}")
...>   end
...> end)
iex> send(pid, {self(), "Hello!"})
iex> receive do msg -> msg end

# Counter process
iex> c "examples of Counter module above"
iex> counter = Counter.start(10)
iex> Counter.increment(counter)
iex> Counter.get(counter)

# Task.async
iex> task = Task.async(fn ->
...>   :timer.sleep(2000)
...>   "Done!"
...> end)
iex> IO.puts("Waiting...")
iex> Task.await(task)
```

---

## Key Takeaways

1. **Processes are lightweight** - Create thousands without worry
2. **Isolated memory** - No shared state, no locks
3. **Message passing** - `send` and `receive`
4. **State via recursion** - Loop with updated state
5. **Links connect processes** - Crash together
6. **Monitors observe processes** - Get notified of crashes
7. **Task for simple parallelism** - `Task.async` / `Task.await`

This is the foundation. OTP (GenServer, Supervisors) builds on these primitives to make building reliable systems easier.

---

**You've completed Elixir Fundamentals!**

**Next section:** [OTP Fundamentals →](../02-otp-fundamentals/)
