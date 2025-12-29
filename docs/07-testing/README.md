# Section 7: Testing

Learn to write tests for your Elixir and Phoenix applications.

---

## Why Test in Elixir?

Elixir's design makes testing a pleasure:

- **Immutability** - No hidden state changes to track
- **Pattern matching** - Assert on structure, not just values
- **Processes** - Isolate tests with separate processes
- **ExUnit** - Fast, built-in, and powerful

---

## In This Section

| File                                               | Topic                             |
| -------------------------------------------------- | --------------------------------- |
| [01-exunit-basics.md](01-exunit-basics.md)         | Test structure, assertions, setup |
| [02-testing-contexts.md](02-testing-contexts.md)   | Testing business logic            |
| [03-testing-liveview.md](03-testing-liveview.md)   | Testing real-time UI              |
| [04-testing-genserver.md](04-testing-genserver.md) | Testing stateful processes        |

---

## Quick Start

```bash
# Run all tests
mix test

# Run specific file
mix test test/chatroom/chat_test.exs

# Run specific test by line number
mix test test/chatroom/chat_test.exs:10

# Run with verbose output
mix test --trace

# Run and stop on first failure
mix test --max-failures 1
```

---

## Test File Location

Tests mirror the `lib/` structure:

```
lib/chatroom/chat.ex
  -> test/chatroom/chat_test.exs

lib/chatroom_web/live/chat_live.ex
  -> test/chatroom_web/live/chat_live_test.exs
```

---

## The Test Environment

Tests run with `MIX_ENV=test`:

- Uses `config/test.exs` settings
- Database runs in sandbox mode (isolated per test)
- Faster compile, no assets

---

## Next

Start with [ExUnit Basics](01-exunit-basics.md) to learn the fundamentals.
