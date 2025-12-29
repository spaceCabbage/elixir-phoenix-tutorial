# Queries

Ecto queries are composable - build them up piece by piece, then execute.

---

## Repo Functions

The Repo executes queries:

```elixir
# Get all
Repo.all(Message)

# Get by ID
Repo.get(Message, 1)        # Returns nil if not found
Repo.get!(Message, 1)       # Raises if not found

# Get by attributes
Repo.get_by(Message, username: "alice")
Repo.get_by!(Message, username: "alice")

# Insert
Repo.insert(%Message{username: "alice", body: "hi"})
Repo.insert!(changeset)

# Update
Repo.update(changeset)
Repo.update!(changeset)

# Delete
Repo.delete(message)
Repo.delete!(message)

# Count
Repo.aggregate(Message, :count)
```

---

## Query Syntax

Two syntaxes - keyword and macro:

### Keyword Syntax

```elixir
import Ecto.Query

# Simple query
from m in Message,
  where: m.username == "alice",
  select: m

# With ordering and limit
from m in Message,
  where: m.username == "alice",
  order_by: [desc: m.inserted_at],
  limit: 10
```

### Macro Syntax (Pipeable)

```elixir
import Ecto.Query

Message
|> where([m], m.username == "alice")
|> order_by([m], desc: m.inserted_at)
|> limit(10)
|> Repo.all()
```

Both produce the same SQL. Macro syntax is better for building queries dynamically.

---

## Where Clauses

```elixir
# Equality
where(query, [m], m.username == "alice")

# Not equal
where(query, [m], m.username != "alice")

# Comparison
where(query, [m], m.age > 18)
where(query, [m], m.age >= 18)

# NULL checks
where(query, [m], is_nil(m.deleted_at))
where(query, [m], not is_nil(m.published_at))

# IN clause
where(query, [m], m.status in ["published", "featured"])

# LIKE (use ilike for case-insensitive)
where(query, [m], like(m.username, "alice%"))
where(query, [m], ilike(m.username, "%alice%"))

# Multiple conditions (AND)
where(query, [m], m.status == "published" and m.age > 18)

# OR conditions
where(query, [m], m.status == "published" or m.featured == true)

# Between
where(query, [m], m.age >= 18 and m.age <= 65)

# Fragment for raw SQL
where(query, [m], fragment("? @> ?", m.tags, ^["elixir"]))
```

---

## Dynamic Queries

Build queries conditionally:

```elixir
def list_messages(params \\ %{}) do
  Message
  |> apply_username_filter(params)
  |> apply_date_filter(params)
  |> order_by(desc: :inserted_at)
  |> Repo.all()
end

defp apply_username_filter(query, %{username: username}) when username != "" do
  where(query, [m], m.username == ^username)
end
defp apply_username_filter(query, _), do: query

defp apply_date_filter(query, %{since: date}) do
  where(query, [m], m.inserted_at >= ^date)
end
defp apply_date_filter(query, _), do: query
```

---

## Select

```elixir
# Select specific fields
from m in Message,
  select: m.body

# Select multiple fields as map
from m in Message,
  select: %{username: m.username, body: m.body}

# Select with transformation
from m in Message,
  select: {m.username, m.body}

# Count
from m in Message,
  select: count(m.id)

# Aggregate
from m in Message,
  select: sum(m.amount)
```

---

## Order, Limit, Offset

```elixir
Message
|> order_by(asc: :inserted_at)          # Oldest first
|> order_by(desc: :inserted_at)         # Newest first
|> order_by([m], [desc: m.inserted_at, asc: m.id])  # Multiple
|> limit(10)
|> offset(20)
|> Repo.all()
```

---

## Group and Aggregate

```elixir
# Count per username
from m in Message,
  group_by: m.username,
  select: {m.username, count(m.id)}

# Sum
from o in Order,
  group_by: o.user_id,
  select: {o.user_id, sum(o.total)}

# Having
from m in Message,
  group_by: m.username,
  having: count(m.id) > 5,
  select: {m.username, count(m.id)}
```

---

## Joins

```elixir
# Inner join
from m in Message,
  join: u in User, on: m.user_id == u.id,
  select: {m.body, u.name}

# Left join
from m in Message,
  left_join: u in User, on: m.user_id == u.id,
  select: {m.body, u.name}

# With associations (better)
from m in Message,
  join: u in assoc(m, :user),
  select: {m.body, u.name}
```

---

## Preloading Associations

```elixir
# Separate queries
Message
|> Repo.all()
|> Repo.preload(:user)

# Join preload (one query)
Message
|> preload([m], [:user])
|> Repo.all()

# In query
from m in Message,
  preload: [:user]

# Nested preload
from p in Post,
  preload: [comments: :user]
```

---

## This Codebase

```elixir
# lib/chatroom/chat.ex
def list_messages do
  Message
  |> order_by(asc: :inserted_at)
  |> limit(50)
  |> Repo.all()
end
```

Simple but effective - gets the last 50 messages ordered chronologically.

---

## Update/Delete Many

```elixir
# Update all
from(m in Message, where: m.status == "draft")
|> Repo.update_all(set: [status: "published"])

# Delete all
from(m in Message, where: m.inserted_at < ^one_year_ago)
|> Repo.delete_all()
```

---

## Subqueries

```elixir
# Subquery in where
recent_ids =
  from m in Message,
    order_by: [desc: m.inserted_at],
    limit: 10,
    select: m.id

from m in Message,
  where: m.id in subquery(recent_ids)
```

---

## Try It

```elixir
iex> import Ecto.Query
iex> alias Chatroom.{Repo, Chat.Message}

# Get all messages
iex> Repo.all(Message)

# Get with conditions
iex> Message |> where([m], m.username == "alice") |> Repo.all()

# Count
iex> Repo.aggregate(Message, :count)

# Complex query
iex> Message
...> |> where([m], m.username != "system")
...> |> order_by(desc: :inserted_at)
...> |> limit(5)
...> |> Repo.all()

# See the SQL
iex> Message |> where([m], m.username == "alice") |> Ecto.Query.to_string()
```

---

## Key Takeaways

1. **Queries are composable** - Build up with `|>`
2. **Two syntaxes** - Keyword (`from`) and macro (pipeable)
3. **`^` pins variables** - `where([m], m.id == ^id)`
4. **Preload associations** - Avoid N+1 queries
5. **Dynamic queries** - Build conditionally
6. **Repo executes** - `Repo.all`, `Repo.one`, etc.

---

**Next:** [Migrations →](./04-migrations.md)
