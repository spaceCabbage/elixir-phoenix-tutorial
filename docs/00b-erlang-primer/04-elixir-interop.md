# Elixir-Erlang Interop: Using the Full Ecosystem

Elixir and Erlang are fully interoperable. You can call Erlang from Elixir (and vice versa) with zero overhead. This gives you access to decades of battle-tested libraries.

---

## The Basics: Calling Erlang

Erlang modules are atoms, Elixir modules are aliases. The mapping is simple:

| Erlang                      | Elixir                        |
| --------------------------- | ----------------------------- |
| `lists:reverse([1,2,3])`    | `:lists.reverse([1,2,3])`     |
| `crypto:hash(sha256, Data)` | `:crypto.hash(:sha256, data)` |
| `os:timestamp()`            | `:os.timestamp()`             |

The pattern: **`:module_name.function_name(args)`**

---

## Try It in IEx

```elixir
# Random numbers (Erlang's rand module)
iex> :rand.uniform(100)
42

# Cryptographic hashing
iex> :crypto.hash(:sha256, "hello")
<<44, 242, 77, 186, ...>>

# Base64 encoding
iex> :base64.encode("hello world")
"aGVsbG8gd29ybGQ="

# Timer functions
iex> :timer.seconds(5)
5000

iex> :timer.sleep(1000)  # Sleep for 1 second
:ok

# System information
iex> :erlang.system_info(:otp_release)
~c"27"

iex> :erlang.system_info(:schedulers)
4

# OS interactions
iex> :os.type()
{:unix, :linux}

iex> :os.cmd(~c"whoami")
~c"alice\n"
```

---

## Useful Erlang Modules

These come with every Erlang installation:

| Module    | Purpose                    | Example                |
| --------- | -------------------------- | ---------------------- |
| `:crypto` | Cryptographic functions    | Hashing, encryption    |
| `:base64` | Base64 encoding/decoding   | Data serialization     |
| `:rand`   | Random number generation   | `:rand.uniform(100)`   |
| `:timer`  | Time-related utilities     | `:timer.sleep/1`       |
| `:os`     | Operating system interface | `:os.cmd/1`            |
| `:file`   | File operations            | `:file.read/1`         |
| `:lists`  | List operations            | `:lists.flatten/1`     |
| `:maps`   | Map operations             | `:maps.merge/2`        |
| `:ets`    | In-memory storage          | Fast key-value lookups |
| `:dets`   | Disk-based storage         | Persistent `:ets`      |
| `:mnesia` | Distributed database       | Built-in database      |
| `:httpc`  | HTTP client                | `:httpc.request/1`     |
| `:xmerl`  | XML parsing                | XML processing         |

---

## Charlists vs Strings

Here's a gotcha: Erlang uses **charlists** (lists of integers), Elixir uses **binary strings**.

```elixir
# Elixir string
iex> "hello"
"hello"

# Erlang charlist
iex> ~c"hello"
~c"hello"

# They're different!
iex> "hello" == ~c"hello"
false

# Erlang functions often return charlists
iex> :os.cmd(~c"echo hi")
~c"hi\n"

# Convert charlist to string
iex> :os.cmd(~c"echo hi") |> to_string()
"hi\n"

# Convert string to charlist
iex> String.to_charlist("hello")
~c"hello"
```

### The Rule

- Elixir functions expect and return binary strings: `"hello"`
- Erlang functions often expect and return charlists: `~c"hello"`
- Use `to_string/1` and `String.to_charlist/1` to convert

---

## Using ETS (In-Memory Cache)

ETS (Erlang Term Storage) is an incredibly fast in-memory key-value store. It's often faster than Redis for local data.

```elixir
# Create a table
iex> :ets.new(:my_cache, [:set, :public, :named_table])
:my_cache

# Insert data
iex> :ets.insert(:my_cache, {"key1", "value1"})
true
iex> :ets.insert(:my_cache, {"key2", %{complex: "data"}})
true

# Lookup
iex> :ets.lookup(:my_cache, "key1")
[{"key1", "value1"}]

# Delete
iex> :ets.delete(:my_cache, "key1")
true

# Check if exists
iex> :ets.member(:my_cache, "key2")
true
```

