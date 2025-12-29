# Common Errors

Solutions to errors you'll encounter while learning.

---

## MatchError

```
** (MatchError) no match of right hand side value: {:error, %Ecto.Changeset{}}
```

**Cause:** Pattern match failed. You expected `{:ok, result}` but got `{:error, changeset}`.

**Fix:** Handle both cases:

```elixir
case Chat.create_message(attrs) do
  {:ok, message} -> # success
  {:error, changeset} -> # handle error
end
```

---

## FunctionClauseError

```
** (FunctionClauseError) no function clause matching in MyModule.my_func/1
```

**Cause:** None of your function clauses match the arguments.

**Fix:** Add a catch-all clause or check your input:

```elixir
def my_func(x) when is_integer(x), do: x
def my_func(_), do: {:error, :invalid_input}  # catch-all
```

---

## UndefinedFunctionError

```
** (UndefinedFunctionError) function MyModule.foo/1 is undefined or private
```

**Cause:** The function doesn't exist, is private (`defp`), or wrong arity.

**Fix:**

- Check spelling
- Check if it's `defp` (private)
- Check number of arguments (`/1` means 1 argument)
- Make sure module is compiled

---

## CompileError: undefined function

```
** (CompileError) lib/my_module.ex:5: undefined function foo/0
```

**Cause:** Calling a function before it's defined, or calling local function incorrectly.

**Fix:**

- Make sure function is defined above where it's called, OR
- Elixir compiles full file first, so order doesn't matter for same module
- Check if you need to `import` or alias the module

---

## Protocol.UndefinedError

```
** (Protocol.UndefinedError) protocol Enumerable not implemented for %User{}
```

**Cause:** Trying to use `Enum` functions on a struct that doesn't implement `Enumerable`.

**Fix:** Convert to enumerable first:

```elixir
# If it's a struct, maybe you want a field?
Enum.map(user.posts, &(&1.title))

# Or convert struct to map
user |> Map.from_struct() |> Enum.map(...)
```

---

## Ecto.NoResultsError

```
** (Ecto.NoResultsError) expected at least one result but got none in query
```

**Cause:** `Repo.get!` or similar with `!` found no record.

**Fix:** Use non-bang version and handle nil:

```elixir
case Repo.get(User, id) do
  nil -> {:error, :not_found}
  user -> {:ok, user}
end
```

---

## Ecto.ConstraintError

```
** (Ecto.ConstraintError) constraint error when attempting to insert struct
```

**Cause:** Database constraint violated (unique, foreign key, etc.)

**Fix:** Add constraint handling to changeset:

```elixir
user
|> cast(attrs, [:email])
|> unique_constraint(:email)
```

---

## ArgumentError

```
** (ArgumentError) argument error
```

**Cause:** Wrong argument type passed to a function.

**Common cases:**

- Passing string when integer expected: `String.to_integer("abc")`
- Invalid regex: `Regex.match?(invalid_pattern, str)`

**Fix:** Validate input or convert types:

```elixir
case Integer.parse(input) do
  {num, _} -> {:ok, num}
  :error -> {:error, :invalid_number}
end
```

---

## KeyError

```
** (KeyError) key :foo not found in: %{bar: 1}
```

**Cause:** Accessing map key with `.` syntax when key doesn't exist.

**Fix:** Use `Map.get/3` or `[]` syntax:

```elixir
# Returns nil if missing
map[:foo]
Map.get(map, :foo)

# With default
Map.get(map, :foo, "default")
```

---

## BadMapError

```
** (BadMapError) expected a map, got: nil
```

**Cause:** Trying to access `.key` on nil.

**Fix:** Handle nil case:

```elixir
# Check first
if user, do: user.name, else: "Anonymous"

# Or pattern match
case get_user(id) do
  nil -> "not found"
  user -> user.name
end
```

---

## Phoenix: "no route found"

```
no route found for GET / (MyAppWeb.Router)
```

**Cause:** Missing route in router.

**Fix:** Add the route:

```elixir
scope "/", MyAppWeb do
  pipe_through :browser
  get "/", PageController, :home
end
```

---

## LiveView: "assign @foo not available"

```
assign @foo not available in eex template
```

**Cause:** Using `@foo` in template but never assigned it.

**Fix:** Add to mount:

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket, foo: "value")}
end
```

---

## Database: "relation does not exist"

```
** (Postgrex.Error) ERROR 42P01 (undefined_table) relation "users" does not exist
```

**Cause:** Table doesn't exist. Migrations not run.

**Fix:**

```bash
mix ecto.create   # if database doesn't exist
mix ecto.migrate  # run migrations
```

---

## Mix: "could not find dependency"

```
** (Mix) Could not find dependency :some_dep
```

**Cause:** Dependency not in `mix.exs` or not fetched.

**Fix:**

1. Add to `deps` in `mix.exs`
2. Run `mix deps.get`

---

## Debugging Tips

### Add IO.inspect

```elixir
data
|> IO.inspect(label: "before filter")
|> Enum.filter(&(&1.active))
|> IO.inspect(label: "after filter")
```

### Use IEx.pry

```elixir
require IEx
IEx.pry  # Drops you into IEx at this point
```

### Check process state

```elixir
:sys.get_state(pid)
```

### See full stack trace

```elixir
Process.info(self(), :current_stacktrace)
```
