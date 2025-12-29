defmodule Chatroom.Examples.ElixirBasics do
  @moduledoc """
  Example module demonstrating core Elixir concepts.

  Run these examples in IEx:
      iex -S mix
      alias Chatroom.Examples.ElixirBasics
      ElixirBasics.run_all()
  """

  # ============================================================
  # PATTERN MATCHING
  # ============================================================

  @doc """
  Demonstrates pattern matching - Elixir's most powerful feature.
  The = operator is the MATCH operator, not assignment!
  """
  def pattern_matching_demo do
    IO.puts("\n=== Pattern Matching Demo ===\n")

    # Basic binding
    x = 1
    IO.puts("x = 1 binds x to 1: #{x}")

    # Tuple destructuring (VERY common in Phoenix)
    {:ok, value} = {:ok, 42}
    IO.puts("{:ok, value} = {:ok, 42} -> value = #{value}")

    # This is how you handle errors in Elixir!
    result = {:error, "something went wrong"}
    case result do
      {:ok, data} -> IO.puts("Success: #{data}")
      {:error, msg} -> IO.puts("Error handled: #{msg}")
    end

    # List destructuring
    [head | tail] = [1, 2, 3, 4, 5]
    IO.puts("[head | tail] = [1,2,3,4,5] -> head=#{head}, tail=#{inspect(tail)}")

    # Map destructuring
    user = %{name: "Alice", age: 30, city: "Portland"}
    %{name: name, age: age} = user
    IO.puts("Extracted from map: name=#{name}, age=#{age}")

    # Pin operator ^ - match without rebinding
    expected = 42
    ^expected = 42  # Matches!
    IO.puts("Pin operator ^expected = 42 matches when expected is 42")

    :ok
  end

  # ============================================================
  # FUNCTION CLAUSES & GUARDS
  # ============================================================

  @doc """
  Multiple function clauses with pattern matching.
  Elixir matches from top to bottom, first match wins.
  """
  def fizzbuzz(n) when rem(n, 15) == 0, do: "FizzBuzz"
  def fizzbuzz(n) when rem(n, 3) == 0, do: "Fizz"
  def fizzbuzz(n) when rem(n, 5) == 0, do: "Buzz"
  def fizzbuzz(n), do: to_string(n)

  def fizzbuzz_demo do
    IO.puts("\n=== FizzBuzz with Pattern Matching ===\n")

    1..20
    |> Enum.map(&fizzbuzz/1)
    |> Enum.join(", ")
    |> IO.puts()
  end

  # Pattern matching on data structures
  def describe_list([]), do: "empty list"
  def describe_list([_]), do: "single element"
  def describe_list([_, _]), do: "two elements"
  def describe_list([_ | _]), do: "multiple elements"

  # Pattern matching with guards
  def classify_number(n) when is_integer(n) and n > 0, do: "positive integer"
  def classify_number(n) when is_integer(n) and n < 0, do: "negative integer"
  def classify_number(0), do: "zero"
  def classify_number(n) when is_float(n), do: "float"
  def classify_number(_), do: "not a number"

  # ============================================================
  # PIPES
  # ============================================================

  @doc """
  The pipe operator |> transforms nested calls into readable pipelines.
  Data flows left-to-right, passing as the FIRST argument.
  """
  def pipe_demo do
    IO.puts("\n=== Pipe Operator Demo ===\n")

    # Without pipes (read inside-out, hard to follow)
    result1 = Enum.join(Enum.map(Enum.filter(1..10, &(rem(&1, 2) == 0)), &(&1 * 2)), ", ")
    IO.puts("Without pipes: #{result1}")

    # With pipes (read top-to-bottom, easy to follow)
    result2 =
      1..10
      |> Enum.filter(&(rem(&1, 2) == 0))  # Keep even numbers
      |> Enum.map(&(&1 * 2))               # Double them
      |> Enum.join(", ")                   # Join with comma

    IO.puts("With pipes: #{result2}")

    # Real-world example: processing user data
    users = [
      %{name: "Alice", age: 25, active: true},
      %{name: "Bob", age: 17, active: true},
      %{name: "Charlie", age: 30, active: false},
      %{name: "Diana", age: 22, active: true}
    ]

    active_adult_names =
      users
      |> Enum.filter(& &1.active)           # Only active users
      |> Enum.filter(&(&1.age >= 18))       # Only adults
      |> Enum.map(& &1.name)                # Extract names
      |> Enum.sort()                        # Sort alphabetically

    IO.puts("Active adults: #{inspect(active_adult_names)}")
  end

  # ============================================================
  # RECURSION (No loops in Elixir!)
  # ============================================================

  @doc """
  Elixir has no for/while loops - use recursion or Enum functions.
  """

  # Basic recursion
  def sum_list([]), do: 0
  def sum_list([head | tail]), do: head + sum_list(tail)

  # Tail-call optimized version (accumulator pattern)
  # This won't blow the stack on large lists
  def sum_list_tco(list), do: do_sum(list, 0)
  defp do_sum([], acc), do: acc
  defp do_sum([head | tail], acc), do: do_sum(tail, acc + head)

  # Factorial
  def factorial(0), do: 1
  def factorial(n) when n > 0, do: n * factorial(n - 1)

  # Fibonacci (naive - demonstrates concept, not efficient)
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n) when n > 1, do: fib(n - 1) + fib(n - 2)

  def recursion_demo do
    IO.puts("\n=== Recursion Demo ===\n")

    IO.puts("sum_list([1,2,3,4,5]) = #{sum_list([1, 2, 3, 4, 5])}")
    IO.puts("factorial(5) = #{factorial(5)}")
    IO.puts("First 10 Fibonacci: #{inspect(Enum.map(0..9, &fib/1))}")
  end

  # ============================================================
  # STRUCTS
  # ============================================================

  defmodule Person do
    @moduledoc "Example struct"
    defstruct [:name, :email, age: 0, role: :user]

    def new(name, email, opts \\ []) do
      %__MODULE__{
        name: name,
        email: email,
        age: Keyword.get(opts, :age, 0),
        role: Keyword.get(opts, :role, :user)
      }
    end

    def adult?(%__MODULE__{age: age}), do: age >= 18

    def promote(%__MODULE__{} = person) do
      %{person | role: :admin}
    end
  end

  def struct_demo do
    IO.puts("\n=== Struct Demo ===\n")

    # Create with struct syntax
    person1 = %Person{name: "Alice", email: "alice@example.com", age: 25}
    IO.puts("Created: #{inspect(person1)}")

    # Create with constructor
    person2 = Person.new("Bob", "bob@example.com", age: 17)
    IO.puts("Created: #{inspect(person2)}")

    # Update (creates NEW struct, original unchanged)
    older_person = %{person2 | age: 18}
    IO.puts("Updated age: #{inspect(older_person)}")
    IO.puts("Original unchanged: #{inspect(person2)}")

    # Pattern match on struct
    %Person{name: name, role: role} = person1
    IO.puts("Extracted: name=#{name}, role=#{role}")

    # Use struct functions
    IO.puts("Alice adult? #{Person.adult?(person1)}")
    IO.puts("Bob adult? #{Person.adult?(person2)}")
  end

  # ============================================================
  # WITH EXPRESSION (Error handling pipelines)
  # ============================================================

  @doc """
  The `with` expression chains pattern matches.
  If any match fails, it short-circuits to the else clause.
  """
  def with_demo do
    IO.puts("\n=== With Expression Demo ===\n")

    # Simulated external calls that might fail
    fetch_user = fn id ->
      case id do
        1 -> {:ok, %{id: 1, name: "Alice"}}
        _ -> {:error, :user_not_found}
      end
    end

    fetch_posts = fn user ->
      {:ok, [%{title: "Post 1", author: user.name}]}
    end

    # Happy path - all matches succeed
    result1 = with {:ok, user} <- fetch_user.(1),
                   {:ok, posts} <- fetch_posts.(user) do
      {:ok, %{user: user, posts: posts}}
    else
      {:error, :user_not_found} -> {:error, "User not found"}
      {:error, reason} -> {:error, "Failed: #{inspect(reason)}"}
    end
    IO.puts("Happy path result: #{inspect(result1)}")

    # Sad path - first match fails
    result2 = with {:ok, user} <- fetch_user.(999),
                   {:ok, posts} <- fetch_posts.(user) do
      {:ok, %{user: user, posts: posts}}
    else
      {:error, :user_not_found} -> {:error, "User not found"}
      {:error, reason} -> {:error, "Failed: #{inspect(reason)}"}
    end
    IO.puts("Sad path result: #{inspect(result2)}")
  end

  # ============================================================
  # RUN ALL DEMOS
  # ============================================================

  def run_all do
    pattern_matching_demo()
    fizzbuzz_demo()
    pipe_demo()
    recursion_demo()
    struct_demo()
    with_demo()

    IO.puts("\n=== All demos complete! ===\n")
    :ok
  end
end
