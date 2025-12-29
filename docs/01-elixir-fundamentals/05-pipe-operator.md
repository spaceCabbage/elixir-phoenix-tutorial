# The Pipe Operator

The pipe operator `|>` is Elixir's signature feature. It transforms nested function calls into readable data pipelines.

---

## The Problem

Without pipes, code becomes hard to read:

```elixir
# Nested calls - read inside-out
String.split(String.downcase(String.trim("  HELLO WORLD  ")))
# What happens first? Hard to tell.
```

Intermediate variables help but are verbose:

```elixir
trimmed = String.trim("  HELLO WORLD  ")
lowered = String.downcase(trimmed)
words = String.split(lowered)
```

---

## The Solution: `|>`

The pipe passes the result of the left side as the **first argument** to the right side:

```elixir
"  HELLO WORLD  "
|> String.trim()
|> String.downcase()
|> String.split()

# Returns: ["hello", "world"]
```

Read top-to-bottom, like a recipe:

1. Start with `"  HELLO WORLD  "`
2. Trim whitespace
3. Convert to lowercase
4. Split into words

---

## How It Works

```elixir
x |> f(y, z)
# Is equivalent to:
f(x, y, z)
```

The left side becomes the **first** argument:

```elixir
# These are equivalent:
"hello" |> String.upcase()
String.upcase("hello")

# With additional arguments:
"hello world" |> String.split(" ")
String.split("hello world", " ")
```

---

## Real-World Examples

### Data Transformation

```elixir
# Process user input
user_input
|> String.trim()
|> String.downcase()
|> String.replace(~r/[^a-z0-9]/, "_")
|> String.slice(0, 50)
```

### Working with Collections

```elixir
# Calculate average of positive numbers
[1, -2, 3, -4, 5]
|> Enum.filter(&(&1 > 0))
|> Enum.sum()
|> Kernel./(3)  # Divide by count

# Result: 3.0
```

### Building Ecto Queries

```elixir
User
|> where([u], u.active == true)
|> where([u], u.age >= 18)
|> order_by([u], desc: u.inserted_at)
|> limit(10)
|> Repo.all()
```

### Phoenix Request Pipeline

```elixir
conn
|> put_status(:created)
|> put_resp_header("location", path)
|> render("show.json", user: user)
```

---

## Pattern: First Argument Convention

Elixir libraries are designed for piping. The "subject" is always the first argument:

```elixir
# String module - string is first
String.upcase(string)
String.split(string, pattern)
String.replace(string, pattern, replacement)

# Enum module - enumerable is first
Enum.map(enumerable, function)
Enum.filter(enumerable, function)
Enum.reduce(enumerable, acc, function)

# Map module - map is first
Map.get(map, key)
Map.put(map, key, value)
Map.merge(map, other_map)
```

---

## Multi-Line Formatting

For readability, put each step on its own line:

```elixir
# Good
result =
  data
  |> step_one()
  |> step_two()
  |> step_three()

# Also good (for short pipelines)
result = data |> step_one() |> step_two()

# Avoid: mixing styles
result = data |> step_one()
  |> step_two()  # Inconsistent
```

---

## When to Use Pipes

### Good Use Cases

```elixir
# Clear data flow
"hello world"
|> String.split()
|> Enum.map(&String.capitalize/1)
|> Enum.join(" ")
# "Hello World"

# Multiple transformations
user
|> Map.put(:updated_at, DateTime.utc_now())
|> Map.update(:login_count, 1, &(&1 + 1))
|> Repo.update()
```

### When NOT to Use Pipes

```elixir
# Single operation - just call directly
String.upcase("hello")  # Good
"hello" |> String.upcase()  # Unnecessary

# When first arg isn't the subject
Enum.at(list, index)  # Good
list |> Enum.at(index)  # Fine, but...
index |> Enum.at(list)  # Wrong! Order matters
```

---

## The `then` Function

For operations where you need the value somewhere other than first position:

```elixir
# Problem: can't pipe directly
Map.get(map, key)

# Solution: use then/2
key
|> then(&Map.get(map, &1))

# Or in Elixir 1.12+, use tap for side effects
data
|> tap(&IO.inspect/1)  # Print but continue with original
|> process()
```

---

## Anonymous Functions in Pipes

```elixir
1..10
|> Enum.map(fn x -> x * 2 end)
|> Enum.filter(fn x -> x > 10 end)

# Or with capture syntax
1..10
|> Enum.map(&(&1 * 2))
|> Enum.filter(&(&1 > 10))
```

---

## Debugging with `IO.inspect`

Insert `IO.inspect` anywhere in a pipeline:

```elixir
data
|> first_transform()
|> IO.inspect(label: "after first")  # Prints and passes through
|> second_transform()
|> IO.inspect(label: "after second")
|> final_transform()
```

Output:

```
after first: [transformed data]
after second: [more transformed data]
```

---

## Common Patterns

### Chain Until Failure

```elixir
# Each step returns {:ok, value} or {:error, reason}
with {:ok, user} <- find_user(id),
     {:ok, user} <- validate_user(user),
     {:ok, user} <- update_user(user, params) do
  {:ok, user}
end
```

### Transform or Default

```elixir
Map.get(data, :name)
|> Kernel.||("Anonymous")
|> String.capitalize()
```

### Conditional Pipe

```elixir
defmodule StringHelpers do
  def maybe_upcase(string, true), do: String.upcase(string)
  def maybe_upcase(string, false), do: string
end

"hello"
|> StringHelpers.maybe_upcase(should_uppercase?)
|> process()
```

---

## Try It

```elixir
# Simple pipeline
iex> "  elixir is awesome  " |> String.trim() |> String.upcase()
"ELIXIR IS AWESOME"

# Collection pipeline
iex> 1..10 |> Enum.map(&(&1 * 3)) |> Enum.filter(&(&1 > 15))
[18, 21, 24, 27, 30]

# Pipeline with debugging
iex> [1, 2, 3]
...> |> IO.inspect(label: "start")
...> |> Enum.map(&(&1 * 2))
...> |> IO.inspect(label: "doubled")
...> |> Enum.sum()

# Build a pipeline
iex> defmodule Transform do
...>   def run(data) do
...>     data
...>     |> Map.put(:processed, true)
...>     |> Map.update(:count, 1, &(&1 + 1))
...>   end
...> end
iex> Transform.run(%{name: "test", count: 5})
```

---

## Key Takeaways

1. **`|>` pipes to first argument** - Left becomes first arg of right
2. **Read top-to-bottom** - Like a recipe
3. **Design for piping** - Subject first in your functions
4. **Use for data transformation** - Clear flow of data
5. **Debug with `IO.inspect`** - Prints and passes through
6. **Don't overuse** - Single operations don't need pipes

The pipe operator isn't just syntax sugar - it encourages a functional style of programming where data flows through transformations.

---

**Next:** [Control Flow →](./06-control-flow.md)
