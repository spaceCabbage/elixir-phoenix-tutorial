# Functions

Functions are first-class citizens in Elixir. There are two types: named functions (in modules) and anonymous functions.

---

## Anonymous Functions

Create with `fn -> end`:

```elixir
iex> add = fn a, b -> a + b end
#Function<...>

iex> add.(1, 2)  # Note the dot!
3

# Single expression shorthand
iex> double = &(&1 * 2)
#Function<...>

iex> double.(5)
10

# Multi-argument capture
iex> add = &(&1 + &2)
#Function<...>

iex> add.(3, 4)
7
```

### Why the Dot?

The dot distinguishes anonymous function calls from named function calls:

```elixir
iex> greet = fn name -> "Hello, #{name}" end

# Anonymous function - needs dot
iex> greet.("Alice")
"Hello, Alice"

# Named function - no dot
iex> String.upcase("hello")
"HELLO"
```

### Pattern Matching in Anonymous Functions

```elixir
iex> handle = fn
...>   {:ok, value} -> "Success: #{value}"
...>   {:error, reason} -> "Error: #{reason}"
...> end

iex> handle.({:ok, 42})
"Success: 42"

iex> handle.({:error, "not found"})
"Error: not found"
```

---

## Named Functions

Named functions live in modules:

```elixir
defmodule Math do
  def add(a, b) do
    a + b
  end

  def multiply(a, b) do
    a * b
  end
end

iex> Math.add(1, 2)
3

iex> Math.multiply(3, 4)
12
```

### Single-Line Syntax

```elixir
defmodule Math do
  def add(a, b), do: a + b
  def multiply(a, b), do: a * b
end
```

---

## Private Functions

Use `defp` for functions only callable within the module:

```elixir
defmodule Greeting do
  def hello(name) do
    format_greeting("Hello", name)
  end

  defp format_greeting(greeting, name) do
    "#{greeting}, #{name}!"
  end
end

iex> Greeting.hello("Alice")
"Hello, Alice!"

iex> Greeting.format_greeting("Hi", "Bob")
** (UndefinedFunctionError) function Greeting.format_greeting/2 is undefined or private
```

---

## Function Arity

A function's arity is its number of arguments. Same name with different arities are different functions:

```elixir
defmodule Greeter do
  def hello, do: "Hello, World!"
  def hello(name), do: "Hello, #{name}!"
  def hello(first, last), do: "Hello, #{first} #{last}!"
end

iex> Greeter.hello()
"Hello, World!"

iex> Greeter.hello("Alice")
"Hello, Alice!"

iex> Greeter.hello("Alice", "Smith")
"Hello, Alice Smith!"
```

We refer to these as:

- `Greeter.hello/0`
- `Greeter.hello/1`
- `Greeter.hello/2`

---

## Default Arguments

Use `\\` for defaults:

```elixir
defmodule Greeter do
  def hello(name \\ "World") do
    "Hello, #{name}!"
  end
end

iex> Greeter.hello()
"Hello, World!"

iex> Greeter.hello("Alice")
"Hello, Alice!"
```

### Multiple Defaults with Header

```elixir
defmodule Example do
  # Declare defaults in header
  def greet(name \\ "stranger", greeting \\ "Hello")

  def greet(name, greeting) do
    "#{greeting}, #{name}!"
  end
end

iex> Example.greet()
"Hello, stranger!"

iex> Example.greet("Alice")
"Hello, Alice!"

iex> Example.greet("Alice", "Hi")
"Hi, Alice!"
```

---

## Multiple Function Clauses

Define the same function multiple times with different patterns:

```elixir
defmodule Factorial do
  def of(0), do: 1
  def of(n) when n > 0, do: n * of(n - 1)
end

iex> Factorial.of(5)
120
```

Elixir tries clauses top-to-bottom:

```elixir
defmodule FizzBuzz do
  def say(n) when rem(n, 15) == 0, do: "FizzBuzz"
  def say(n) when rem(n, 3) == 0, do: "Fizz"
  def say(n) when rem(n, 5) == 0, do: "Buzz"
  def say(n), do: to_string(n)
end

iex> Enum.map(1..15, &FizzBuzz.say/1)
["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz"]
```

---

## Guards

Guards add conditions to function clauses:

