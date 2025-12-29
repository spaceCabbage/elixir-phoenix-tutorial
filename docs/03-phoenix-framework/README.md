# Phoenix Framework

Phoenix is a web framework for Elixir. It's like Rails, but built on the solid foundation of Erlang/OTP for extreme performance and reliability.

---

## What You'll Learn

| File                                     | Topic            | Key Concepts               |
| ---------------------------------------- | ---------------- | -------------------------- |
| [01. Architecture](./01-architecture.md) | The big picture  | Request lifecycle, layers  |
| [02. Endpoint](./02-endpoint.md)         | HTTP entry point | Plugs, WebSockets          |
| [03. Router](./03-router.md)             | URL mapping      | Routes, pipelines, scopes  |
| [04. Controllers](./04-controllers.md)   | Request/Response | Actions, params, responses |
| [05. Contexts](./05-contexts.md)         | Business logic   | Boundaries, data access    |
| [06. Templates](./06-templates.md)       | HTML rendering   | HEEx, components           |

---

## Why Phoenix?

| Feature            | Benefit                            |
| ------------------ | ---------------------------------- |
| Built on Erlang VM | Handle millions of connections     |
| LiveView           | Real-time UI without JavaScript    |
| Channels           | WebSocket-based real-time features |
| PubSub             | Built-in message broadcasting      |
| Ecto integration   | First-class database support       |
| Hot code reloading | Instant dev feedback               |

---

## In This Codebase

The chat application demonstrates Phoenix's key features:

```
lib/
├── chatroom/                    # Business logic (contexts)
│   ├── application.ex           # OTP application
│   ├── repo.ex                  # Database connection
│   ├── chat.ex                  # Chat context
│   └── chat/
│       └── message.ex           # Message schema
│
└── chatroom_web/                # Web layer
    ├── endpoint.ex              # HTTP entry point
    ├── router.ex                # URL routing
    ├── live/
    │   └── chat_live.ex         # LiveView (real-time UI)
    ├── controllers/             # Traditional controllers
    ├── components/
    │   └── core_components.ex   # Reusable UI components
    └── templates/               # HTML templates
```

---

## Request Flow

```
Browser Request
      │
      ▼
┌─────────────────────┐
│     Endpoint        │  ← Plug pipeline: parsing, sessions, static files
│  (endpoint.ex)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│      Router         │  ← Match URL to controller/LiveView
│   (router.ex)       │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
Controller    LiveView
  │               │
  ▼               ▼
Context ←─────→ Context     ← Business logic
  │               │
  ▼               ▼
Repo ←─────────→ Repo       ← Database
  │               │
  ▼               ▼
Response      WebSocket
(HTML/JSON)   (Real-time)
```

---

## Key Concepts

### Plugs

Everything in Phoenix is a Plug - a specification for composable modules that handle HTTP connections.

```elixir
# A plug is a function or module that takes a conn and returns a conn
conn
|> Plug.Conn.put_status(:ok)
|> Plug.Conn.put_resp_content_type("text/html")
|> Plug.Conn.send_resp(200, "<h1>Hello</h1>")
```

### Contexts

Contexts group related functionality. They're boundaries between your web layer and business logic.

```elixir
# Don't do this in controllers
Repo.insert(%Message{body: body})

# Do this - use contexts
Chat.create_message(%{body: body})
```

### LiveView

Server-rendered real-time UI. No JavaScript needed.

```elixir
defmodule ChatroomWeb.ChatLive do
  use ChatroomWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :messages, Chat.list_messages())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= for msg <- @messages do %>
        <p><%= msg.body %></p>
      <% end %>
    </div>
    """
  end
end
```

---

## Prerequisites

Before starting:

1. Complete [OTP Fundamentals](../02-otp-fundamentals/)
2. Have the chat app running (`iex -S mix phx.server`)
3. Open `lib/chatroom_web/` in your editor

---

## Time Estimate

- **Quick pass**: 1-2 hours
- **Thorough study**: 3-4 hours
- **Building features**: Practice time

---

## Key Files to Reference

| File                                                                           | Purpose          |
| ------------------------------------------------------------------------------ | ---------------- |
| [lib/chatroom_web/endpoint.ex](../../lib/chatroom_web/endpoint.ex)             | HTTP entry point |
| [lib/chatroom_web/router.ex](../../lib/chatroom_web/router.ex)                 | URL routing      |
| [lib/chatroom_web/live/chat_live.ex](../../lib/chatroom_web/live/chat_live.ex) | LiveView example |
| [lib/chatroom/chat.ex](../../lib/chatroom/chat.ex)                             | Context example  |

---

**Start:** [Architecture →](./01-architecture.md)
