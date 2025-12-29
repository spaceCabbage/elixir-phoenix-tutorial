# Control Flow

Elixir has several control flow constructs, but pattern matching in function heads is often preferred. Use these when pattern matching doesn't fit.

---

## `case`: Pattern Matching on Values

```elixir
case result do
  {:ok, value} ->
    "Got: #{value}"

  {:error, :not_found} ->
    "Not found"

  {:error, reason} ->
    "Error: #{reason}"

  _ ->
    "Unknown"
end
```

### With Guards

```elixir
case number do
  n when n < 0 -> "negative"
  0 -> "zero"
  n when n > 0 -> "positive"
end
```

### Real-World Usage

```elixir
def handle_response(response) do
  case response do
    %{status: 200, body: body} ->
      {:ok, decode(body)}

    %{status: 404} ->
      {:error, :not_found}

    %{status: status} when status in 400..499 ->
      {:error, :client_error}

    %{status: status} when status in 500..599 ->
      {:error, :server_error}

    _ ->
      {:error, :unknown}
  end
end
```

---

## `cond`: Multiple Conditions

When you need `if/else if/else` chains:

```elixir
cond do
  x < 0 -> "negative"
  x == 0 -> "zero"
  x > 0 -> "positive"
end
```

### Real-World Usage

```elixir
def ticket_price(age) do
  cond do
    age < 3 -> :free
    age < 12 -> :child
    age < 65 -> :adult
    true -> :senior  # Default (always matches)
  end
end
```

### `cond` vs Pattern Matching

Often, multiple function clauses are cleaner:

```elixir
# Using cond
def ticket_price(age) do
  cond do
    age < 3 -> :free
    age < 12 -> :child
    age < 65 -> :adult
    true -> :senior
  end
end

# Using function clauses (often preferred)
def ticket_price(age) when age < 3, do: :free
def ticket_price(age) when age < 12, do: :child
def ticket_price(age) when age < 65, do: :adult
def ticket_price(_age), do: :senior
```

---

## `if` and `unless`

For simple true/false conditions:

```elixir
if condition do
  "truthy"
else
  "falsy"
end

unless condition do
  "falsy"
else
  "truthy"
end
```

### One-Liner Syntax

```elixir
if valid?, do: "yes", else: "no"

unless empty?, do: process(data)
```

### Return Values

`if` returns the value of the executed branch:

```elixir
result = if 1 > 0 do
  "math works"
else
  "something is wrong"
end
# result = "math works"

# Missing else returns nil
result = if false, do: "won't happen"
# result = nil
```

### When to Use `if`

```elixir
# Good: simple boolean check
if user.admin?, do: show_admin_panel(user)

# Better: pattern match when possible
case user do
  %{admin: true} -> show_admin_panel(user)
  _ -> show_regular_view(user)
end
```

---

## `with`: Happy Path Chaining

`with` is powerful for chaining operations that might fail:

```elixir
with {:ok, user} <- find_user(id),
     {:ok, profile} <- get_profile(user),
     {:ok, avatar} <- get_avatar(profile) do
  {:ok, avatar}
else
  {:error, reason} -> {:error, reason}
end
```

### How It Works

1. Execute each `<-` expression
2. If it matches, continue to the next
3. If it doesn't match, jump to `else`
4. If all match, execute the `do` block

### Without `with` (Nested Case)

```elixir
# This is ugly
case find_user(id) do
  {:ok, user} ->
    case get_profile(user) do
      {:ok, profile} ->
        case get_avatar(profile) do
          {:ok, avatar} -> {:ok, avatar}
          error -> error
        end
      error -> error
    end
  error -> error
end
```

### Pattern Matching in `with`

```elixir
with {:ok, %{name: name}} <- get_user(id),
     true <- String.length(name) > 0,
     {:ok, result} <- process(name) do
  {:ok, result}
else
  {:error, reason} -> {:error, reason}
  false -> {:error, :empty_name}
end
```

