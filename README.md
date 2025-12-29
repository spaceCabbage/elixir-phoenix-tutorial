# Elixir & Phoenix Tutorial

[![Elixir](https://img.shields.io/badge/Elixir-1.14+-4B275F?style=flat&logo=elixir&logoColor=white)](https://elixir-lang.org/)
[![Phoenix](https://img.shields.io/badge/Phoenix-1.7+-FD4F00?style=flat)](https://phoenixframework.org/)
[![LiveView](https://img.shields.io/badge/LiveView-Real--time-22c55e?style=flat)](https://hexdocs.pm/phoenix_live_view/)
[![License](https://img.shields.io/badge/License-PolyForm_NC-3b82f6?style=flat)](LICENSE)

**Build real-time apps with the language that powers Discord and WhatsApp.**

I created this tutorial because I wanted to learn Elixir and build real apps with it. Rather than keep my notes private, I decided to turn them into something that might help others too. This is my learning journey, documented as I go.

Browse the docs on GitHub or clone the repo for an AI-guided walkthrough if you are lazy and want to see how cool this is.

---

## Two Ways to Learn

### Option A: Browse the Docs

Read the documentation directly on GitHub:

**[Start Here: docs/README.md](docs/README.md)**

### Option B: AI-Guided Tutorial

Get an interactive, personalized walkthrough with Claude Code:

```bash
# 1. Clone the repo
git clone https://github.com/spaceCabbage/elixir-phoenix-tutorial.git
cd elixir-phoenix-tutorial

# 2. Install Claude Code (if you haven't)
# See: https://docs.anthropic.com/claude-code

# 3. Start the guided tutorial
claude
# Then type: begin
```

The AI will guide you through the curriculum, pause to check understanding, and let you explore the codebase at your own pace.

### VSCode Integration

If you're using VSCode with the [Claude Code extension](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code):

1. Open this repo in VSCode
2. Run the task: `Ctrl+Shift+P` → "Run Task" → "Start Elixir Tutorial"
3. Type `begin` in the Claude panel

**Optional keybinding:** Add this to your `keybindings.json` (`Ctrl+Shift+P` → "Open Keyboard Shortcuts (JSON)"):

```json
{
  "key": "ctrl+alt+t",
  "command": "workbench.action.tasks.runTask",
  "args": "Start Elixir Tutorial"
}
```

Then press `Ctrl+Alt+T` to open Claude instantly.

---

## Quick Start

```bash
mix deps.get          # Install dependencies
mix ecto.create       # Create database
mix ecto.migrate      # Run migrations
iex -S mix phx.server # Start with interactive shell
```

Visit [http://localhost:4000](http://localhost:4000)

---

## What You'll Learn

| Section                                             | Topics                                        | Time    |
|-----------------------------------------------------|-----------------------------------------------|---------|
| [Getting Started](docs/00-getting-started/)         | Installation, editor setup, IEx               | 30 min  |
| [Erlang Primer](docs/00b-erlang-primer/)            | BEAM VM, OTP, why Elixir exists               | 30 min  |
| [Elixir Fundamentals](docs/01-elixir-fundamentals/) | Pattern matching, pipes, functions, processes | 2-3 hrs |
| [OTP Fundamentals](docs/02-otp-fundamentals/)       | GenServer, Supervisors, fault tolerance       | 1-2 hrs |
| [Phoenix Framework](docs/03-phoenix-framework/)     | Request lifecycle, routing, contexts          | 1-2 hrs |
| [Ecto Database](docs/04-ecto-database/)             | Schemas, changesets, queries                  | 1-2 hrs |
| [LiveView](docs/05-liveview/)                       | Real-time UI, events, PubSub                  | 1-2 hrs |
| [This Codebase](docs/06-this-codebase/)             | Guided tour, exercises                        | 2-3 hrs |
| [Testing](docs/07-testing/)                         | ExUnit, testing patterns                      | 1 hr    |

**Total: 10-15 hours**

For a condensed overview, see the [Crash Course](docs/00-crash-course.md).

---

## What is Phoenix Good For?

Phoenix excels at **real-time, high-concurrency applications**:

- **Chat & messaging** - WhatsApp-scale connections
- **Live dashboards** - Stock tickers, analytics, monitoring
- **Collaborative tools** - Google Docs-style real-time editing
- **IoT backends** - Millions of connected devices
- **APIs** - High-throughput, low-latency services

**Notable users:** Discord (150M+ users), Bleacher Report (reduced 150 servers to 5), Toyota Connected, Pinterest.

---

## Deployment

Phoenix apps typically deploy to:

- **[Fly.io](https://fly.io/docs/elixir/)** - Official recommendation, run `fly launch`
- **[Gigalixir](https://gigalixir.com/)** - Elixir-specific PaaS
- **Docker** - Standard containerization
- **Bare metal** - Elixir releases with `mix release`

---

## Resources

- [Elixir Docs](https://hexdocs.pm/elixir/)
- [Phoenix Docs](https://hexdocs.pm/phoenix/)
- [LiveView Docs](https://hexdocs.pm/phoenix_live_view/)
- [Ecto Docs](https://hexdocs.pm/ecto/)
- [Elixir School](https://elixirschool.com/)
- [Elixir Forum](https://elixirforum.com/)

---

## License

[PolyForm Noncommercial 1.0.0](LICENSE)

You can use this for learning and personal projects. For commercial use, reach out.
