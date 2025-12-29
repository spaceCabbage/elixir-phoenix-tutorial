# IEx: The Interactive Shell

IEx (Interactive Elixir) is your most powerful learning tool. Use it constantly.

---

## Starting IEx

```bash
# Basic IEx
iex

# IEx with your project loaded
iex -S mix

# IEx with Phoenix server running
iex -S mix phx.server
```

---

## Basic Usage

```elixir
iex> 1 + 1
2

iex> "Hello, " <> "World!"
"Hello, World!"

iex> [1, 2, 3] |> Enum.map(&(&1 * 2))
[2, 4, 6]
```

---

## Essential Commands

### Help System

```elixir
# Get help on a module
iex> h Enum

# Get help on a specific function
iex> h Enum.map

# Get help on operators
iex> h +
iex> h |>
```

### Inspect Values

```elixir
# Detailed info about a value
iex> i [1, 2, 3]
Term
  [1, 2, 3]
Data type
  List
...

iex> i %{foo: "bar"}
Term
  %{foo: "bar"}
Data type
  Map
...
```

### Recompile Code

```elixir
# After editing a file, reload it
iex> r MyModule

# Recompile everything
iex> recompile()
```

### Value History

```elixir
# Last result is stored in `v()`
iex> 1 + 1
2
iex> v()
2

# Access previous results by line number
iex> v(1)  # Result from line 1
```

---

## Multi-line Input

IEx automatically handles multi-line code:

```elixir
iex> defmodule Greeter do
...>   def hello(name) do
...>     "Hello, #{name}!"
...>   end
...> end
{:module, Greeter, ...}

iex> Greeter.hello("World")
"Hello, World!"
```

If you get stuck in multi-line mode:

- Press `Ctrl+C` twice to exit
- Or type `#iex:break` to break out

---

## Working with Your Project

### Access Your Modules

```elixir
# With iex -S mix phx.server

# Access your context
iex> alias Chatroom.Chat
iex> Chat.list_messages()
[...]

# Create records
iex> Chat.create_message(%{username: "test", body: "Hello!"})
{:ok, %Chatroom.Chat.Message{...}}

# Query the database
iex> Chatroom.Repo.all(Chatroom.Chat.Message)
[...]
```

### Test Functions Interactively

```elixir
# Try out pattern matching
iex> {:ok, value} = {:ok, 42}
{:ok, 42}
iex> value
42

# Test pipelines
iex> "hello world"
...> |> String.upcase()
...> |> String.split()
["HELLO", "WORLD"]
```

---

## Useful IEx Helpers

### Compile and Run Files

```elixir
# Compile a file
iex> c "path/to/file.ex"

# Import a file (runs it)
iex> import_file "script.exs"
```

### Debug with IEx.pry

Add `IEx.pry()` to pause execution and inspect:

```elixir
defmodule MyModule do
  def problematic_function(data) do
    result = transform(data)
    IEx.pry()  # Execution pauses here
    finalize(result)
  end
end
```

Then run with:

```bash
iex -S mix
```

### See Loaded Modules

```elixir
iex> exports(Enum)  # See all Enum functions
```

---

## Configuration

### `.iex.exs` File

Create `.iex.exs` in your project root for auto-loaded configuration:

```elixir
# .iex.exs
import Ecto.Query

alias Chatroom.{Repo, Chat}
alias Chatroom.Chat.Message

# Pretty print for better inspection
IEx.configure(inspect: [limit: :infinity])

IO.puts("🚀 IEx loaded with project aliases!")
```

### IEx History

Enable command history across sessions:

```bash
# Add to ~/.bashrc or ~/.zshrc
export ERL_AFLAGS="-kernel shell_history enabled"
```

---

## Keyboard Shortcuts

| Shortcut          | Action          |
| ----------------- | --------------- |
| `Ctrl+C` (twice)  | Exit IEx        |
| `Ctrl+G` then `q` | Force quit      |
| `Ctrl+L`          | Clear screen    |
| `Tab`             | Autocomplete    |
| `Up/Down`         | Command history |
| `Ctrl+R`          | Search history  |

---

## Common Patterns

### Quick Testing

```elixir
# Test a function you're writing
iex> defmodule Test do
...>   def double(x), do: x * 2
...> end
iex> Test.double(5)
10

# Iterate on it
iex> defmodule Test do
...>   def double(x) when is_number(x), do: x * 2
...>   def double(_), do: {:error, "not a number"}
...> end
```

### Explore Dependencies

```elixir
# See what's available in Phoenix
iex> exports(Phoenix.PubSub)

# Check Ecto functions
iex> h Ecto.Query.from
```

---

## Troubleshooting

### IEx Won't Start

```bash
# Check Erlang is working
erl -version

# Try with minimal flags
iex --erl "-smp disable"
```

### Project Won't Load

```bash
# Make sure deps are fetched
mix deps.get

# Compile first
mix compile

# Then try IEx
iex -S mix
```

---

**Next:** [First Run →](./06-first-run.md)
