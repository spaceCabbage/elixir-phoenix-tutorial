# Collections

Elixir has four main collection types. Each has specific use cases.

---

## Quick Reference

| Type             | Syntax          | Access          | Use Case                         |
| ---------------- | --------------- | --------------- | -------------------------------- |
| **List**         | `[1, 2, 3]`     | Sequential O(n) | Ordered items, prepending        |
| **Tuple**        | `{:ok, value}`  | Index O(1)      | Fixed-size groups, return values |
| **Map**          | `%{key: value}` | Key O(log n)    | Key-value lookup                 |
| **Keyword List** | `[key: value]`  | Key O(n)        | Options, ordered pairs           |

---

## Lists

Lists are linked lists - efficient at the head, expensive at the tail.

```elixir
iex> [1, 2, 3]
[1, 2, 3]

iex> [1, "two", :three]  # Mixed types allowed
[1, "two", :three]

iex> []  # Empty list
[]
```

### Head and Tail

```elixir
iex> list = [1, 2, 3]

# Get the head (first element)
iex> hd(list)
1

# Get the tail (everything except first)
iex> tl(list)
[2, 3]

# Pattern match head and tail
iex> [head | tail] = [1, 2, 3]
iex> head
1
iex> tail
[2, 3]
```

### List Operations

```elixir
# Prepend (fast - O(1))
iex> [0 | [1, 2, 3]]
[0, 1, 2, 3]

# Append (slow - O(n), must traverse list)
iex> [1, 2, 3] ++ [4, 5]
[1, 2, 3, 4, 5]

# Subtract
iex> [1, 2, 3, 2] -- [2]
[1, 3, 2]  # Removes first occurrence

# Length
iex> length([1, 2, 3])
3

# Check membership
iex> 2 in [1, 2, 3]
true

# Get element (O(n) - must traverse)
iex> Enum.at([1, 2, 3], 1)
2
```

### When to Use Lists

- When you frequently add to the beginning
- When you process items sequentially
- When size varies frequently
- Don't use when you need random access

---

## Tuples

Tuples store elements contiguously in memory. Fast access, but expensive to modify.

```elixir
iex> {:ok, "success"}
{:ok, "success"}

iex> {:error, "not found"}
{:error, "not found"}

iex> {1, 2, 3}
{1, 2, 3}
```

### Tuple Operations

```elixir
# Access by index (O(1))
iex> tuple = {:a, :b, :c}
iex> elem(tuple, 0)
:a
iex> elem(tuple, 2)
:c

# Size
iex> tuple_size({:a, :b, :c})
3

# Update (creates new tuple - O(n))
iex> put_elem({:a, :b, :c}, 1, :x)
{:a, :x, :c}
```

### Common Tuple Patterns

```elixir
# Success/error returns
{:ok, result} = some_function()
{:error, reason} = failing_function()

# Multiple return values
{status, body, headers} = make_request()

# Coordinates/points
point = {10, 20}

# Tagged values
{:user, "alice", 25}
```

### When to Use Tuples

- Return values from functions
- Fixed-size groups of related values
- When you need fast index access
- Don't use when size varies or for large collections

---

## Maps

Maps are key-value stores. The go-to data structure for most cases.

```elixir
# Any key type
iex> %{"name" => "Alice", "age" => 30}
%{"age" => 30, "name" => "Alice"}

# Atom keys (common pattern)
iex> %{name: "Alice", age: 30}
%{name: "Alice", age: 30}

# Mixed keys
iex> %{:a => 1, "b" => 2}
%{:a => 1, "b" => 2}

# Empty map
iex> %{}
%{}
```

### Accessing Values

```elixir
iex> user = %{name: "Alice", age: 30}

# Bracket syntax (works with any key)
iex> user[:name]
"Alice"

iex> user[:nonexistent]
nil

# Dot syntax (atom keys only, raises if missing)
iex> user.name
"Alice"

iex> user.nonexistent
** (KeyError) key :nonexistent not found

# Map.get with default
iex> Map.get(user, :name)
"Alice"

iex> Map.get(user, :missing, "default")
"default"

# Map.fetch (returns {:ok, value} or :error)
iex> Map.fetch(user, :name)
{:ok, "Alice"}

iex> Map.fetch(user, :missing)
:error
```

### Updating Maps

