# Enum & Recursion

The `Enum` module is your primary tool for working with collections. Understanding both `Enum` and recursion gives you flexibility.

---

## The Enum Module

`Enum` works with any enumerable: lists, maps, ranges, etc.

### Essential Functions

```elixir
list = [1, 2, 3, 4, 5]

# map: transform each element
Enum.map(list, fn x -> x * 2 end)
# [2, 4, 6, 8, 10]

# filter: keep elements matching predicate
Enum.filter(list, fn x -> x > 2 end)
# [3, 4, 5]

# reject: opposite of filter
Enum.reject(list, fn x -> x > 2 end)
# [1, 2]

# reduce: accumulate to single value
Enum.reduce(list, 0, fn x, acc -> acc + x end)
# 15

# each: side effects (returns :ok)
Enum.each(list, fn x -> IO.puts(x) end)
# prints 1 through 5, returns :ok
```

### Finding Elements

```elixir
list = [1, 2, 3, 4, 5]

Enum.find(list, fn x -> x > 3 end)     # 4
Enum.find(list, fn x -> x > 10 end)    # nil
Enum.find(list, :default, &(&1 > 10))  # :default

Enum.at(list, 0)     # 1
Enum.at(list, 10)    # nil
Enum.at(list, 10, 0) # 0 (default)

Enum.member?(list, 3)  # true
3 in list              # true (syntactic sugar)
```

### Aggregations

```elixir
list = [1, 2, 3, 4, 5]

Enum.sum(list)        # 15
Enum.product(list)    # 120
Enum.count(list)      # 5
Enum.max(list)        # 5
Enum.min(list)        # 1

Enum.max_by(["a", "abc", "ab"], &String.length/1)  # "abc"
Enum.min_by(["a", "abc", "ab"], &String.length/1)  # "a"
```

### Slicing and Taking

```elixir
list = [1, 2, 3, 4, 5]

Enum.take(list, 3)       # [1, 2, 3]
Enum.take(list, -2)      # [4, 5]
Enum.drop(list, 2)       # [3, 4, 5]
Enum.slice(list, 1, 3)   # [2, 3, 4]

Enum.take_while(list, fn x -> x < 4 end)  # [1, 2, 3]
Enum.drop_while(list, fn x -> x < 4 end)  # [4, 5]
```

### Sorting and Reversing

```elixir
Enum.sort([3, 1, 4, 1, 5])           # [1, 1, 3, 4, 5]
Enum.sort([3, 1, 4], :desc)          # [4, 3, 1]
Enum.sort_by(users, & &1.name)       # Sort by name field
Enum.reverse([1, 2, 3])              # [3, 2, 1]

Enum.shuffle([1, 2, 3, 4, 5])        # Random order
```

### Grouping and Chunking

```elixir
# group_by
users = [%{name: "Alice", role: :admin}, %{name: "Bob", role: :user}]
Enum.group_by(users, & &1.role)
# %{admin: [%{name: "Alice", ...}], user: [%{name: "Bob", ...}]}

# chunk_every
Enum.chunk_every([1, 2, 3, 4, 5], 2)
# [[1, 2], [3, 4], [5]]

# chunk_by
Enum.chunk_by([1, 1, 2, 2, 3], fn x -> x end)
# [[1, 1], [2, 2], [3]]
```

### Joining and Flattening

```elixir
Enum.join(["a", "b", "c"], "-")  # "a-b-c"
Enum.join([1, 2, 3])             # "123"

Enum.flat_map([[1, 2], [3, 4]], fn x -> x end)  # [1, 2, 3, 4]
Enum.concat([[1, 2], [3, 4]])                   # [1, 2, 3, 4]
```

### Boolean Checks

```elixir
list = [1, 2, 3, 4, 5]

Enum.all?(list, fn x -> x > 0 end)   # true
Enum.any?(list, fn x -> x > 4 end)   # true
Enum.empty?([])                       # true
Enum.empty?(list)                     # false
```

---

## Reduce: The Swiss Army Knife

`reduce` is the most powerful function - you can implement most others with it:

```elixir
# Basic reduce
Enum.reduce([1, 2, 3, 4], 0, fn x, acc -> acc + x end)
# 10

# Reduce with initial value from first element
Enum.reduce([1, 2, 3, 4], fn x, acc -> acc + x end)
# 10 (same result, different signature)
```

### Build Your Own Functions

```elixir
# Implement map with reduce
def my_map(list, func) do
  list
  |> Enum.reduce([], fn x, acc -> [func.(x) | acc] end)
  |> Enum.reverse()
end

# Implement filter with reduce
def my_filter(list, func) do
  list
  |> Enum.reduce([], fn x, acc ->
    if func.(x), do: [x | acc], else: acc
  end)
  |> Enum.reverse()
end

# Count occurrences
words = ["apple", "banana", "apple", "cherry", "apple"]
Enum.reduce(words, %{}, fn word, acc ->
  Map.update(acc, word, 1, &(&1 + 1))
end)
# %{"apple" => 3, "banana" => 1, "cherry" => 1}
```

---

## Working with Maps

