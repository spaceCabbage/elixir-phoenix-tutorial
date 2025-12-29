# Relationships

Ecto supports standard database relationships: one-to-many, many-to-many, and one-to-one.

---

## One-to-Many (has_many/belongs_to)

A user has many posts. A post belongs to one user.

### Migration

```elixir
# Create users table
create table(:users) do
  add :name, :string
  timestamps()
end

# Create posts table with foreign key
create table(:posts) do
  add :title, :string
  add :user_id, references(:users, on_delete: :delete_all)
  timestamps()
end

create index(:posts, [:user_id])
```

### Schemas

```elixir
defmodule MyApp.User do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    has_many :posts, MyApp.Post
    timestamps()
  end
end

defmodule MyApp.Post do
  use Ecto.Schema

  schema "posts" do
    field :title, :string
    belongs_to :user, MyApp.User
    timestamps()
  end
end
```

### Usage

```elixir
# Create with association
user = Repo.get!(User, 1)
%Post{title: "Hello", user_id: user.id}
|> Repo.insert!()

# Or build through association
user
|> Ecto.build_assoc(:posts, %{title: "Hello"})
|> Repo.insert!()

# Load association
user = Repo.get!(User, 1) |> Repo.preload(:posts)
user.posts
# [%Post{}, %Post{}, ...]
```

---

## Many-to-Many

A post has many tags. A tag has many posts.

### Migration

```elixir
# Posts table
create table(:posts) do
  add :title, :string
  timestamps()
end

# Tags table
create table(:tags) do
  add :name, :string
  timestamps()
end

# Join table
create table(:posts_tags, primary_key: false) do
  add :post_id, references(:posts, on_delete: :delete_all)
  add :tag_id, references(:tags, on_delete: :delete_all)
end

create index(:posts_tags, [:post_id])
create index(:posts_tags, [:tag_id])
create unique_index(:posts_tags, [:post_id, :tag_id])
```

### Schemas

```elixir
defmodule MyApp.Post do
  use Ecto.Schema

  schema "posts" do
    field :title, :string
    many_to_many :tags, MyApp.Tag, join_through: "posts_tags"
    timestamps()
  end
end

defmodule MyApp.Tag do
  use Ecto.Schema

  schema "tags" do
    field :name, :string
    many_to_many :posts, MyApp.Post, join_through: "posts_tags"
    timestamps()
  end
end
```

### Usage

```elixir
# Associate existing tags with post
post = Repo.get!(Post, 1) |> Repo.preload(:tags)
tag = Repo.get_by!(Tag, name: "elixir")

post
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:tags, [tag | post.tags])
|> Repo.update!()
```

---

## One-to-One (has_one/belongs_to)

A user has one profile.

### Migration

```elixir
create table(:profiles) do
  add :bio, :text
  add :user_id, references(:users, on_delete: :delete_all)
  timestamps()
end

create unique_index(:profiles, [:user_id])
```

### Schemas

```elixir
defmodule MyApp.User do
  schema "users" do
    field :name, :string
    has_one :profile, MyApp.Profile
  end
end

defmodule MyApp.Profile do
  schema "profiles" do
    field :bio, :text
    belongs_to :user, MyApp.User
  end
end
```

---

## Preloading

Associations aren't loaded by default. Use preload:

```elixir
# Preload after query
user = Repo.get!(User, 1)
user = Repo.preload(user, :posts)

# Preload in query (more efficient)
User
|> where([u], u.id == 1)
|> preload(:posts)
|> Repo.one!()

# Nested preload
User
|> preload(posts: :comments)
|> Repo.all()

# Preload with custom query
User
|> preload(posts: ^from(p in Post, order_by: p.inserted_at, limit: 5))
|> Repo.all()
```

---

## N+1 Query Problem

### The Problem

```elixir
# BAD - makes N+1 queries
users = Repo.all(User)
Enum.each(users, fn user ->
  user = Repo.preload(user, :posts)  # Query per user!
  IO.inspect(user.posts)
end)
```

### The Solution

```elixir
# GOOD - makes 2 queries total
users = Repo.all(User) |> Repo.preload(:posts)
Enum.each(users, fn user ->
  IO.inspect(user.posts)  # Already loaded
end)
```

---

## Association Options

```elixir
schema "users" do
  # Custom foreign key
  has_many :posts, Post, foreign_key: :author_id

  # With where clause
  has_many :published_posts, Post, where: [status: "published"]

  # Preload order
  has_many :posts, Post, preload_order: [desc: :inserted_at]
end
```

---

## Changesets with Associations

### `cast_assoc` - For Nested Forms

```elixir
def changeset(user, attrs) do
  user
  |> cast(attrs, [:name])
  |> cast_assoc(:posts, with: &Post.changeset/2)
end

# Creates/updates posts from nested params
User.changeset(user, %{
  name: "Alice",
  posts: [
    %{title: "First Post"},
    %{id: 1, title: "Updated Title"}
  ]
})
```

### `put_assoc` - For Existing Records

```elixir
def changeset(post, attrs, tags) do
  post
  |> cast(attrs, [:title])
  |> put_assoc(:tags, tags)
end

# Replace all tags
tags = Repo.all(from t in Tag, where: t.name in ^["elixir", "phoenix"])
Post.changeset(post, %{title: "New Title"}, tags)
```

---

## Through Associations

Access associations through a join:

```elixir
# User has many posts, posts have many comments
schema "users" do
  has_many :posts, Post
  has_many :comments, through: [:posts, :comments]
end

# Now you can do:
user = Repo.get!(User, 1) |> Repo.preload(:comments)
user.comments  # All comments on all user's posts
```

---

## Deleting with Associations

```elixir
# In migration
add :user_id, references(:users, on_delete: :delete_all)

# Options:
# :nothing - Do nothing (default)
# :delete_all - Delete associated records
# :nilify_all - Set foreign key to NULL
# :restrict - Prevent deletion if associations exist
```

In schema:

```elixir
has_many :posts, Post, on_delete: :delete_all
```

---

## Try It

```elixir
iex> import Ecto.Query
iex> alias Chatroom.Repo

# With associations (if you add them)
iex> user = Repo.get!(User, 1)
iex> user = Repo.preload(user, :posts)
iex> user.posts

# Preload in query
iex> User |> preload(:posts) |> Repo.all()

# Check if loaded
iex> Ecto.assoc_loaded?(user.posts)
```

---

## Key Takeaways

1. **`has_many` / `belongs_to`** - One-to-many relationships
2. **`many_to_many`** - Needs a join table
3. **`has_one`** - One-to-one with foreign key on other table
4. **Preload explicitly** - Associations aren't auto-loaded
5. **Avoid N+1** - Preload before iterating
6. **`cast_assoc` for forms** - Handle nested params
7. **`put_assoc` for existing** - Associate existing records

---

**You've completed Ecto Database!**

**Next section:** [LiveView →](../05-liveview/)