Phoenix uses ETS internally for session storage and PubSub.

---

## Using Erlang Libraries via Mix

Many great libraries are written in Erlang. Use them directly:

```elixir
# mix.exs
defp deps do
  [
    {:poolboy, "~> 1.5"},     # Erlang connection pooling
    {:jsx, "~> 3.0"},         # Erlang JSON parser
    {:cowboy, "~> 2.9"},      # Erlang web server (Phoenix uses this)
  ]
end
```

Then call them like any Erlang module:

```elixir
iex> :jsx.encode(%{hello: "world"})
"{\"hello\":\"world\"}"
```

---

## Reading Erlang Code

You'll occasionally see Erlang code or error messages. Here's a quick translation guide:

### Syntax Comparison

```erlang
%% Erlang
-module(example).
-export([hello/1, add/2]).

hello(Name) ->
    io:format("Hello, ~s!~n", [Name]).

add(A, B) ->
    A + B.
```

```elixir
# Elixir equivalent
defmodule Example do
  def hello(name) do
    IO.puts("Hello, #{name}!")
  end

  def add(a, b) do
    a + b
  end
end
```

### Key Differences

| Erlang                            | Elixir                         |
| --------------------------------- | ------------------------------ |
| `module_name`                     | `ModuleName`                   |
| Variables start uppercase: `Name` | Variables lowercase: `name`    |
| Atoms start lowercase: `ok`       | Atoms have colon: `:ok`        |
| Period ends statements: `.`       | No statement terminator        |
| Comma separates, period ends      | Comma separates                |
| Pattern match with `=`            | Pattern match with `=` (same!) |
| `fun(X) -> X * 2 end`             | `fn x -> x * 2 end`            |

---

## Erlang Error Messages

When something goes wrong, you might see Erlang-style errors:

```elixir
iex> 1 / 0
** (ArithmeticError) bad argument in arithmetic expression
    :erlang./(1, 0)
```

The `:erlang./(1, 0)` tells you the actual Erlang function that failed.

```elixir
iex> :ets.lookup(:nonexistent, "key")
** (ArgumentError) argument error
    :ets.lookup(:nonexistent, "key")
```

This tells you the ETS table doesn't exist.

---

## The `:erlang` Module

The `:erlang` module contains fundamental operations:

```elixir
# Process operations
iex> :erlang.self()  # Same as self()
#PID<0.110.0>

iex> :erlang.spawn(fn -> IO.puts("hello") end)  # Same as spawn()
#PID<0.115.0>

# Type checks
iex> :erlang.is_list([1,2,3])  # Same as is_list()
true

# Arithmetic
iex> :erlang.+(1, 2)  # Same as 1 + 2
3

# Binary operations
iex> :erlang.binary_to_term(:erlang.term_to_binary(%{a: 1}))
%{a: 1}
```

Most of these have Elixir wrappers, but knowing they exist helps when reading stack traces.

---

## When to Use Erlang Directly

Use Erlang when:

1. **No Elixir wrapper exists** - e.g., `:crypto.hash/2`
2. **Performance critical** - Skip Elixir wrapper overhead
3. **Using Erlang libraries** - No Elixir port available
4. **System-level operations** - `:os`, `:file` for raw access

Use Elixir wrappers when:

1. **They exist** - `Enum` > `:lists`
2. **Better API** - Elixir often has nicer interfaces
3. **Consistency** - Keep codebase uniform

---

## Key Takeaways

1. **Call Erlang with `:module.function()`** - Zero overhead
2. **Charlists vs strings** - Convert with `to_string/1` and `String.to_charlist/1`
3. **Erlang standard library is yours** - `:crypto`, `:ets`, `:timer`, etc.
4. **Read Erlang stack traces** - They show you exactly what failed
5. **Mix works with Erlang deps** - Use any library from hex.pm

Elixir's power comes from standing on Erlang's shoulders. Don't hesitate to use Erlang modules directly - they're part of your toolkit.

---

**You've completed the Erlang Primer!**

**Next section:** [Elixir Fundamentals →](../01-elixir-fundamentals/)
