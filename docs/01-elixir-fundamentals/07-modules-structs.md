# Modules & Structs

Modules organize functions and define structs. They're the primary unit of code organization in Elixir.

---

## Modules

### Basic Module

```elixir
defmodule Math do
  def add(a, b), do: a + b
  def subtract(a, b), do: a - b
end

iex> Math.add(1, 2)
3
```

### Nested Modules

```elixir
defmodule Chatroom.Chat.Message do
  # ...
end

# Or nest definition
defmodule Chatroom do
  defmodule Chat do
    defmodule Message do
      # ...
    end
  end
end
```

### Module Attributes

```elixir
defmodule MyApp.Config do
  @default_timeout 5000
  @max_retries 3

  def timeout, do: @default_timeout
  def retries, do: @max_retries
end
```

Attributes are evaluated at **compile time**:

```elixir
defmodule Example do
  @compile_time DateTime.utc_now()  # Set once at compile

  def when_compiled, do: @compile_time
end
```

### Documentation Attributes

```elixir
defmodule Greeter do
  @moduledoc """
  Functions for greeting users.

  ## Examples

      iex> Greeter.hello("World")
      "Hello, World!"
  """

  @doc """
  Greets someone by name.

  ## Parameters
    - name: The name to greet

  ## Examples

      iex> Greeter.hello("Alice")
      "Hello, Alice!"
  """
  def hello(name), do: "Hello, #{name}!"

  @doc false  # Hide from documentation
  def internal_function, do: :hidden
end
```

View docs in IEx:

```elixir
iex> h Greeter
iex> h Greeter.hello
```

---

## Structs

Structs are maps with compile-time checks and defaults.

### Defining a Struct

```elixir
defmodule User do
  defstruct [:name, :email, age: 0, admin: false]
end
```

### Creating Structs

```elixir
iex> %User{}
%User{name: nil, email: nil, age: 0, admin: false}

iex> %User{name: "Alice", email: "alice@example.com"}
%User{name: "Alice", email: "alice@example.com", age: 0, admin: false}

# Unknown keys raise at compile time
iex> %User{unknown: "value"}
** (KeyError) key :unknown not found in: User
```

### Accessing Fields

```elixir
iex> user = %User{name: "Alice", age: 30}

iex> user.name
"Alice"

iex> user[:name]  # Also works
"Alice"
```

### Updating Structs

```elixir
iex> user = %User{name: "Alice", age: 30}

iex> %{user | age: 31}
%User{name: "Alice", age: 31, ...}

# Only existing keys allowed
iex> %{user | new_field: "value"}
** (KeyError) key :new_field not found
```

### Pattern Matching Structs

```elixir
def greet(%User{name: name}), do: "Hello, #{name}!"

def greet(%Admin{name: name}), do: "Hello, Admin #{name}!"

def greet(_), do: "Hello, stranger!"
```

### Struct with Functions

```elixir
defmodule User do
  defstruct [:name, :email, :age]

  def new(name, email, age \\ 0) do
    %__MODULE__{name: name, email: email, age: age}
  end

  def adult?(%__MODULE__{age: age}), do: age >= 18

  def birthday(%__MODULE__{age: age} = user) do
    %{user | age: age + 1}
  end
end
```

```elixir
iex> user = User.new("Alice", "alice@example.com", 25)
%User{name: "Alice", email: "alice@example.com", age: 25}

iex> User.adult?(user)
true

iex> User.birthday(user)
%User{name: "Alice", email: "alice@example.com", age: 26}
```

---

## `alias`, `import`, `require`, `use`

### `alias`

Shortens module names:

```elixir
defmodule MyApp.Services.UserService do
  alias MyApp.Schemas.User
  alias MyApp.Repo

  def get(id) do
    Repo.get(User, id)  # Instead of MyApp.Repo.get(MyApp.Schemas.User, id)
  end
end

# Alias multiple
alias MyApp.{Repo, Schemas.User, Services.Email}

# Alias with custom name
alias MyApp.VeryLongModuleName, as: Short
```

### `import`

Brings functions into scope:

