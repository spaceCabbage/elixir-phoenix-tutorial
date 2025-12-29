# Basic Types

Elixir has a rich type system. Understanding these fundamentals is essential.

---

## Numbers

### Integers

```elixir
iex> 42
42

iex> 1_000_000  # Underscores for readability
1000000

iex> 0xFF  # Hexadecimal
255

iex> 0b1010  # Binary
10

iex> 0o777  # Octal
511
```

Integers have arbitrary precision - no overflow:

```elixir
iex> 99999999999999999999999999999999999 * 2
199999999999999999999999999999999998
```

### Floats

```elixir
iex> 3.14
3.14

iex> 1.0e10  # Scientific notation
10000000000.0

iex> 1 / 2  # Division always returns float
0.5

iex> div(5, 2)  # Integer division
2

iex> rem(5, 2)  # Remainder (modulo)
1
```

---

## Atoms

Atoms are constants whose value is their own name. They're like symbols in Ruby or enums in other languages.

```elixir
iex> :hello
:hello

iex> :ok
:ok

iex> :error
:error

iex> :"with spaces"  # Quoted atom
:"with spaces"

iex> :hello == :hello
true

iex> :hello == :world
false
```

### Why Atoms Matter

Atoms are used everywhere in Elixir:

- Boolean values (`:true`, `:false`)
- Return status (`:ok`, `:error`)
- Map keys
- Module names (`String` is actually `:"Elixir.String"`)

```elixir
# Function return values
iex> File.read("mix.exs")
{:ok, "defmodule Chatroom.MixProject do..."}

iex> File.read("nonexistent.txt")
{:error, :enoent}
```

### Atoms are not garbage collected

Atoms are stored in a global table and never removed. Don't create atoms dynamically from user input:

```elixir
# BAD - could exhaust atom table
String.to_atom(user_input)

# GOOD - only converts existing atoms
String.to_existing_atom(user_input)
```

---

## Booleans

Booleans are just atoms:

```elixir
iex> true == :true
true

iex> false == :false
true

iex> is_atom(true)
true
```

### Boolean Operations

```elixir
iex> true and false
false

iex> true or false
true

iex> not true
false

# Short-circuit operators
iex> false and raise("never evaluated")
false

iex> true or raise("never evaluated")
true
```

### Truthiness

In boolean contexts, everything except `false` and `nil` is truthy:

```elixir
iex> if "hello", do: "truthy", else: "falsy"
"truthy"

iex> if 0, do: "truthy", else: "falsy"  # 0 is truthy!
"truthy"

iex> if nil, do: "truthy", else: "falsy"
"falsy"

iex> if false, do: "truthy", else: "falsy"
"falsy"
```

### Logical Operators

| Operator | Expects   | Returns              |
| -------- | --------- | -------------------- |
| `and`    | Boolean   | Boolean              |
| `or`     | Boolean   | Boolean              |
| `not`    | Boolean   | Boolean              |
| `&&`     | Any value | Last evaluated value |
| `\|\|`   | Any value | First truthy value   |
| `!`      | Any value | Boolean              |

```elixir
iex> nil || "default"
"default"

iex> "value" || "default"
"value"

iex> nil && "won't reach"
nil

iex> "truthy" && "also evaluated"
"also evaluated"
```

---

## Strings

Strings in Elixir are UTF-8 encoded binaries:

```elixir
iex> "Hello, World!"
"Hello, World!"

iex> "Hello, " <> "World!"  # Concatenation
"Hello, World!"

# String interpolation
iex> name = "Alice"
iex> "Hello, #{name}!"
"Hello, Alice!"

# Multiline strings
iex> """
...> This is a
...> multiline string
...> """
"This is a\nmultiline string\n"
```

### String Functions

```elixir
iex> String.length("hello")
5

iex> String.upcase("hello")
"HELLO"

iex> String.downcase("HELLO")
"hello"

iex> String.split("hello world")
["hello", "world"]

iex> String.split("a,b,c", ",")
["a", "b", "c"]

iex> String.trim("  hello  ")
"hello"

iex> String.contains?("hello", "ell")
true

iex> String.replace("hello", "l", "L")
"heLLo"

iex> String.slice("hello", 1, 3)
"ell"
```

### Strings vs Charlists

Remember from the Erlang primer:

```elixir
iex> "hello"  # Binary string (Elixir)
"hello"

iex> ~c"hello"  # Charlist (Erlang)
~c"hello"

iex> "hello" == ~c"hello"
false

iex> to_string(~c"hello")
"hello"

iex> String.to_charlist("hello")
~c"hello"
```

---

## Nil

`nil` represents the absence of a value:

```elixir
iex> nil
nil

iex> is_nil(nil)
true

iex> nil == false
false  # nil is NOT false, just falsy
```

---

## Comparison Operators

```elixir
iex> 1 == 1
true

iex> 1 == 1.0  # Loose equality
true

iex> 1 === 1.0  # Strict equality
false

iex> 1 != 2
true

iex> 1 !== 1.0
true

iex> 1 < 2
true

iex> 1 <= 1
true

iex> 2 > 1
true

iex> 2 >= 2
true
```

### Type Ordering

Elixir can compare any types (useful for sorting):

```
number < atom < reference < function < port < pid < tuple < map < list < bitstring
```

```elixir
iex> 1 < :atom
true

iex> :atom < "string"
true
```

---

## Immutability

All data in Elixir is immutable. Operations return new values:

```elixir
iex> name = "alice"
"alice"

iex> String.upcase(name)
"ALICE"

iex> name  # Original unchanged!
"alice"

iex> name = String.upcase(name)  # Rebind to new value
"ALICE"
```

This might seem inefficient, but:

1. The runtime shares memory efficiently
2. Immutability enables safe concurrency
3. Easier to reason about (no spooky action at a distance)

---

## Type Checking

```elixir
iex> is_integer(42)
true

iex> is_float(3.14)
true

iex> is_number(42)  # Integer or float
true

iex> is_atom(:hello)
true

iex> is_boolean(true)
true

iex> is_binary("hello")  # Strings are binaries
true

iex> is_nil(nil)
true
```

---

## Try It

```elixir
# Play with numbers
iex> 2 ** 100  # Exponentiation
1267650600228229401496703205376

# Inspect types
iex> i 42
# Shows detailed type info

iex> i "hello"
# Shows it's a binary

# String operations
iex> "HELLO" |> String.downcase() |> String.reverse()
"olleh"
```

---

## Key Takeaways

1. **Integers have arbitrary precision** - No overflow
2. **Atoms are constants** - Their value is their name
3. **Booleans are atoms** - `true` is `:true`
4. **Strings are UTF-8 binaries** - Use `String` module
5. **Everything is immutable** - Operations return new values
6. **Truthiness** - Only `nil` and `false` are falsy

---

**Next:** [Collections →](./02-collections.md)
