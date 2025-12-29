# Schemas

Schemas map database tables to Elixir structs. They define what fields exist and their types.

---

## Basic Schema

```elixir
defmodule Chatroom.Chat.Message do
  use Ecto.Schema

  schema "messages" do
    field :username, :string
    field :body, :string
    timestamps()
  end
end
```

This creates a struct:

```elixir
%Chatroom.Chat.Message{
  id: nil,
  username: nil,
  body: nil,
  inserted_at: nil,
  updated_at: nil
}
```

---

## Field Types

| Type                | Elixir Type   | Database |
| ------------------- | ------------- | -------- |
| `:id`               | integer       | BIGINT   |
| `:binary_id`        | binary        | UUID     |
| `:integer`          | integer       | INT      |
| `:float`            | float         | FLOAT    |
| `:decimal`          | Decimal       | DECIMAL  |
| `:boolean`          | boolean       | BOOLEAN  |
| `:string`           | string        | VARCHAR  |
| `:binary`           | binary        | BLOB     |
| `:map`              | map           | JSON     |
| `{:array, :string}` | list          | ARRAY    |
| `:date`             | Date          | DATE     |
| `:time`             | Time          | TIME     |
| `:naive_datetime`   | NaiveDateTime | DATETIME |
| `:utc_datetime`     | DateTime      | DATETIME |

### Examples

```elixir
schema "users" do
  field :name, :string
  field :age, :integer
  field :balance, :decimal
  field :is_active, :boolean, default: true
  field :settings, :map
  field :tags, {:array, :string}
  field :born_at, :date
  field :last_login, :utc_datetime
  timestamps()  # inserted_at, updated_at
end
```

---

## Default Values

```elixir
schema "posts" do
  field :title, :string
  field :status, :string, default: "draft"
  field :view_count, :integer, default: 0
  field :published_at, :utc_datetime
end
```

Defaults are set when creating a struct:

```elixir
%Post{}
# %Post{status: "draft", view_count: 0, ...}
```

---

## Virtual Fields

Fields that exist in the struct but not in the database:

```elixir
schema "users" do
  field :email, :string
  field :password_hash, :string
  field :password, :string, virtual: true  # Not saved
  field :password_confirmation, :string, virtual: true
end
```

Use for:

- Form inputs that shouldn't be stored
- Computed values
- Temporary data

---

## Primary Keys

### Default (auto-increment integer)

```elixir
schema "users" do
  # id field is implicit
  field :name, :string
end
```

### UUID Primary Key

```elixir
@primary_key {:id, :binary_id, autogenerate: true}
schema "users" do
  field :name, :string
end
```

### Custom Primary Key

```elixir
@primary_key {:code, :string, []}
schema "products" do
  field :name, :string
end
# Must set :code manually
```

### No Primary Key

```elixir
@primary_key false
schema "settings" do
  field :key, :string
  field :value, :string
end
```

---

## This Codebase

```elixir
# lib/chatroom/chat/message.ex
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
    |> cast(attrs, [:username, :body])
    |> validate_required([:username, :body])
    |> validate_length(:username, min: 1, max: 20)
    |> validate_length(:body, min: 1, max: 500)
  end
end
```

---

## Schema Module Pattern

```elixir
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # Schema definition
  schema "users" do
    field :email, :string
    field :name, :string
    timestamps()
  end

  # Changeset for creation
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> unique_constraint(:email)
  end

  # Specialized changeset
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_length(:password, min: 8)
    |> hash_password()
  end

  defp hash_password(changeset) do
    # ... password hashing logic
  end
end
```

---

## Embedded Schemas

For JSON columns or nested data:

```elixir
defmodule MyApp.Address do
  use Ecto.Schema

  embedded_schema do
    field :street, :string
    field :city, :string
    field :zip, :string
  end
end

defmodule MyApp.User do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    embeds_one :address, MyApp.Address  # Stored as JSON
    embeds_many :addresses, MyApp.Address
  end
end
```

---

## Try It

```elixir
iex> alias Chatroom.Chat.Message

# Create a struct
iex> %Message{}
%Message{id: nil, username: nil, body: nil, ...}

# Structs are maps
iex> msg = %Message{username: "test", body: "hello"}
iex> msg.username
"test"

# Pattern match
iex> %Message{username: name} = msg
iex> name
"test"

# Access all fields
iex> Message.__schema__(:fields)
[:id, :username, :body, :inserted_at, :updated_at]

# Access field type
iex> Message.__schema__(:type, :username)
:string
```

---

## Key Takeaways

1. **Schemas map tables to structs** - `schema "table_name" do`
2. **Fields have types** - `:string`, `:integer`, `:boolean`, etc.
3. **`timestamps()` adds two fields** - `inserted_at`, `updated_at`
4. **Virtual fields aren't persisted** - For forms and computed values
5. **Primary keys are configurable** - Integer, UUID, or custom
6. **Embedded schemas** - For JSON columns

---

**Next:** [Changesets →](./02-changesets.md)