```elixir
iex> user = %{name: "Alice", age: 30}

# Update existing key (| syntax)
iex> %{user | age: 31}
%{name: "Alice", age: 31}

# | raises if key doesn't exist
iex> %{user | height: 170}
** (KeyError) key :height not found

# Map.put (adds or updates)
iex> Map.put(user, :height, 170)
%{name: "Alice", age: 30, height: 170}

# Map.merge
iex> Map.merge(user, %{city: "NYC", age: 31})
%{name: "Alice", age: 31, city: "NYC"}

# Map.delete
iex> Map.delete(user, :age)
%{name: "Alice"}
```

### Pattern Matching Maps

```elixir
iex> %{name: name} = %{name: "Alice", age: 30}
iex> name
"Alice"

# Match subset (doesn't need all keys)
iex> %{name: name} = %{name: "Alice", age: 30, city: "NYC"}
iex> name
"Alice"

# Match in function heads
def greet(%{name: name}) do
  "Hello, #{name}!"
end
```

### When to Use Maps

- Key-value storage
- Configuration
- JSON-like data
- When you need fast lookups
- Most of the time!

---

## Keyword Lists

Keyword lists are lists of `{atom, value}` tuples with special syntax.

```elixir
# These are equivalent
iex> [name: "Alice", age: 30]
[name: "Alice", age: 30]

iex> [{:name, "Alice"}, {:age, 30}]
[name: "Alice", age: 30]
```

### Key Features

```elixir
# Duplicate keys allowed
iex> [a: 1, a: 2]
[a: 1, a: 2]

# Order preserved
iex> [z: 1, a: 2, m: 3]
[z: 1, a: 2, m: 3]

# Access
iex> opts = [name: "Alice", debug: true]
iex> opts[:name]
"Alice"

# First value wins with []
iex> [a: 1, a: 2][:a]
1
```

### Common Use: Function Options

```elixir
# Without keyword list
def connect(host, port, ssl, timeout) do
  ...
end
connect("localhost", 5432, true, 5000)

# With keyword list
def connect(host, opts \\ []) do
  port = Keyword.get(opts, :port, 5432)
  ssl = Keyword.get(opts, :ssl, false)
  timeout = Keyword.get(opts, :timeout, 5000)
  ...
end
connect("localhost", port: 5432, ssl: true)
```

### When Last Argument, Brackets Optional

```elixir
# These are equivalent
query(User, where: [age: 30], order_by: :name)
query(User, [where: [age: 30], order_by: :name])
```

### When to Use Keyword Lists

- Function options
- DSLs (like Ecto queries)
- When order matters
- When duplicate keys are needed
- Don't use for data storage (use maps)

---

## Ranges

Ranges represent a sequence of integers:

```elixir
iex> 1..10
1..10

iex> Enum.to_list(1..5)
[1, 2, 3, 4, 5]

iex> 1 in 1..10
true

iex> 15 in 1..10
false

# Step ranges (Elixir 1.12+)
iex> Enum.to_list(1..10//2)
[1, 3, 5, 7, 9]

# Descending
iex> Enum.to_list(5..1//-1)
[5, 4, 3, 2, 1]
```

---

## Comparison Summary

| Operation | List | Tuple | Map      | Keyword |
| --------- | ---- | ----- | -------- | ------- |
| Prepend   | O(1) | -     | -        | O(1)    |
| Append    | O(n) | -     | -        | O(n)    |
| Access    | O(n) | O(1)  | O(log n) | O(n)    |
| Length    | O(n) | O(1)  | O(n)     | O(n)    |
| Update    | O(n) | O(n)  | O(log n) | O(n)    |

---

## Try It

```elixir
# Lists
iex> list = [1, 2, 3]
iex> [0 | list]
iex> list ++ [4]
iex> [head | tail] = [1, 2, 3, 4, 5]

# Maps
iex> user = %{name: "Bob", scores: [95, 87, 92]}
iex> user.name
iex> user[:scores]
iex> %{user | name: "Robert"}

# Keyword lists
iex> opts = [timeout: 5000, retries: 3]
iex> opts[:timeout]
iex> Keyword.get(opts, :missing, "default")

# Nested access
iex> data = %{user: %{name: "Alice", address: %{city: "NYC"}}}
iex> data.user.address.city
iex> get_in(data, [:user, :address, :city])
```

---

## Key Takeaways

1. **Lists** - Linked lists, prepend O(1), good for sequential processing
2. **Tuples** - Fixed size, index access O(1), good for return values
3. **Maps** - Key-value, fast lookup, use for most data
4. **Keyword Lists** - Ordered, duplicate keys, use for options

Pick the right collection for the job. When in doubt, use a map.

---

**Next:** [Pattern Matching →](./03-pattern-matching.md)
