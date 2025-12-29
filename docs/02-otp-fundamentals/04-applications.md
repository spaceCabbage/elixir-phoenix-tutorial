# Applications

An OTP Application packages your supervision tree, configuration, and dependencies into a startable component.

---

## What is an Application?

In OTP terms, an Application is:

- A component that can be started and stopped
- Has a supervision tree (usually)
- Declares its dependencies
- Can be configured via `config/`
- Can be included in releases

When you run `mix phx.server`, Mix starts the `:chatroom` application.

---

## The Application Module

```elixir
# lib/chatroom/application.ex
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

### The `start/2` Callback

Called when the application starts. Must return `{:ok, pid}` or `{:ok, pid, state}`.

Arguments:

- `type` - Usually `:normal` (or `:takeover`/`:failover` in distributed systems)
- `args` - From `mix.exs` `mod:` option (usually `[]`)

### The `stop/1` Callback

Called when the application stops. Optional.

```elixir
@impl true
def stop(_state) do
  # Cleanup logic
  :ok
end
```

---

## mix.exs Application Config

```elixir
# mix.exs
def application do
  [
    mod: {Chatroom.Application, []},  # Application module & args
    extra_applications: [:logger, :runtime_tools]  # Erlang apps to start
  ]
end
```

### Common Options

| Option               | Purpose                                        |
| -------------------- | ---------------------------------------------- |
| `mod`                | `{Module, args}` - Application callback module |
| `extra_applications` | OTP apps to start before yours                 |
| `applications`       | Deprecated - use deps instead                  |
| `env`                | Default config values                          |
| `registered`         | Names the app will register                    |

---

## Configuration

### config/config.exs

```elixir
# config/config.exs
import Config

config :chatroom,
  ecto_repos: [Chatroom.Repo]

config :chatroom, Chatroom.Repo,
  database: Path.expand("../chatroom_dev.db", __DIR__),
  pool_size: 5

config :chatroom, ChatroomWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [formats: [html: ChatroomWeb.ErrorHTML]]
```

### Accessing Config

```elixir
# Get config value
Application.get_env(:chatroom, :some_key)
Application.get_env(:chatroom, :some_key, "default")

# Get all config for an app
Application.get_all_env(:chatroom)

# Runtime config (in application.ex)
Application.fetch_env!(:chatroom, :required_key)
```

### Environment-Specific Config

```elixir
# config/dev.exs
import Config

config :chatroom, ChatroomWeb.Endpoint,
  debug_errors: true,
  code_reloader: true

# config/prod.exs
import Config

config :chatroom, ChatroomWeb.Endpoint,
  url: [host: "example.com", port: 443]
```

### Runtime Config

```elixir
# config/runtime.exs - read at startup, not compile time
import Config

if config_env() == :prod do
  config :chatroom, Chatroom.Repo,
    url: System.get_env("DATABASE_URL")
end
```

---

## Dependencies

Dependencies are also applications. Mix starts them automatically:

```elixir
# mix.exs
defp deps do
  [
    {:phoenix, "~> 1.7"},
    {:ecto_sqlite3, "~> 0.13"},
    {:phoenix_live_view, "~> 0.20"}
  ]
end
```

Start order is determined by dependency graph - `:phoenix` starts before your app because you depend on it.

---

## Application Environment

Each application has its own configuration namespace:

```elixir
# Set config for your app
config :chatroom, key: "value"
Application.get_env(:chatroom, :key)  # "value"

# Set config for a dependency
config :phoenix, :json_library, Jason
Application.get_env(:phoenix, :json_library)  # Jason
```

---

## Managing Applications

```elixir
# List all loaded applications
Application.loaded_applications()

# List all started applications
Application.started_applications()

# Start an application manually
Application.start(:crypto)

# Stop an application
Application.stop(:chatroom)

# Ensure an application is started
Application.ensure_all_started(:chatroom)
```

---

## See Applications in Action

```elixir
iex> Application.started_applications()
[
  {:chatroom, ~c"chatroom", ~c"0.1.0"},
  {:phoenix_live_view, ~c"phoenix_live_view", ~c"0.20.0"},
  {:phoenix, ~c"phoenix", ~c"1.7.0"},
  {:ecto, ~c"ecto", ~c"3.11.0"},
  ...
]

iex> Application.get_all_env(:chatroom)
[
  ecto_repos: [Chatroom.Repo],
  generators: [timestamp_type: :utc_datetime],
  ...
]

# Visual inspection
iex> :observer.start()
# Click "Applications" tab
```

---

## Application Lifecycle

```
1. mix phx.server
       │
       ▼
2. Mix reads mix.exs
       │
       ▼
3. Start dependency applications
   (phoenix, ecto, etc.)
       │
       ▼
4. Call Chatroom.Application.start/2
       │
       ▼
5. Supervisor.start_link(children, opts)
       │
       ▼
6. Children start (Repo, PubSub, Endpoint)
       │
       ▼
7. Application running!
```

---

## Without a Supervision Tree

Some applications don't need a supervisor:

```elixir
# mix.exs - no mod: option
def application do
  [
    extra_applications: [:logger]
  ]
end
```

This is for library applications that don't need long-running processes.

---

## Environment Compilation

Config files are compiled at different times:

| File                 | When         | Use For                        |
| -------------------- | ------------ | ------------------------------ |
| `config/config.exs`  | Compile time | Static config, imported files  |
| `config/dev.exs`     | Compile time | Dev-specific                   |
| `config/test.exs`    | Compile time | Test-specific                  |
| `config/prod.exs`    | Compile time | Prod defaults                  |
| `config/runtime.exs` | Runtime      | Environment variables, secrets |

---

## Release Configuration

For deployment with `mix release`:

```elixir
# config/runtime.exs
import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise "DATABASE_URL environment variable not set"

  config :chatroom, Chatroom.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE environment variable not set"

  config :chatroom, ChatroomWeb.Endpoint,
    secret_key_base: secret_key_base
end
```

---

## Try It

```elixir
# See your app's config
iex> Application.get_all_env(:chatroom)

# Check what's running
iex> Application.started_applications()

# Stop and start
iex> Application.stop(:chatroom)
iex> Application.start(:chatroom)

# Check the app spec
iex> Application.spec(:chatroom)

# View in observer
iex> :observer.start()
```

---

## Key Takeaways

1. **Applications package supervision trees** - Start/stop as units
2. **`start/2` callback** - Returns `{:ok, pid}` with supervisor
3. **Configuration in `config/`** - Accessed via `Application.get_env`
4. **Dependencies are applications** - Started before yours
5. **`runtime.exs`** - For environment variables and secrets
6. **Releases** - Bundle everything for deployment

---

**You've completed OTP Fundamentals!**

**Next section:** [Phoenix Framework →](../03-phoenix-framework/)
