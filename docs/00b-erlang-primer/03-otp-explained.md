# OTP Explained: The Secret Sauce

OTP is the most important thing you'll learn. It's the difference between "I wrote an Elixir script" and "I built a production system."

---

## What is OTP?

OTP stands for **Open Telecom Platform**, but that name is misleading. It's really a set of:

1. **Design patterns** for building concurrent applications
2. **Behaviours** (interfaces) that standardize those patterns
3. **Libraries** implementing common functionality
4. **Tools** for debugging, tracing, and monitoring

Think of OTP as "Design Patterns for Distributed Systems" - battle-tested solutions to problems you'll definitely encounter.

---

## The Three Key Concepts

| Concept         | What It Is                                           | When You Use It                 |
| --------------- | ---------------------------------------------------- | ------------------------------- |
| **GenServer**   | A process that holds state and handles requests      | User sessions, caches, counters |
| **Supervisor**  | A process that monitors and restarts other processes | Fault tolerance                 |
| **Application** | A packaged component with its own supervision tree   | Organizing your system          |

Everything else in OTP builds on these three concepts.

---

## GenServer: Stateful Processes

A GenServer is a process that:

- Holds state between calls
- Responds to synchronous requests (call)
- Handles asynchronous messages (cast)
- Manages its own lifecycle

### The Pattern

```elixir
defmodule Counter do
  use GenServer

  # Client API (called by other processes)

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def increment do
    GenServer.call(__MODULE__, :increment)
  end

  def get_value do
    GenServer.call(__MODULE__, :get_value)
  end

  # Server Callbacks (run inside the GenServer process)

  @impl true
  def init(initial_value) do
    {:ok, initial_value}  # initial_value becomes the state
  end

  @impl true
  def handle_call(:increment, _from, state) do
    new_state = state + 1
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:get_value, _from, state) do
    {:reply, state, state}
  end
end
```

### Using It

```elixir
iex> Counter.start_link(0)
{:ok, #PID<0.123.0>}

iex> Counter.get_value()
0

iex> Counter.increment()
1

iex> Counter.increment()
2

iex> Counter.get_value()
2
```

The state persists between calls because the GenServer process stays alive.

---

## Supervisor: Fault Tolerance

A Supervisor watches other processes and restarts them when they crash.

### Simple Example

```elixir
defmodule MyApp.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Counter, 0},           # Start Counter with initial value 0
      {AnotherWorker, []},    # Start another worker
    ]

    # :one_for_one means if one child crashes, only restart that one
    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

### Restart Strategies

| Strategy        | Behavior                                                |
| --------------- | ------------------------------------------------------- |
| `:one_for_one`  | Only restart the crashed child                          |
| `:one_for_all`  | Restart all children if any crashes                     |
| `:rest_for_one` | Restart crashed child and all children started after it |

### In Action

```elixir
# Counter is running
iex> Counter.get_value()
5

# Crash it deliberately
iex> Process.exit(Process.whereis(Counter), :kill)
true

# It's back! (Supervisor restarted it)
iex> Counter.get_value()
0  # Back to initial state
```

---

## Supervision Trees

Real applications have **nested supervisors** forming a tree:

```
                    Application
                         │
                    ┌────┴────┐
                    │ Root    │
                    │Supervisor│
                    └────┬────┘
           ┌─────────────┼─────────────┐
           ▼             ▼             ▼
    ┌──────────┐  ┌──────────┐  ┌──────────┐
    │ Database │  │   Web    │  │Background│
    │Supervisor│  │Supervisor│  │ Workers  │
    └────┬─────┘  └────┬─────┘  └────┬─────┘
         │             │              │
    ┌────┴────┐   ┌────┴────┐   ┌────┴────┐
    │ Repo    │   │ Endpoint│   │ Worker1 │
    │ Pool    │   │ PubSub  │   │ Worker2 │
    └─────────┘   └─────────┘   └─────────┘
```

When the chat app starts, look at `lib/chatroom/application.ex`:

```elixir
def start(_type, _args) do
  children = [
    ChatroomWeb.Telemetry,
    Chatroom.Repo,           # Database connection pool
    {Phoenix.PubSub, name: Chatroom.PubSub},  # Pub/Sub system
    ChatroomWeb.Endpoint,    # Web server
  ]

  opts = [strategy: :one_for_one, name: Chatroom.Supervisor]
  Supervisor.start_link(children, opts)
end
```

Each of these children might have their own supervisors and workers beneath them.

---

## Application: Packaging It All

An **Application** in OTP terms is:

- A component that can be started and stopped
- Has a supervision tree
- Declares its dependencies
- Configured in `mix.exs` and `config/`

When you run `mix phx.server`, it starts the `:chatroom` application, which starts the supervision tree, which starts all the processes.

---

## Why This Matters

Without OTP:

```elixir
# Naive approach - if database fails, everything dies
def start do
  database = start_database()
  webserver = start_webserver(database)
  # If start_webserver crashes, database is orphaned
end
```

With OTP:

```elixir
# Supervisor manages lifecycle
children = [
  DatabasePool,
  {Webserver, database: DatabasePool}
]
# If Webserver crashes, Supervisor restarts it
# If DatabasePool crashes, Supervisor restarts both (with :rest_for_one)
```

---

## Common OTP Behaviours

| Behaviour     | Purpose                            | Example                   |
| ------------- | ---------------------------------- | ------------------------- |
| `GenServer`   | Stateful server                    | Chat room, cache          |
| `Supervisor`  | Process monitoring                 | Restart crashed processes |
| `Application` | System component                   | Your Phoenix app          |
| `Task`        | One-off async work                 | Sending an email          |
| `Agent`       | Simple state wrapper               | Quick counter/cache       |
| `GenStage`    | Backpressure-aware data processing | Event pipelines           |

---

## Try It

In IEx with your Phoenix app running:

```elixir
# See the supervision tree
iex> :observer.start()
# Click "Applications" tab, then "chatroom"

# List all supervisors
iex> for {_, pid, :supervisor, _} <- Supervisor.which_children(Chatroom.Supervisor) do
...>   {pid, Process.info(pid, :registered_name)}
...> end

# See what the Repo supervisor manages
iex> Supervisor.which_children(Chatroom.Repo)
```

---

## The OTP Mindset

1. **Everything is a process** - State lives in processes
2. **Let it crash** - Write happy path, supervisors handle recovery
3. **Supervision trees** - Organize processes hierarchically
4. **Behaviours are contracts** - GenServer, Supervisor define the interface
5. **Links and monitors** - Processes know when others die

This is what makes Erlang/Elixir "fault-tolerant" - not that things don't crash, but that crashes are handled gracefully and automatically.

---

**Next:** [Elixir Interop →](./04-elixir-interop.md)
