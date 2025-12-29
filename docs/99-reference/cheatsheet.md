# Elixir & Phoenix Cheatsheet

Quick syntax reference for common patterns.

---

## Data Types

```elixir
# Atoms
:ok
:error
true  # same as :true
nil   # same as :nil

# Strings
"hello"
"interpolation: #{1 + 1}"

# Lists (linked)
[1, 2, 3]
[head | tail] = [1, 2, 3]  # head=1, tail=[2,3]

# Tuples (fixed size)
{:ok, "success"}
elem({1, 2, 3}, 0)  # => 1

# Maps
%{key: "value"}
map.key
map[:key]
%{map | key: "new"}

# Keyword lists
[name: "Alice", age: 30]
```

---

## Pattern Matching

```elixir
# Basic
x = 1
{:ok, result} = {:ok, 42}
[h | t] = [1, 2, 3]
%{name: name} = %{name: "Alice", age: 30}

# Pin operator (match, don't rebind)
^x = 1

# Ignore
{:ok, _} = {:ok, "ignored"}
```

---

## Functions

```elixir
# Anonymous
add = fn a, b -> a + b end
add.(1, 2)

# Capture
add = &(&1 + &2)
upcase = &String.upcase/1

# Named (in module)
def greet(name), do: "Hello, #{name}"
defp private_fn(x), do: x * 2

# Multiple clauses
def fib(0), do: 0
def fib(1), do: 1
def fib(n), do: fib(n-1) + fib(n-2)

# Guards
def valid?(n) when is_integer(n) and n > 0, do: true
def valid?(_), do: false

# Default args
def greet(name, greeting \\ "Hello")
```

---

## Pipe Operator

```elixir
"  hello  "
|> String.trim()
|> String.upcase()
|> String.split()
# => ["HELLO"]
```

---

## Control Flow

```elixir
# if/else
if true, do: "yes", else: "no"

# case (pattern match)
case value do
  {:ok, x} -> x
  {:error, _} -> nil
  _ -> :default
end

# cond (first truthy)
cond do
  x > 10 -> "big"
  x > 0 -> "small"
  true -> "zero or negative"
end

# with (chain matches)
with {:ok, a} <- fetch_a(),
     {:ok, b} <- fetch_b(a) do
  {:ok, a + b}
else
  {:error, reason} -> {:error, reason}
end
```

---

## Enum

```elixir
Enum.map([1,2,3], &(&1 * 2))       # [2,4,6]
Enum.filter([1,2,3], &(&1 > 1))    # [2,3]
Enum.reduce([1,2,3], 0, &+/2)      # 6
Enum.find([1,2,3], &(&1 > 1))      # 2
Enum.sort([3,1,2])                 # [1,2,3]
Enum.group_by(users, & &1.role)
```

---

## Structs

```elixir
defmodule User do
  defstruct [:name, :email, age: 0]
end

user = %User{name: "Alice"}
%User{name: name} = user
%{user | age: 30}
```

---

## Processes

```elixir
# Spawn
pid = spawn(fn -> IO.puts("hi") end)

# Send/receive
send(pid, {:msg, "hello"})
receive do
  {:msg, text} -> text
after
  5000 -> :timeout
end
```

---

## GenServer

```elixir
defmodule Counter do
  use GenServer

  # Client
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)
  def get(pid), do: GenServer.call(pid, :get)
  def inc(pid), do: GenServer.cast(pid, :inc)

  # Server
  def init(opts), do: {:ok, opts[:initial] || 0}
  def handle_call(:get, _from, state), do: {:reply, state, state}
  def handle_cast(:inc, state), do: {:noreply, state + 1}
end
```

---

## Phoenix LiveView

```elixir
defmodule MyLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_info({:update, n}, socket) do
    {:noreply, assign(socket, count: n)}
  end

  def render(assigns) do
    ~H"""
    <button phx-click="inc"><%= @count %></button>
    """
  end
end
```

---

## Ecto

```elixir
# Schema
schema "users" do
  field :name, :string
  has_many :posts, Post
  timestamps()
end

# Changeset
def changeset(user, attrs) do
  user
  |> cast(attrs, [:name])
  |> validate_required([:name])
end

# Queries
User |> where([u], u.active) |> Repo.all()
Repo.get!(User, 1)
Repo.insert(changeset)
```

---

## PubSub

```elixir
# Subscribe
Phoenix.PubSub.subscribe(MyApp.PubSub, "topic")

# Broadcast
Phoenix.PubSub.broadcast(MyApp.PubSub, "topic", {:event, data})

# Receive (in LiveView)
def handle_info({:event, data}, socket), do: ...
```

---

## Mix Commands

```bash
mix new my_app          # New project
mix deps.get            # Install deps
mix compile             # Compile
mix test                # Run tests
mix format              # Format code

# Phoenix
mix phx.new my_app      # New Phoenix app
mix phx.server          # Start server
mix phx.routes          # List routes
mix phx.gen.live        # Generate LiveView
mix phx.gen.auth        # Generate auth

# Ecto
mix ecto.create         # Create DB
mix ecto.migrate        # Run migrations
mix ecto.gen.migration  # New migration
mix ecto.rollback       # Undo migration
```

---

## IEx

```elixir
iex -S mix              # Start with project
iex -S mix phx.server   # Start with Phoenix

r Module                # Reload module
h Enum.map              # Help
i variable              # Inspect
c "file.ex"             # Compile file
```