```elixir
defmodule Example do
  import Enum, only: [map: 2, filter: 2]

  def double_positives(list) do
    list
    |> filter(&(&1 > 0))  # Without Enum. prefix
    |> map(&(&1 * 2))
  end
end

# Import options
import Module                    # All functions
import Module, only: [func: 1]   # Only specific functions
import Module, except: [func: 1] # All except specific
import Module, only: :functions  # Only functions, not macros
import Module, only: :macros     # Only macros
```

### `require`

Needed before using macros:

```elixir
defmodule Example do
  require Logger

  def hello do
    Logger.info("Hello!")  # Logger.info is a macro
  end
end
```

### `use`

Injects code via `__using__` macro:

```elixir
defmodule MyApp.Schema do
  use Ecto.Schema  # Injects schema-related macros

  schema "users" do
    field :name, :string
    timestamps()
  end
end
```

`use Module` roughly expands to:

```elixir
require Module
Module.__using__(opts)
```

### Summary Table

| Directive | Purpose                    | Common Use                    |
| --------- | -------------------------- | ----------------------------- |
| `alias`   | Shorten module name        | Less typing                   |
| `import`  | Bring functions into scope | DSLs, frequently used modules |
| `require` | Enable macros              | Logger, testing               |
| `use`     | Inject module code         | Ecto.Schema, GenServer        |

---

## Behaviours

Behaviours define interfaces (like interfaces in other languages):

```elixir
defmodule Parser do
  @callback parse(binary()) :: {:ok, term()} | {:error, term()}
  @callback extensions() :: [binary()]
end

defmodule JSONParser do
  @behaviour Parser

  @impl Parser
  def parse(content) do
    Jason.decode(content)
  end

  @impl Parser
  def extensions, do: [".json"]
end

defmodule XMLParser do
  @behaviour Parser

  @impl Parser
  def parse(content) do
    # XML parsing logic
  end

  @impl Parser
  def extensions, do: [".xml", ".xhtml"]
end
```

The `@impl` attribute documents that a function implements a behaviour callback.

---

## Protocols

Protocols enable polymorphism - different implementations for different types:

```elixir
defprotocol Size do
  @doc "Calculates the size of a data structure"
  def size(data)
end

defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end

defimpl Size, for: Map do
  def size(map), do: map_size(map)
end

defimpl Size, for: Tuple do
  def size(tuple), do: tuple_size(tuple)
end

defimpl Size, for: List do
  def size(list), do: length(list)
end
```

```elixir
iex> Size.size("hello")
5

iex> Size.size(%{a: 1, b: 2})
2

iex> Size.size({1, 2, 3})
3

iex> Size.size([1, 2, 3, 4])
4
```

### Implementing for Your Struct

```elixir
defmodule User do
  defstruct [:name, :friends]
end

defimpl Size, for: User do
  def size(%User{friends: friends}) do
    length(friends)
  end
end

iex> Size.size(%User{name: "Alice", friends: ["Bob", "Carol"]})
2
```

---

## The `__MODULE__` Special Form

`__MODULE__` returns the current module name:

```elixir
defmodule MyApp.User do
  def struct_name, do: __MODULE__
  # Returns MyApp.User

  def new(name) do
    %__MODULE__{name: name}
    # Same as %MyApp.User{name: name}
  end
end
```

---

## Try It

```elixir
# Define a struct
defmodule Pet do
  defstruct [:name, :species, age: 0]

  def grow_older(%__MODULE__{age: age} = pet) do
    %{pet | age: age + 1}
  end
end

iex> dog = %Pet{name: "Buddy", species: :dog, age: 3}
iex> Pet.grow_older(dog)
iex> dog.name

# Try alias
defmodule Example do
  alias Pet, as: P
  def make_cat(name), do: %P{name: name, species: :cat}
end

iex> Example.make_cat("Whiskers")
```

---

## Key Takeaways

1. **Modules organize code** - Functions, structs, documentation
2. **Structs are typed maps** - Compile-time key checking
3. **`alias` shortens names** - Less typing, clearer code
4. **`import` brings functions in** - Use sparingly
5. **`require` enables macros** - Needed for Logger, etc.
6. **`use` injects code** - For frameworks like Ecto, Phoenix
7. **Protocols = polymorphism** - Different implementations per type

---

**Next:** [Enum & Recursion →](./08-enum-recursion.md)
