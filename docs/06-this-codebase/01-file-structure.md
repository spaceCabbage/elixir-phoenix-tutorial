# File Structure

Understanding where everything lives in a Phoenix project.

---

## The Big Picture

```
elixir-phoenix-tutorial/
|-- lib/
|   |-- chatroom/           # Business logic (Elixir)
|   |-- chatroom_web/       # Web layer (Phoenix)
|   |-- chatroom.ex         # Main module
|   +-- chatroom_web.ex     # Web helpers
|
|-- priv/
|   |-- repo/migrations/    # Database migrations
|   +-- static/             # Static files
|
|-- config/                 # Configuration
|-- test/                   # Tests
|-- docs/                   # This documentation
+-- mix.exs                 # Project definition
```

---

## The `lib/` Directory

This is where your Elixir code lives. Phoenix splits it into two parts:

### `lib/chatroom/` - Business Logic

```
lib/chatroom/
|-- application.ex          # OTP supervisor - starts everything
|-- repo.ex                 # Database connection pool
|-- chat.ex                 # Chat context - the public API
|-- chat/
|   +-- message.ex          # Message schema
+-- examples/
    |-- elixir_basics.ex    # Tutorial examples
    +-- genserver_example.ex
```

**Key insight:** This directory has NO web dependencies. You could use this code from a CLI, a different web framework, or a background job.

### `lib/chatroom_web/` - Web Layer

```
lib/chatroom_web/
|-- endpoint.ex             # HTTP entry point
|-- router.ex               # URL routing
|-- gettext.ex              # Internationalization
|-- telemetry.ex            # Metrics
|-- components/
|   |-- core_components.ex  # Reusable UI components
|   +-- layouts.ex          # Page layouts
|-- controllers/
|   |-- page_controller.ex  # Traditional controller
|   +-- page_html.ex        # View module
+-- live/
    +-- chat_live.ex        # LiveView for chat
```

**Key insight:** The web layer imports the business logic - never the reverse.

---

## The `config/` Directory

```
config/
|-- config.exs     # Base config, loaded first
|-- dev.exs        # Development overrides
|-- test.exs       # Test overrides
|-- prod.exs       # Production overrides
+-- runtime.exs    # Runtime config (env vars)
```

The config files are evaluated in order:

1. `config.exs` (compile-time)
2. `dev.exs` / `test.exs` / `prod.exs` (compile-time, based on MIX_ENV)
3. `runtime.exs` (at runtime, can read env vars)

---

## The `priv/` Directory

"priv" means "private to this application":

```
priv/
|-- repo/
|   |-- migrations/         # Database schema changes
|   +-- seeds.exs           # Seed data for development
+-- static/
    |-- favicon.ico
    +-- robots.txt
```

Migrations are timestamped:

```
20241229190000_create_messages.exs
^----------^ ^-----------------^
 timestamp    description
```

---

## Key Files Explained

### `mix.exs` - Project Definition

Like `package.json` for Node or `Gemfile` for Ruby:

```elixir
def project do
  [
    app: :chatroom,
    version: "0.1.0",
    elixir: "~> 1.14",
    deps: deps()
  ]
end

defp deps do
  [
    {:phoenix, "~> 1.7.0"},
    {:phoenix_live_view, "~> 0.20.0"},
    {:ecto_sql, "~> 3.10"},
    # ...
  ]
end
```

### `lib/chatroom.ex` - Main Module

Mostly just documentation. The real work happens in submodules.

### `lib/chatroom_web.ex` - Web Helpers

Defines macros used by controllers, views, and LiveViews:

```elixir
def live_view do
  quote do
    use Phoenix.LiveView
    # ... common imports
  end
end
```

When you write `use ChatroomWeb, :live_view`, this code gets injected.

---

## Convention Over Configuration

Phoenix follows conventions:

| If you want...  | Put it in...                         |
|-----------------|--------------------------------------|
| Business logic  | `lib/chatroom/`                      |
| Web routes      | `lib/chatroom_web/router.ex`         |
| LiveView        | `lib/chatroom_web/live/`             |
| Controllers     | `lib/chatroom_web/controllers/`      |
| Database schema | `lib/chatroom/<context>/<schema>.ex` |
| Migrations      | `priv/repo/migrations/`              |

---

## Try It

Open these files and explore:

```bash
# In your editor, open:
lib/chatroom/application.ex    # See what processes start
lib/chatroom_web/router.ex     # See how URLs map to code
lib/chatroom/chat.ex           # See the context API
```

In IEx:

```elixir
# List all modules
:application.get_key(:chatroom, :modules)

# See the supervision tree
:observer.start()  # Opens a GUI showing all processes
```

---

## Next

Continue to [Data Flow](02-data-flow.md) to see how a message travels through the system.