```elixir
map = %{a: 1, b: 2, c: 3}

# Iterate key-value pairs
Enum.map(map, fn {k, v} -> {k, v * 2} end)
# [a: 2, b: 4, c: 6]  (returns keyword list!)

Enum.into(
  Enum.map(map, fn {k, v} -> {k, v * 2} end),
  %{}
)
# %{a: 2, b: 4, c: 6}

# Or use Map functions
Map.new(map, fn {k, v} -> {k, v * 2} end)
# %{a: 2, b: 4, c: 6}
```

---

## Comprehensions

List comprehensions are syntactic sugar for common patterns:

```elixir
# Basic comprehension
for x <- [1, 2, 3], do: x * 2
# [2, 4, 6]

# With filter
for x <- 1..10, x > 5, do: x * 2
# [12, 14, 16, 18, 20]

# Multiple generators
for x <- [1, 2], y <- [:a, :b], do: {x, y}
# [{1, :a}, {1, :b}, {2, :a}, {2, :b}]

# Pattern matching
for {:ok, value} <- [{:ok, 1}, {:error, 2}, {:ok, 3}], do: value
# [1, 3]

# Into different collection
for x <- [1, 2, 3], into: %{}, do: {x, x * x}
# %{1 => 1, 2 => 4, 3 => 9}

for char <- ~c"hello", into: "", do: <<char>>
# "hello"
```

---

## Recursion

Elixir has no traditional loops. Use recursion instead:

### Basic Recursion

```elixir
defmodule Example do
  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)
end

iex> Example.sum([1, 2, 3, 4, 5])
15
```

### Tail Call Optimization

Regular recursion builds up stack frames. Tail recursion uses constant stack:

```elixir
defmodule Example do
  # NOT tail recursive (builds stack)
  def sum_bad([]), do: 0
  def sum_bad([h | t]), do: h + sum_bad(t)

  # Tail recursive (constant stack)
  def sum_good(list), do: do_sum(list, 0)

  defp do_sum([], acc), do: acc
  defp do_sum([h | t], acc), do: do_sum(t, acc + h)
end
```

### Common Recursive Patterns

```elixir
defmodule Recursion do
  # Map
  def map([], _func), do: []
  def map([h | t], func), do: [func.(h) | map(t, func)]

  # Filter
  def filter([], _func), do: []
  def filter([h | t], func) do
    if func.(h) do
      [h | filter(t, func)]
    else
      filter(t, func)
    end
  end

  # Reduce
  def reduce([], acc, _func), do: acc
  def reduce([h | t], acc, func) do
    reduce(t, func.(h, acc), func)
  end

  # Length
  def length([]), do: 0
  def length([_ | t]), do: 1 + length(t)

  # Reverse
  def reverse(list), do: do_reverse(list, [])
  defp do_reverse([], acc), do: acc
  defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
end
```

### When to Use Recursion vs Enum

| Use Enum                    | Use Recursion                     |
| --------------------------- | --------------------------------- |
| Standard operations         | Custom traversal logic            |
| Clarity matters most        | Performance critical              |
| Working with any enumerable | Building your own data structures |
| Team code                   | Understanding fundamentals        |

---

## Streams: Lazy Enumeration

Streams are lazy - they don't compute until needed:

```elixir
# This builds entire list in memory
1..1_000_000
|> Enum.map(&(&1 * 2))
|> Enum.take(5)

# This only computes what's needed
1..1_000_000
|> Stream.map(&(&1 * 2))
|> Enum.take(5)
# [2, 4, 6, 8, 10]
```

### Stream Functions

```elixir
# Infinite streams
Stream.cycle([1, 2, 3]) |> Enum.take(7)
# [1, 2, 3, 1, 2, 3, 1]

Stream.repeatedly(fn -> :rand.uniform() end) |> Enum.take(3)
# [0.123, 0.456, 0.789]

Stream.iterate(1, &(&1 * 2)) |> Enum.take(5)
# [1, 2, 4, 8, 16]

# File streaming (memory efficient)
File.stream!("large_file.txt")
|> Stream.map(&String.trim/1)
|> Stream.filter(&(&1 != ""))
|> Enum.to_list()
```

---

## Try It

```elixir
# Basic Enum operations
iex> [1, 2, 3, 4, 5] |> Enum.map(&(&1 * 2)) |> Enum.filter(&(&1 > 5))

# Reduce to build a map
iex> ["a", "b", "a", "c", "b", "a"]
...> |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

# Comprehension
iex> for x <- 1..5, y <- 1..5, x < y, do: {x, y}

# Write recursive sum
defmodule MyMath do
  def sum([]), do: 0
  def sum([h | t]), do: h + sum(t)
end
iex> MyMath.sum([1, 2, 3, 4, 5])

# Streams vs Enum
iex> 1..100 |> Stream.map(&IO.inspect/1) |> Enum.take(3)
# Only prints 1, 2, 3

iex> 1..100 |> Enum.map(&IO.inspect/1) |> Enum.take(3)
# Prints 1 through 100!
```

---

## Key Takeaways

1. **`Enum` for most collection work** - map, filter, reduce, find
2. **`reduce` is foundational** - Can implement most others
3. **Comprehensions for readable transforms** - `for x <- list, do: ...`
4. **Recursion with pattern matching** - Base case + recursive case
5. **Tail recursion for efficiency** - Use accumulator pattern
6. **Streams for large/infinite data** - Lazy evaluation

---

**Next:** [Processes →](./09-processes.md)
