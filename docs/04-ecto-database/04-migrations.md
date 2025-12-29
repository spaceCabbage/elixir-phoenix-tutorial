# Migrations

Migrations are version-controlled database changes. They ensure your database schema evolves consistently.

---

## Creating Migrations

```bash
mix ecto.gen.migration create_messages
```

Creates `priv/repo/migrations/20241229123456_create_messages.exs`.

---

## Basic Migration

```elixir
defmodule Chatroom.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :username, :string
      add :body, :text

      timestamps()
    end
  end
end
```

### The `change` Function

Ecto can automatically reverse `change` functions:

- `create table` → `drop table`
- `add column` → `remove column`
- `create index` → `drop index`

---

## Column Types

```elixir
create table(:examples) do
  # Strings
  add :name, :string                    # VARCHAR(255)
  add :name, :string, size: 100         # VARCHAR(100)
  add :bio, :text                       # TEXT

  # Numbers
  add :age, :integer
  add :price, :decimal, precision: 10, scale: 2
  add :rating, :float

  # Boolean
  add :active, :boolean, default: false

  # Binary
  add :data, :binary

  # Date/Time
  add :born_on, :date
  add :starts_at, :time
  add :published_at, :naive_datetime
  add :created_at, :utc_datetime

  # JSON/Map
  add :settings, :map
  add :metadata, :jsonb               # PostgreSQL only

  # Arrays (PostgreSQL)
  add :tags, {:array, :string}

  # UUID
  add :external_id, :uuid
end
```

---

## Column Options

```elixir
add :email, :string, null: false              # NOT NULL
add :status, :string, default: "pending"      # DEFAULT value
add :role, :string, default: fragment("'user'")  # SQL default
add :user_id, references(:users)              # FOREIGN KEY
add :user_id, references(:users, on_delete: :delete_all)  # CASCADE
```

---

## Primary Keys

```elixir
# Default integer primary key
create table(:users) do
  add :name, :string
end

# UUID primary key
create table(:users, primary_key: false) do
  add :id, :binary_id, primary_key: true
  add :name, :string
end

# No primary key
create table(:settings, primary_key: false) do
  add :key, :string
  add :value, :string
end
```

---

## Indexes

```elixir
def change do
  create table(:users) do
    add :email, :string
    add :username, :string
  end

  # Single column index
  create index(:users, [:email])

  # Unique index
  create unique_index(:users, [:email])

  # Multi-column index
  create index(:users, [:first_name, :last_name])

  # Conditional index (PostgreSQL)
  create index(:users, [:email], where: "active = true")
end
```

---

## Modifying Tables

```elixir
def change do
  alter table(:users) do
    add :phone, :string
    remove :fax
    modify :name, :text  # Change type (may need up/down)
  end
end
```

### When `change` Can't Reverse

Use `up` and `down`:

```elixir
def up do
  alter table(:users) do
    modify :name, :text, from: :string
  end
end

def down do
  alter table(:users) do
    modify :name, :string, from: :text
  end
end
```

---

## This Codebase

```elixir
# priv/repo/migrations/20241229190000_create_messages.exs
defmodule Chatroom.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :username, :string
      add :body, :text

      timestamps()
    end
  end
end
```

Simple migration that creates the messages table with username, body, and timestamps.

---

## Running Migrations

```bash
# Run pending migrations
mix ecto.migrate

# Rollback last migration
mix ecto.rollback

# Rollback multiple
mix ecto.rollback --step 3

# See migration status
mix ecto.migrations

# Reset database (drop, create, migrate)
mix ecto.reset

# Setup (create, migrate, seed)
mix ecto.setup
```

---

## Constraints

```elixir
def change do
  create table(:users) do
    add :email, :string, null: false
    add :age, :integer
  end

  # Check constraint
  create constraint(:users, :age_must_be_positive, check: "age > 0")

  # Unique constraint (same as unique_index)
  create unique_index(:users, [:email])

  # Exclusion constraint (PostgreSQL)
  create constraint(:reservations, :no_overlapping,
    exclude: ~s|gist (room_id WITH =, tsrange(start_at, end_at) WITH &&)|
  )
end
```

---

## References (Foreign Keys)

```elixir
create table(:posts) do
  add :title, :string
  add :user_id, references(:users)
end

# With options
add :user_id, references(:users,
  on_delete: :nothing,       # Do nothing (default)
  # on_delete: :delete_all,  # CASCADE delete
  # on_delete: :nilify_all,  # Set to NULL
  # on_delete: :restrict,    # Prevent delete if referenced
  type: :binary_id           # If users use UUID
)
```

---

## Renaming

```elixir
def change do
  rename table(:posts), :title, to: :name
  rename table(:posts), to: table(:articles)
end
```

---

## Executing SQL

```elixir
def change do
  execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"",
          "DROP EXTENSION \"uuid-ossp\""
end

def up do
  execute "UPDATE users SET role = 'user' WHERE role IS NULL"
end
```

---

## Try It

```bash
# Generate a migration
mix ecto.gen.migration add_email_to_messages

# Edit the migration
# priv/repo/migrations/*_add_email_to_messages.exs

# Run it
mix ecto.migrate

# Check status
mix ecto.migrations

# Rollback if needed
mix ecto.rollback
```

```elixir
# In the migration file
def change do
  alter table(:messages) do
    add :email, :string
  end

  create index(:messages, [:email])
end
```

---

## Key Takeaways

1. **`change` is reversible** - Ecto auto-generates rollback
2. **`up`/`down` for complex cases** - When auto-reverse won't work
3. **Types map to database** - `:string`, `:text`, `:integer`, etc.
4. **Indexes improve queries** - Create for commonly filtered columns
5. **`references` creates foreign keys** - Link tables together
6. **Run with `mix ecto.migrate`** - Apply pending migrations

---

**Next:** [Relationships →](./05-relationships.md)
