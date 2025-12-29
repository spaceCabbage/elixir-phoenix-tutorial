# Pattern Matching

Pattern matching is Elixir's most powerful feature. It replaces most conditional logic you'd write in other languages.

---

## The `=` Operator

In Elixir, `=` is the **match operator**, not just assignment:

```elixir
iex> x = 1  # Binds x to 1
1

iex> 1 = x  # Matches! 1 equals x
1

iex> 2 = x  # Fails! 2 doesn't equal 1
** (MatchError) no match of right hand side value: 1
```

The left side is a **pattern**, the right side is a **value**. Elixir tries to make them match.

---

## Matching Tuples

```elixir
iex> {a, b, c} = {1, 2, 3}
{1, 2, 3}

iex> a
1

iex> b
2

iex> c
3

# Structure must match
iex> {a, b} = {1, 2, 3}
** (MatchError) no match of right hand side value: {1, 2, 3}
```

### Real-World Usage

```elixir
# Handling function returns
iex> {:ok, file} = File.read("mix.exs")
{:ok, "defmodule..."}
iex> file
"defmodule..."

# Error handling
iex> {:ok, file} = File.read("nonexistent.txt")
** (MatchError) no match of right hand side value: {:error, :enoent}

# Proper error handling
case File.read("file.txt") do
  {:ok, content} -> process(content)
  {:error, reason} -> handle_error(reason)
end
```

---

## Matching Lists

```elixir
iex> [a, b, c] = [1, 2, 3]
[1, 2, 3]

iex> a
1

# Head and tail
iex> [head | tail] = [1, 2, 3, 4]
[1, 2, 3, 4]

iex> head
1

iex> tail
[2, 3, 4]

# Just first two elements
iex> [first, second | rest] = [1, 2, 3, 4, 5]
iex> first
1
iex> second
2
iex> rest
[3, 4, 5]

# Empty tail
iex> [only] = [1]
[1]
iex> [head | tail] = [1]
iex> tail
[]
```

---

## Matching Maps

Maps match on **subset** - you don't need all keys:

```elixir
iex> %{name: name} = %{name: "Alice", age: 30}
%{name: "Alice", age: 30}

iex> name
"Alice"

# Multiple keys
iex> %{name: n, age: a} = %{name: "Alice", age: 30, city: "NYC"}
iex> n
"Alice"
iex> a
30

# Matching specific values
iex> %{type: :user} = %{type: :user, name: "Alice"}
%{type: :user, name: "Alice"}

iex> %{type: :admin} = %{type: :user, name: "Alice"}
** (MatchError) no match of right hand side value...
```

---

## The Pin Operator `^`

By default, variables on the left are bound to new values. Use `^` to match against an existing value:

```elixir
iex> x = 1
1

iex> x = 2  # Rebinds x
2

iex> ^x = 2  # Matches against x's value (2)
2

iex> ^x = 3  # Fails! 2 != 3
** (MatchError) no match of right hand side value: 3
```

### Real-World Usage

```elixir
def update_user(user_id, attrs) do
  # Only update if IDs match
  %{id: ^user_id} = current_user
  # ... update logic
end
```

---

## Ignoring Values with `_`

Use `_` to match but ignore a value:

```elixir
iex> {_, b, _} = {1, 2, 3}
{1, 2, 3}

iex> b
2

# Named ignore (for documentation)
iex> {_first, second, _third} = {1, 2, 3}
iex> second
2

# Ignore in list tail
iex> [head | _] = [1, 2, 3, 4, 5]
iex> head
1
```

---

## Pattern Matching in Function Heads

This is where pattern matching really shines:

```elixir
defmodule Greeter do
  def hello(%{name: name, age: age}) when age >= 18 do
    "Hello, #{name}! You're an adult."
  end

  def hello(%{name: name}) do
    "Hello, #{name}!"
  end

  def hello(name) when is_binary(name) do
    "Hello, #{name}!"
  end

  def hello(_) do
    "Hello, stranger!"
  end
end
```

```elixir
iex> Greeter.hello(%{name: "Alice", age: 25})
"Hello, Alice! You're an adult."

iex> Greeter.hello(%{name: "Bob"})
"Hello, Bob!"

iex> Greeter.hello("Charlie")
"Hello, Charlie!"

iex> Greeter.hello(123)
"Hello, stranger!"
```

### Function clause order matters!

Elixir tries clauses top-to-bottom. Put specific patterns first:

```elixir
# WRONG - first clause always matches
def process(data) do
  # generic handling
end

def process(%{type: :special} = data) do
  # This never runs!
end

# RIGHT - specific first
def process(%{type: :special} = data) do
  # special handling
end

def process(data) do
  # generic handling
end
```

---

## Pattern Matching in Case

```elixir
case result do
  {:ok, value} ->
    "Success: #{value}"

  {:error, :not_found} ->
    "Not found"

  {:error, reason} ->
    "Error: #{reason}"

  _ ->
    "Unknown result"
end
```

---

## Destructuring in Function Parameters

```elixir
# Instead of this
def full_name(user) do
  "#{user.first} #{user.last}"
end

# Do this
def full_name(%{first: first, last: last}) do
  "#{first} #{last}"
end

# Or even better with capture
def full_name(%{first: first, last: last} = user) do
  Logger.info("Getting name for user #{user.id}")
  "#{first} #{last}"
end
```

---

## Common Patterns

### Handling Success/Error

```elixir
case do_something() do
  {:ok, result} -> handle_success(result)
  {:error, reason} -> handle_error(reason)
end

# Or with bang!
{:ok, result} = do_something!()
```

### Extracting Nested Data

```elixir
%{
  user: %{
    profile: %{
      name: name
    }
  }
} = response

# Or use get_in
name = get_in(response, [:user, :profile, :name])
```

### List Recursion

```elixir
def sum([]), do: 0
def sum([head | tail]), do: head + sum(tail)

iex> sum([1, 2, 3, 4])
10
```

### Optional Fields

```elixir
def greet(%{nickname: nick}), do: "Hey #{nick}!"
def greet(%{name: name}), do: "Hello #{name}"
def greet(_), do: "Hello there"
```

---

## Try It

```elixir
# Basic matching
iex> {status, value} = {:ok, 42}
iex> status
iex> value

# List matching
iex> [first | rest] = String.split("hello world how are you")
iex> first
iex> rest

# Map matching
iex> response = %{status: 200, body: "OK", headers: %{}}
iex> %{status: status, body: body} = response
iex> status

# Pin operator
iex> expected = :success
iex> ^expected = :success
iex> ^expected = :failure

# Function heads
defmodule Math do
  def abs(n) when n >= 0, do: n
  def abs(n), do: -n
end
iex> Math.abs(-5)
iex> Math.abs(5)
```

---

## Key Takeaways

1. **`=` is match, not assign** - Both sides must match
2. **Tuples match by structure** - Same size required
3. **Lists use `[head | tail]`** - Recursive processing
4. **Maps match subsets** - Don't need all keys
5. **`^` pins existing values** - Match instead of rebind
6. **`_` ignores values** - Match but don't capture
7. **Function heads pattern match** - Multiple clauses, guards

Pattern matching replaces `if/else` chains, type checks, and null checks. Use it everywhere.

---

**Next:** [Functions →](./04-functions.md)