### Bare Expressions in `with`

You can mix `<-` with regular expressions:

```elixir
with {:ok, data} <- fetch_data(),
     processed = transform(data),  # Always succeeds, binds processed
     {:ok, result} <- validate(processed) do
  {:ok, result}
end
```

---

## `raise` and Exceptions

Elixir has exceptions but uses them sparingly:

```elixir
# Raise an exception
raise "Something went wrong"
raise ArgumentError, message: "Invalid input"

# Rescue an exception
try do
  risky_operation()
rescue
  RuntimeError -> "runtime error"
  ArgumentError -> "bad argument"
  e in [IOError, File.Error] -> "IO problem: #{e.message}"
  e -> "unknown: #{inspect(e)}"
end
```

### When to Use Exceptions

```elixir
# Use return tuples for expected failures
{:ok, result} = operation()
{:error, reason} = operation()

# Use exceptions for unexpected failures
File.read!("must_exist.txt")  # Raises if file doesn't exist

# Convention: ! suffix means "raises on error"
File.read("file.txt")   # Returns {:ok, content} or {:error, reason}
File.read!("file.txt")  # Returns content or raises
```

---

## `throw` and `catch`

Rarely used - for non-local returns:

```elixir
try do
  Enum.each(1..100, fn x ->
    if x == 50, do: throw(:found)
  end)
  :not_found
catch
  :found -> :found
end
```

**Note:** Prefer `Enum.find` or pattern matching over `throw/catch`.

---

## Control Flow Comparison

| Construct                         | Use When                               |
| --------------------------------- | -------------------------------------- |
| Pattern matching (function heads) | Multiple cases with different patterns |
| `case`                            | Pattern matching on a single value     |
| `cond`                            | Multiple boolean conditions            |
| `if/unless`                       | Simple true/false check                |
| `with`                            | Chaining operations that might fail    |
| Exceptions                        | Unexpected, unrecoverable errors       |

---

## Idiomatic Elixir

### Prefer Pattern Matching

```elixir
# Instead of this
def process(value) do
  if is_map(value) do
    handle_map(value)
  else
    if is_list(value) do
      handle_list(value)
    else
      handle_other(value)
    end
  end
end

# Do this
def process(value) when is_map(value), do: handle_map(value)
def process(value) when is_list(value), do: handle_list(value)
def process(value), do: handle_other(value)
```

### Prefer `with` for Happy Path

```elixir
# Instead of nested case
case step1() do
  {:ok, a} ->
    case step2(a) do
      {:ok, b} -> {:ok, b}
      error -> error
    end
  error -> error
end

# Do this
with {:ok, a} <- step1(),
     {:ok, b} <- step2(a) do
  {:ok, b}
end
```

---

## Try It

```elixir
# case
iex> case {1, 2, 3} do
...>   {1, x, 3} -> "matched with x=#{x}"
...>   _ -> "no match"
...> end

# cond
iex> cond do
...>   2 + 2 == 5 -> "math is broken"
...>   2 * 2 == 4 -> "math works"
...>   true -> "catch all"
...> end

# with
iex> with {:ok, a} <- {:ok, 1},
...>      {:ok, b} <- {:ok, 2} do
...>   a + b
...> end

iex> with {:ok, a} <- {:error, "failed"},
...>      {:ok, b} <- {:ok, 2} do
...>   a + b
...> else
...>   {:error, reason} -> "error: #{reason}"
...> end
```

---

## Key Takeaways

1. **Prefer pattern matching** - Function heads > case > cond > if
2. **`case` for pattern matching** - When you have a value to match
3. **`cond` for boolean conditions** - Multiple `if/else if` branches
4. **`with` for happy path** - Chain operations that return `{:ok, _}` or `{:error, _}`
5. **Exceptions are rare** - Use return tuples for expected failures
6. **`!` functions raise** - `File.read!` vs `File.read`

---

**Next:** [Modules & Structs →](./07-modules-structs.md)
