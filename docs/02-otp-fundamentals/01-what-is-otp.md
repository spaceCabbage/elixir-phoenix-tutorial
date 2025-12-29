# What is OTP?

OTP stands for "Open Telecom Platform" - a misleading name for what's essentially "Design Patterns for Concurrent Systems."

---

## The Origin

OTP was developed at Ericsson in the 1990s for building telephone switches. These systems needed:

- **99.9999999% uptime** (9 nines = 32ms downtime per year)
- **Millions of concurrent calls** (one process per call)
- **Hot code upgrades** (update without dropping calls)
- **Fault isolation** (one call crashing doesn't affect others)

OTP is the codified wisdom of building such systems.

---

## What OTP Provides

### 1. Behaviours

Standard interfaces for common patterns:

| Behaviour     | Purpose          | You Implement                                       |
| ------------- | ---------------- | --------------------------------------------------- |
| `GenServer`   | Stateful server  | `init`, `handle_call`, `handle_cast`, `handle_info` |
| `Supervisor`  | Process monitor  | `init` with child specs                             |
| `Application` | System component | `start`, optional `stop`                            |
| `GenStage`    | Data pipeline    | `handle_demand`, `handle_events`                    |

### 2. Supervisors

Automatic restart strategies when things crash.

### 3. Applications

Package processes, config, and dependencies together.

### 4. Standard Libraries

ETS, Mnesia, debugging tools, etc.

---

## The "Let It Crash" Philosophy

Traditional programming:

```python
# Python - defensive programming
def divide(a, b):
    if b == 0:
        return None, "division by zero"
    return a / b, None
```

OTP philosophy:

```elixir
# Elixir - let it crash
def divide(a, b), do: a / b

# If b is 0, the process crashes
# A supervisor restarts it
# The system continues
```

Why this works:

1. **Crashes are isolated** - Only the crashed process dies
2. **Supervisors are watching** - They restart crashed processes
3. **State is recoverable** - Restart from known good state
4. **Code is simpler** - No error checking clutter

---

## GenServer: The Foundation

Most OTP patterns are built on GenServer. It handles:

- **State management** - Keep state between calls
- **Synchronous calls** - Request/response (client waits)
- **Asynchronous casts** - Fire and forget
- **Other messages** - Handle arbitrary messages

```elixir
# The pattern GenServer implements for you:
def loop(state) do
  receive do
    {:call, from, request} ->
      {reply, new_state} = handle_request(request, state)
      send(from, reply)
      loop(new_state)

    {:cast, request} ->
      new_state = handle_async(request, state)
      loop(new_state)
  end
end
```

You don't write this boilerplate - GenServer does it.

---

## Supervision: Fault Tolerance

Supervisors monitor processes and restart them when they crash:

```
Supervisor
    │
    ├── Worker A (crashes!)
    │       ↓
    │   Supervisor notices
    │       ↓
    │   Restarts Worker A
    │
    ├── Worker B (unaffected)
    └── Worker C (unaffected)
```

### Supervision Strategies

| Strategy        | Behavior                                       |
| --------------- | ---------------------------------------------- |
| `:one_for_one`  | Restart only the crashed child                 |
| `:one_for_all`  | Restart all children if any crashes            |
| `:rest_for_one` | Restart crashed child and all started after it |

---

## Applications: Packaging

An OTP Application bundles:

- Supervision tree
- Configuration
- Dependencies
- Start/stop logic

When you run `mix phx.server`, it starts the `:chatroom` application, which starts the supervision tree, which starts all your processes.

---

## See It In Action

In IEx with your Phoenix app running:

```elixir
# See all running applications
iex> Application.started_applications()
[
  {:chatroom, 'chatroom', '0.1.0'},
  {:phoenix, 'phoenix', '1.7.0'},
  ...
]

# See supervision tree visually
iex> :observer.start()
# Click "Applications" tab, then "chatroom"

# List supervised processes
iex> Supervisor.which_children(Chatroom.Supervisor)
[
  {ChatroomWeb.Endpoint, #PID<0.500.0>, :supervisor, [ChatroomWeb.Endpoint]},
  {Phoenix.PubSub, #PID<0.400.0>, :supervisor, [Phoenix.PubSub.Supervisor]},
  {Chatroom.Repo, #PID<0.300.0>, :supervisor, [Chatroom.Repo]},
  ...
]
```

---

## OTP vs "Raw" Processes

| Without OTP                  | With OTP                          |
| ---------------------------- | --------------------------------- |
| Write your own receive loops | GenServer handles it              |
| Manual error handling        | Supervisors restart automatically |
| Ad-hoc process organization  | Structured supervision trees      |
| Custom message protocols     | Standard call/cast interface      |
| Reinvent debugging tools     | Use :observer, :sys, etc.         |

---

## The OTP Mindset

1. **Everything is a process** - State lives in processes
2. **Processes are cheap** - Don't hesitate to create them
3. **Let things crash** - Supervisors handle recovery
4. **Isolate failures** - Crashes shouldn't cascade
5. **Design for restart** - Processes should restart cleanly
6. **Supervision trees** - Organize processes hierarchically

---

## Key Takeaways

1. **OTP = patterns for building reliable concurrent systems**
2. **GenServer = standard way to build stateful processes**
3. **Supervisor = automatic restart on failures**
4. **Application = packaged component with supervision tree**
5. **"Let it crash"** - Simpler code, supervisors handle recovery

The next sections will dive deep into GenServer, Supervisors, and Applications.

---

**Next:** [GenServer →](./02-genserver.md)
