# Ecto Database

Ecto is Elixir's database toolkit. It's not an ORM - it's a set of tools for working with data and databases.

---

## What You'll Learn

| File                                       | Topic                 | Key Concepts                     |
| ------------------------------------------ | --------------------- | -------------------------------- |
| [01. Schemas](./01-schemas.md)             | Data mapping          | Fields, types, virtual fields    |
| [02. Changesets](./02-changesets.md)       | Validation & tracking | Cast, validate, constraints      |
| [03. Queries](./03-queries.md)             | Fetching data         | Composable queries, preloading   |
| [04. Migrations](./04-migrations.md)       | Schema evolution      | Creating/modifying tables        |
| [05. Relationships](./05-relationships.md) | Associations          | has_many, belongs_to, preloading |

---

## Key Components

### Schema

Maps database tables to Elixir structs:

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

### Changeset

Tracks and validates changes:

```elixir
def changeset(message, attrs) do
  message
  |> cast(attrs, [:username, :body])
  |> validate_required([:username, :body])
  |> validate_length(:body, min: 1, max: 500)
end
```

### Query

Composable database queries:

```elixir
Message
|> where([m], m.username == "alice")
|> order_by(desc: :inserted_at)
|> limit(10)
|> Repo.all()
```

### Migration

Database schema changes:

```elixir
def change do
  create table(:messages) do
    add :username, :string
    add :body, :text
    timestamps()
  end
end
```

### Repo

The database connection:

```elixir
Repo.all(Message)
Repo.get!(Message, 1)
Repo.insert(%Message{})
Repo.update(changeset)
Repo.delete(message)
```

---

## In This Codebase

```
lib/chatroom/
├── repo.ex                 # Database connection
├── chat.ex                 # Context using Ecto
└── chat/
    └── message.ex          # Schema + changeset

priv/repo/
└── migrations/
    └── *_create_messages.exs  # Migration
```

---

## Why Ecto (Not an ORM)

| Traditional ORM         | Ecto                 |
| ----------------------- | -------------------- |
| Magic methods           | Explicit queries     |
| Hidden SQL              | See what's happening |
| Implicit loading        | Explicit preloading  |
| Object-database mapping | Data transformation  |
| Hard to optimize        | Easy to optimize     |

Ecto makes you think about data flow, which leads to better performance.

---

## Prerequisites

Before starting:

1. Complete [Phoenix Framework](../03-phoenix-framework/)
2. Have the chat app running
3. Understand [Elixir basics](../01-elixir-fundamentals/)

---

## Time Estimate

- **Quick pass**: 1-2 hours
- **Thorough study**: 2-3 hours
- **Building features**: Practice time

---

## Key Files to Reference

| File                                                               | Purpose        |
| ------------------------------------------------------------------ | -------------- |
| [lib/chatroom/repo.ex](../../lib/chatroom/repo.ex)                 | Repo module    |
| [lib/chatroom/chat/message.ex](../../lib/chatroom/chat/message.ex) | Schema example |
| [lib/chatroom/chat.ex](../../lib/chatroom/chat.ex)                 | Query examples |

---

**Start:** [Schemas →](./01-schemas.md)
