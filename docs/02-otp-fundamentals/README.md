# OTP Fundamentals

OTP (Open Telecom Platform) is the framework that makes Elixir applications reliable and scalable. It's the difference between a script and a production system.

---

## What You'll Learn

| File                                     | Topic              | Key Concepts                          |
| ---------------------------------------- | ------------------ | ------------------------------------- |
| [01. What is OTP](./01-what-is-otp.md)   | Overview           | Why OTP matters, core concepts        |
| [02. GenServer](./02-genserver.md)       | Stateful processes | State, calls, casts, callbacks        |
| [03. Supervisors](./03-supervisors.md)   | Fault tolerance    | Restart strategies, supervision trees |
| [04. Applications](./04-applications.md) | System packaging   | Application module, configuration     |

---

## Why OTP Matters

You've learned that Elixir processes are:

- Lightweight
- Isolated
- Communicate via messages

OTP provides **battle-tested patterns** for:

- Managing process state (GenServer)
- Handling failures automatically (Supervisors)
- Organizing processes (Applications)

Without OTP, you'd write error-prone boilerplate. With OTP, you get decades of Ericsson's telecom reliability engineering for free.

---

## The Big Picture

```
┌─────────────────────────────────────────────────────────┐
│                     Application                          │
│  (Your app - Chatroom)                                  │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Root Supervisor                      │    │
│  │  (Chatroom.Supervisor)                           │    │
│  └────────────────────┬─────────────────────────────┘    │
│                       │                                  │
│          ┌────────────┼───────────────┐                  │
│          ▼            ▼               ▼                  │
│    ┌──────────┐ ┌──────────┐  ┌──────────────┐          │
│    │  Repo    │ │  PubSub  │  │   Endpoint   │          │
│    │(GenServer│ │(GenServer│  │ (Supervisor) │          │
│    │ Pool)    │ │  )       │  │              │          │
│    └──────────┘ └──────────┘  └──────┬───────┘          │
│                                      │                   │
│                               ┌──────┴──────┐            │
│                               ▼             ▼            │
│                         LiveView       LiveView          │
│                         Process        Process           │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## In This Codebase

See OTP in action:

```elixir
# lib/chatroom/application.ex - The supervision tree
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
```

When you run `mix phx.server`:

1. The Application starts
2. The Supervisor starts its children
3. Each child (Repo, PubSub, Endpoint) is a GenServer or Supervisor
4. If any crashes, the Supervisor restarts it

---

## Prerequisites

Before starting:

1. Complete [Elixir Fundamentals](../01-elixir-fundamentals/)
2. Understand [Processes](../01-elixir-fundamentals/09-processes.md)
3. Have a running Phoenix app (`iex -S mix phx.server`)

---

## Time Estimate

- **Quick pass**: 1 hour
- **Thorough study**: 2-3 hours
- **Building your own GenServers**: Practice time

---

**Start:** [What is OTP →](./01-what-is-otp.md)
