# Section 6: This Codebase

A guided tour of the chat application that demonstrates everything you've learned.

---

## What You'll Learn

- How the files are organized
- How data flows through the system
- How each component connects
- Hands-on exercises to solidify your skills

---

## Prerequisites

Before diving in, make sure you're comfortable with:

- [Elixir Fundamentals](../01-elixir-fundamentals/) - especially pattern matching
- [OTP Fundamentals](../02-otp-fundamentals/) - GenServer basics
- [Phoenix Framework](../03-phoenix-framework/) - request lifecycle
- [Ecto](../04-ecto-database/) - schemas and changesets
- [LiveView](../05-liveview/) - lifecycle and events

---

## In This Section

| File                                         | Topic                                  |
| -------------------------------------------- | -------------------------------------- |
| [01-file-structure.md](01-file-structure.md) | Where everything lives                 |
| [02-data-flow.md](02-data-flow.md)           | Following a message through the system |
| [03-key-files.md](03-key-files.md)           | Deep dive into critical files          |
| [04-exercises.md](04-exercises.md)           | Hands-on challenges                    |

---

## Running the App

Before exploring the code, get the app running:

```bash
mix deps.get
mix ecto.create
mix ecto.migrate
iex -S mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000)

Open a second browser tab to see real-time messaging in action.

---

## Next Steps

After completing this section, move on to [Testing](../07-testing/) to learn how to write tests for everything you've built.
