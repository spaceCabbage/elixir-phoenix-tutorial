# Learn Elixir & Phoenix

Welcome to the ultimate interactive tutorial for learning Elixir, Erlang, and the Phoenix Framework.

> **Who is this for?** Mid-to-senior developers who know at least one programming language and want to learn Elixir/Phoenix quickly and thoroughly.

---

## Learning Path

Follow these modules in order. Each builds on the previous.

| #   | Module                                           | Description                        | Est. Time |
| --- | ------------------------------------------------ | ---------------------------------- | --------- |
| 0   | [Getting Started](./00-getting-started/)         | Install Elixir, set up your editor | 30 min    |
| 0b  | [Erlang Primer](./00b-erlang-primer/)            | Understand the foundation          | 30 min    |
| 1   | [Elixir Fundamentals](./01-elixir-fundamentals/) | The language itself                | 2-3 hours |
| 2   | [OTP Fundamentals](./02-otp-fundamentals/)       | Processes, GenServer, Supervisors  | 1-2 hours |
| 3   | [Phoenix Framework](./03-phoenix-framework/)     | Web framework architecture         | 2-3 hours |
| 4   | [Ecto & Database](./04-ecto-database/)           | Data persistence & queries         | 1-2 hours |
| 5   | [LiveView](./05-liveview/)                       | Real-time server-rendered UI       | 2-3 hours |
| 6   | [This Codebase](./06-this-codebase/)             | Guided tour of the chat app        | 1 hour    |
| 7   | [Testing](./07-testing/)                         | ExUnit, testing patterns           | 1 hour    |

**Total estimated time: 10-15 hours**

> **In a hurry?** Check out the [Crash Course](./00-crash-course.md) for a condensed overview.

---

## AI-Guided Mode

Want an interactive walkthrough? Use Claude Code:

```bash
claude
# Then type: begin
```

The AI will guide you through the curriculum, pause to check understanding, and help you explore the codebase.

---

## Quick Links

### References

- [Cheatsheet](./99-reference/cheatsheet.md) - Quick syntax reference
- [Glossary](./99-reference/glossary.md) - Terms and definitions
- [Common Errors](./99-reference/common-errors.md) - Troubleshooting guide
- [Resources](./99-reference/resources.md) - Books, videos, community

### Official Documentation

- [Elixir Docs](https://hexdocs.pm/elixir/)
- [Phoenix Guides](https://hexdocs.pm/phoenix/)
- [LiveView Docs](https://hexdocs.pm/phoenix_live_view/)
- [Ecto Docs](https://hexdocs.pm/ecto/)

---

## The Chat Application

This repository contains a fully-functional real-time chat application that demonstrates every concept you'll learn. As you progress through the modules, you'll understand how each piece works.

```
lib/
├── chatroom/           # Business logic
│   ├── chat.ex         # Context module
│   └── chat/
│       └── message.ex  # Ecto schema
└── chatroom_web/       # Web layer
    ├── router.ex       # URL routing
    └── live/
        └── chat_live.ex  # LiveView UI
```

### Try It Now

```bash
# Clone and run
git clone <repo>
cd elixir-phoenix-tutorial
mix setup
mix phx.server
# Visit http://localhost:4000
```

---

## How to Use This Tutorial

### 1. Read Actively

Don't just read - type the code yourself. Muscle memory matters.

### 2. Use IEx Constantly

The interactive shell is your best friend:

```bash
iex -S mix  # Start IEx with project loaded
```

### 3. Experiment

Every "Try It" box is an invitation to explore. Change things. Break things. Learn why.

### 4. Do the Exercises

Each module has exercises. Do them before moving on.

### 5. Reference the Code

This repo IS the curriculum. The docs explain the concepts; the code shows them in action.

---

## Getting Help

- **Stuck on something?** Check [Common Errors](./99-reference/common-errors.md)
- **Need clarification?** Ask in [Elixir Forum](https://elixirforum.com/) or [Discord](https://discord.gg/elixir)
- **Found an issue?** Open a GitHub issue

---

**Ready?** [Start with Getting Started →](./00-getting-started/)
