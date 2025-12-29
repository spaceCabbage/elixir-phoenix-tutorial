# Supervisors

Supervisors are the key to fault tolerance. They watch processes and restart them when they crash.

---

## Basic Supervisor

```elixir
defmodule MyApp.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Counter, 0},
      {Cache, []},
      {Worker, :arg}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

### Using It

```elixir
iex> {:ok, sup} = MyApp.Supervisor.start_link(name: MyApp.Supervisor)
{:ok, #PID<0.200.0>}

iex> Supervisor.which_children(sup)
[
  {Worker, #PID<0.203.0>, :worker, [Worker]},
  {Cache, #PID<0.202.0>, :worker, [Cache]},
  {Counter, #PID<0.201.0>, :worker, [Counter]}
]
```

---

## Restart Strategies

### `:one_for_one`

If a child crashes, only restart that child.

```
Before crash:     After crash:
    Sup               Sup
   / | \             / | \
  A  B  C           A  B' C   (B crashed, restarted as B')
```

Use when: Children are independent.

### `:one_for_all`

If any child crashes, restart all children.

```
Before crash:     After crash:
    Sup               Sup
   / | \             / | \
  A  B  C           A' B' C'  (B crashed, all restarted)
```

Use when: Children depend on each other and should restart together.

### `:rest_for_one`

If a child crashes, restart it and all children started after it.

```
Before crash:     After crash:
    Sup               Sup
   / | \             / | \
  A  B  C           A  B' C'  (B crashed, B and C restarted)
```

Use when: Later children depend on earlier ones.

---

## Child Specifications

Tell the supervisor how to start and manage each child:

```elixir
%{
  id: Counter,                          # Unique identifier
  start: {Counter, :start_link, [0]},   # {Module, function, args}
  restart: :permanent,                   # Restart policy
  shutdown: 5000,                        # Shutdown timeout (ms)
  type: :worker                          # :worker or :supervisor
}
```

### Restart Options

| Option       | Behavior                      |
| ------------ | ----------------------------- |
| `:permanent` | Always restart (default)      |
| `:temporary` | Never restart                 |
| `:transient` | Restart only on abnormal exit |

### Shorthand

```elixir
# These are equivalent:
children = [
  Counter,           # Calls Counter.child_spec([])
  {Counter, 0},      # Calls Counter.child_spec(0)
  %{
    id: Counter,
    start: {Counter, :start_link, [0]}
  }
]
```

---

## Dynamic Supervisors

For when you don't know children at startup:

```elixir
defmodule MyApp.SessionSupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, opts)
  end

  def start_session(user_id) do
    spec = {Session, user_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
```

```elixir
iex> MyApp.SessionSupervisor.start_link(name: MyApp.SessionSupervisor)
iex> MyApp.SessionSupervisor.start_session("user_123")
{:ok, #PID<0.300.0>}
iex> MyApp.SessionSupervisor.start_session("user_456")
{:ok, #PID<0.301.0>}
```

---

## Supervision Trees

Real applications have nested supervisors:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      MyApp.Repo,                    # Database
      {Phoenix.PubSub, name: MyApp.PubSub},
      MyApp.SessionSupervisor,       # Dynamic supervisor
      MyAppWeb.Endpoint              # Web server
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

```
                MyApp.Supervisor
                    │
    ┌───────────────┼───────────────┬───────────────┐
    ▼               ▼               ▼               ▼
  Repo          PubSub        SessionSup        Endpoint
                              (Dynamic)
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
                Session      Session      Session
                user_1       user_2       user_3
```

---

## This Codebase: The Chat App

Look at `lib/chatroom/application.ex`:

```elixir
defmodule Chatroom.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChatroomWeb.Telemetry,
      Chatroom.Repo,
      {Phoenix.PubSub, name: Chatroom.PubSub},
      ChatroomWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Chatroom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChatroomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
```

### What Each Child Does

| Child       | Purpose                  | Type       |
| ----------- | ------------------------ | ---------- |
| `Telemetry` | Metrics collection       | Supervisor |
| `Repo`      | Database connection pool | Supervisor |
| `PubSub`    | Real-time messaging      | Supervisor |
| `Endpoint`  | HTTP/WebSocket server    | Supervisor |

---

## Handling Crashes

```elixir
# Crash a process and watch it restart
iex> pid = Process.whereis(Counter)
#PID<0.201.0>

iex> Process.exit(pid, :kill)
true

# It's back with a new PID!
iex> Process.whereis(Counter)
#PID<0.250.0>

# State is reset (starting fresh)
iex> Counter.get()
0
```

---

## Max Restarts

Prevent restart loops:

```elixir
Supervisor.init(children,
  strategy: :one_for_one,
  max_restarts: 3,    # Max restarts allowed
  max_seconds: 5      # In this time period
)
```

If a child crashes more than 3 times in 5 seconds, the supervisor itself crashes (and its supervisor handles it).

---

## Shutdown Order

When supervisor stops, children shut down in **reverse order**:

```elixir
children = [
  Database,        # Starts first, stops last
  Cache,           # Starts second, stops second
  WebServer        # Starts last, stops first
]
```

This ensures dependencies are respected.

---

## Try It

```elixir
# 1. Start the Phoenix app
iex> iex -S mix phx.server

# 2. See the supervision tree
iex> Supervisor.which_children(Chatroom.Supervisor)

# 3. Find a worker process
iex> pid = Process.whereis(Chatroom.PubSub)

# 4. Kill it
iex> Process.exit(pid, :kill)

# 5. See it restarted
iex> Process.whereis(Chatroom.PubSub)

# 6. Use Observer for visual inspection
iex> :observer.start()
# Go to Applications tab
```

---

## Common Patterns

### Top-Level Supervisor

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      MyApp.Repo,
      MyApp.Cache,
      MyApp.WorkerSupervisor,
      MyAppWeb.Endpoint
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: MyApp.Supervisor
    )
  end
end
```

### Worker Pool Supervisor

```elixir
defmodule MyApp.WorkerSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children =
      for i <- 1..10 do
        Supervisor.child_spec({Worker, i}, id: {Worker, i})
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

---

## Key Takeaways

1. **Supervisors watch processes** - Restart on crash
2. **`:one_for_one`** - Restart only crashed child (most common)
3. **`:one_for_all`** - Restart all if any crashes
4. **`:rest_for_one`** - Restart crashed and following children
5. **Supervision trees** - Nested supervisors for organization
6. **DynamicSupervisor** - When children aren't known at startup
7. **State is lost on restart** - Design for recovery

---

**Next:** [Applications →](./04-applications.md)