```elixir
defmodule Guard do
  def check(x) when is_integer(x), do: "integer: #{x}"
  def check(x) when is_float(x), do: "float: #{x}"
  def check(x) when is_binary(x), do: "string: #{x}"
  def check(x) when is_list(x), do: "list with #{length(x)} elements"
  def check(_), do: "something else"
end

iex> Guard.check(42)
"integer: 42"

iex> Guard.check(3.14)
"float: 3.14"

iex> Guard.check("hello")
"string: hello"

iex> Guard.check([1, 2, 3])
"list with 3 elements"
```

### Allowed in Guards

| Category    | Functions                                                                                                                                                   |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Comparison  | `==`, `!=`, `===`, `!==`, `<`, `>`, `<=`, `>=`                                                                                                              |
| Boolean     | `and`, `or`, `not`                                                                                                                                          |
| Arithmetic  | `+`, `-`, `*`, `/`                                                                                                                                          |
| Membership  | `in`                                                                                                                                                        |
| Type checks | `is_atom/1`, `is_binary/1`, `is_boolean/1`, `is_float/1`, `is_function/1`, `is_integer/1`, `is_list/1`, `is_map/1`, `is_nil/1`, `is_number/1`, `is_tuple/1` |
| Other       | `abs/1`, `bit_size/1`, `byte_size/1`, `div/2`, `elem/2`, `hd/1`, `length/1`, `map_size/1`, `rem/2`, `round/1`, `tl/1`, `trunc/1`, `tuple_size/1`            |

### Guard with `when`

```elixir
def process(data) when is_map(data) and map_size(data) > 0 do
  # Handle non-empty map
end

def process(list) when is_list(list) and length(list) <= 100 do
  # Handle small list
end
```

---

## Capturing Functions

Use `&` to reference a function:

```elixir
# Capture named function
iex> fun = &String.upcase/1
&String.upcase/1

iex> fun.("hello")
"HELLO"

# Pass to higher-order functions
iex> Enum.map(["a", "b", "c"], &String.upcase/1)
["A", "B", "C"]

# Capture with partial application
iex> add_ten = &(&1 + 10)
iex> add_ten.(5)
15

# More complex capture
iex> format = &"Hello, #{&1}!"
iex> format.("Alice")
"Hello, Alice!"
```

---

## Passing Functions

Functions as arguments:

```elixir
defmodule Example do
  def apply_twice(fun, value) do
    fun.(fun.(value))
  end
end

iex> double = fn x -> x * 2 end
iex> Example.apply_twice(double, 5)
20

iex> Example.apply_twice(&String.upcase/1, "hello")
"HELLO"
```

---

## Returning Functions (Closures)

Functions can return functions and capture variables:

```elixir
defmodule Adder do
  def make_adder(n) do
    fn x -> x + n end  # n is captured in the closure
  end
end

iex> add_5 = Adder.make_adder(5)
iex> add_5.(10)
15

iex> add_100 = Adder.make_adder(100)
iex> add_100.(10)
110
```

---

## Try It

```elixir
# Anonymous functions
iex> square = fn x -> x * x end
iex> square.(4)

iex> shorter = &(&1 * &1)
iex> shorter.(4)

# Pattern matching in clauses
defmodule Response do
  def handle({:ok, data}), do: "Got: #{inspect(data)}"
  def handle({:error, reason}), do: "Error: #{reason}"
  def handle(:retry), do: "Retrying..."
end

iex> Response.handle({:ok, [1, 2, 3]})
iex> Response.handle({:error, "timeout"})
iex> Response.handle(:retry)

# Guards
defmodule Validator do
  def valid?(str) when is_binary(str) and byte_size(str) > 0, do: true
  def valid?(_), do: false
end

iex> Validator.valid?("hello")
iex> Validator.valid?("")
iex> Validator.valid?(123)
```

---

## Key Takeaways

1. **Anonymous functions need `.` to call** - `fun.(arg)`
2. **Capture shorthand** - `&(&1 + &2)` creates anonymous functions
3. **Same name, different arity = different functions** - `foo/1` vs `foo/2`
4. **Pattern match in function heads** - Multiple clauses, top-to-bottom
5. **Guards add conditions** - `when is_integer(x) and x > 0`
6. **`&` captures functions** - `&String.upcase/1`
7. **Closures capture variables** - Functions remember their creation context

---

**Next:** [Pipe Operator →](./05-pipe-operator.md)
