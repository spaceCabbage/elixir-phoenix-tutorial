# Changesets

Changesets track and validate changes to data before persisting. They're the core of Ecto's data validation.

---

## What is a Changeset?

A changeset wraps:

- The original data (struct)
- The proposed changes (params)
- Validation results (errors)
- Whether it's valid

```elixir
%Ecto.Changeset{
  data: %Message{},           # Original struct
  params: %{"body" => "hi"},  # Incoming data
  changes: %{body: "hi"},     # Validated changes
  errors: [],                 # Validation errors
  valid?: true                # Overall validity
}
```

---

## Basic Changeset

```elixir
defmodule Chatroom.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :username, :string
    field :body, :string
    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:username, :body])           # Allow these fields
    |> validate_required([:username, :body])      # Require these
    |> validate_length(:username, min: 1, max: 20)
    |> validate_length(:body, min: 1, max: 500)
  end
end
```

---

## The Pipeline

```elixir
%Message{}                    # Start with struct
|> cast(attrs, [:field1])     # Cast permitted fields
|> validate_required([...])   # Validate presence
|> validate_length(...)       # Validate length
|> validate_format(...)       # Validate pattern
|> unique_constraint(...)     # Database constraints
```

Each function returns a changeset, enabling the pipeline.

---

## `cast/3` - Filtering Params

```elixir
# Only allow specific fields
cast(message, attrs, [:username, :body])

# attrs might have extra fields - they're ignored
attrs = %{"username" => "alice", "body" => "hi", "admin" => true}
# Only :username and :body are processed
# :admin is silently ignored (security!)
```

---

## Common Validations

### Required Fields

```elixir
validate_required(changeset, [:username, :body])
# Error: "can't be blank"
```

### Length

```elixir
validate_length(changeset, :username, min: 1, max: 20)
validate_length(changeset, :bio, max: 500)
validate_length(changeset, :password, min: 8)
# Error: "should be at least %{count} character(s)"
```

### Format

```elixir
validate_format(changeset, :email, ~r/@/)
validate_format(changeset, :phone, ~r/^\d{10}$/)
# Error: "has invalid format"
```

### Inclusion/Exclusion

```elixir
validate_inclusion(changeset, :role, ["user", "admin", "moderator"])
validate_exclusion(changeset, :username, ["admin", "root", "system"])
# Error: "is invalid"
```

### Number

```elixir
validate_number(changeset, :age, greater_than: 0)
validate_number(changeset, :price, greater_than_or_equal_to: 0)
validate_number(changeset, :quantity, less_than: 100)
# Error: "must be greater than %{number}"
```

### Acceptance

```elixir
validate_acceptance(changeset, :terms_of_service)
# For checkboxes - must be true
```

### Confirmation

```elixir
validate_confirmation(changeset, :password)
# Requires :password_confirmation to match :password
```

### Custom Validation

```elixir
def changeset(user, attrs) do
  user
  |> cast(attrs, [:username])
  |> validate_no_profanity(:username)
end

defp validate_no_profanity(changeset, field) do
  validate_change(changeset, field, fn _, value ->
    if contains_profanity?(value) do
      [{field, "contains inappropriate language"}]
    else
      []
    end
  end)
end
```

---

## Database Constraints

These check against the database:

```elixir
def changeset(user, attrs) do
  user
  |> cast(attrs, [:email, :username])
  |> unique_constraint(:email)
  |> unique_constraint(:username)
  |> foreign_key_constraint(:team_id)
  |> check_constraint(:age, name: :age_must_be_positive)
end
```

**Note:** These only trigger on `Repo.insert/update`. Define the constraint in a migration first!

---

## Error Handling

```elixir
changeset = Message.changeset(%Message{}, %{})

changeset.valid?
# false

changeset.errors
# [username: {"can't be blank", [validation: :required]},
#  body: {"can't be blank", [validation: :required]}]

# Get human-readable errors
Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
  Enum.reduce(opts, msg, fn {key, value}, acc ->
    String.replace(acc, "%{#{key}}", to_string(value))
  end)
end)
# %{username: ["can't be blank"], body: ["can't be blank"]}
```

---

## Using Changesets

### Insert

```elixir
attrs = %{"username" => "alice", "body" => "hello"}

%Message{}
|> Message.changeset(attrs)
|> Repo.insert()

# Returns {:ok, %Message{}} or {:error, %Changeset{}}
```

### Update

```elixir
message = Repo.get!(Message, 1)

message
|> Message.changeset(%{"body" => "updated"})
|> Repo.update()
```

### In Contexts

```elixir
def create_message(attrs) do
  %Message{}
  |> Message.changeset(attrs)
  |> Repo.insert()
end

def update_message(%Message{} = message, attrs) do
  message
  |> Message.changeset(attrs)
  |> Repo.update()
end
```

---

## Multiple Changesets

Different changesets for different purposes:

```elixir
defmodule User do
  # Basic updates
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end

  # Registration (includes password)
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> hash_password()
  end

  # Admin updates (can change role)
  def admin_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:role])
    |> validate_inclusion(:role, ["user", "admin"])
  end
end
```

---

## `change/2` for Simple Changes

For programmatic changes (not user input):

```elixir
# change/2 doesn't cast - used for trusted data
Ecto.Changeset.change(%Message{}, body: "hello", username: "system")

# Or build from changeset
changeset
|> Ecto.Changeset.put_change(:status, :published)
|> Ecto.Changeset.put_change(:published_at, DateTime.utc_now())
```

---

## Forms and Changesets

In Phoenix, changesets power forms:

```elixir
# Controller/LiveView
def new(conn, _params) do
  changeset = Chat.change_message(%Message{})
  render(conn, :new, changeset: changeset)
end
```

```heex
<.simple_form for={@changeset} action={~p"/messages"}>
  <.input field={@changeset[:username]} label="Username" />
  <.input field={@changeset[:body]} label="Message" />
  <:actions>
    <.button>Send</.button>
  </:actions>
</.simple_form>
```

Errors display automatically when changeset has `action: :insert` or similar.

---

## Try It

```elixir
iex> alias Chatroom.Chat.Message
iex> import Ecto.Changeset

# Valid changeset
iex> cs = Message.changeset(%Message{}, %{username: "alice", body: "hi"})
iex> cs.valid?
true
iex> cs.changes
%{username: "alice", body: "hi"}

# Invalid changeset
iex> cs = Message.changeset(%Message{}, %{})
iex> cs.valid?
false
iex> cs.errors
[username: {"can't be blank", ...}, body: {"can't be blank", ...}]

# Length validation
iex> cs = Message.changeset(%Message{}, %{username: "a" |> String.duplicate(50), body: "hi"})
iex> cs.valid?
false

# Insert via context
iex> Chatroom.Chat.create_message(%{username: "test", body: "hello"})
{:ok, %Message{id: 1, ...}}
```

---

## Key Takeaways

1. **Changesets track changes** - Data + proposed changes + errors
2. **`cast/3` filters params** - Whitelist permitted fields
3. **Validations are pipeable** - Chain them together
4. **Database constraints check DB** - Unique, foreign key
5. **`valid?` tells you the result** - Check before insert/update
6. **Multiple changesets per schema** - Different rules for different contexts

---

**Next:** [Queries →](./03-queries.md)
