# Elixir & Phoenix: A Crash Course for Experienced Developers

A real-time chat application that teaches Elixir and Phoenix from the ground up.

> **Target Audience:** Developers familiar with at least one programming language who want to learn Elixir/Phoenix quickly.

> [!TIP]
> Quick Links
>
> - [Elixir Docs](https://hexdocs.pm/elixir/)
> - [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html)
> - [LiveView Docs](https://hexdocs.pm/phoenix_live_view/)
> - [Ecto Docs](https://hexdocs.pm/ecto/)
> - [Elixir School](https://elixirschool.com/)

---

- [Part 1: Elixir Fundamentals](#part-1-elixir-fundamentals)
- [Part 2: Phoenix Framework](#part-2-phoenix-framework)
- [Part 3: This Codebase](#part-3-this-codebase)
- [Part 4: Exercises](#part-4-exercises)
- [Part 5: Running the App](#part-5-running-the-app)
- [Resources](#resources)
- [Next Steps](#next-steps)

## Part 1: Elixir Fundamentals

### 1.1 What is Elixir?

Elixir is a **functional**, **concurrent** language running on the Erlang VM (BEAM). Created by Jose Valim in 2011.

**Why Elixir?**

- **Fault tolerance** - Erlang was built for telecom (99.9999999% uptime)
- **Concurrency** - Handles millions of lightweight processes
- **Hot code swapping** - Update code without stopping the system
- **Functional** - Immutable data, no side effects, easy to reason about

**Mental Model Shift:**

```
OOP:  Objects hold state, methods mutate state
FP:   Functions transform data, data is immutable
```

### 1.2 Basic Types

```elixir
# ===== Primitives =====
42                  # Integer
3.14                # Float
true                # Boolean (actually atoms)
nil                 # Null value (also an atom)

# ===== Atoms =====
# Atoms are constants whose name IS the value (like Ruby symbols)
:ok
:error
:hello_world
true                # Same as :true
nil                 # Same as :nil

# ===== Strings =====
"Hello, World!"     # UTF-8 encoded binary
"Interpolation: #{1 + 1}"  # => "Interpolation: 2"

# ===== Lists =====
# Linked lists - fast prepend, slow random access
[1, 2, 3]
[1 | [2, 3]]        # Prepend: [1, 2, 3]
hd([1, 2, 3])       # Head: 1
tl([1, 2, 3])       # Tail: [2, 3]
[1, 2] ++ [3, 4]    # Concat: [1, 2, 3, 4]
[1, 2, 3] -- [2]    # Subtract: [1, 3]

# ===== Tuples =====
# Fixed-size, contiguous memory - fast access by index
{:ok, "success"}
{:error, "not found"}
elem({1, 2, 3}, 0)  # => 1

# ===== Maps =====
# Key-value store (like objects/dicts/hashes)
%{"key" => "value"}             # String keys
%{name: "Alice", age: 30}      # Atom keys (shorthand)
map = %{name: "Alice"}
map.name                         # => "Alice" (atom keys only)
map[:name]                       # => "Alice" (any key type)
%{map | name: "New"}            # Update: %{name: "New"}

# ===== Keyword Lists =====
# List of {atom, value} tuples - ordered, allows duplicates
[name: "Alice", age: 30]       # Same as [{:name, "Alice"}, {:age, 30}]
```

### 1.3 Pattern Matching (THE Killer Feature)

The `=` operator is the **match operator**, not assignment:

```elixir
# Basic matching
x = 1               # Binds x to 1
1 = x               # Matches! (x equals 1)
2 = x               # ** (MatchError) no match of right hand side value: 1

# Destructuring tuples - USED EVERYWHERE
{:ok, result} = {:ok, 42}
result              # => 42

{:ok, result} = {:error, "oops"}  # ** MatchError
# This is how Elixir handles errors - not exceptions!

# Destructuring lists
[head | tail] = [1, 2, 3, 4]
head                # => 1
tail                # => [2, 3, 4]

[a, b | rest] = [1, 2, 3, 4]
a                   # => 1
b                   # => 2
rest                # => [3, 4]

# Destructuring maps
%{name: name} = %{name: "Alice", age: 30}
name                # => "Alice"

# Pin operator ^ - match against existing value, don't rebind
x = 1
^x = 1              # Matches
^x = 2              # ** MatchError

# Ignore with underscore
{:ok, _} = {:ok, "don't care about this"}
```

### 1.4 Functions

```elixir
# ===== Anonymous Functions =====
add = fn a, b -> a + b end
add.(1, 2)          # => 3 (note the dot!)

# Capture shorthand
add = &(&1 + &2)    # &1 = first arg, &2 = second arg
add.(1, 2)          # => 3

# Capture named function
upcase = &String.upcase/1   # /1 = arity (number of args)
upcase.("hello")    # => "HELLO"

# ===== Named Functions (must be in a module) =====
defmodule Math do
  # Multi-line
  def add(a, b) do
    a + b
  end

  # One-liner
  def subtract(a, b), do: a - b

  # Private function
  defp internal_helper(x), do: x * 2

  # Multiple clauses with pattern matching
  def describe(0), do: "zero"
  def describe(n) when n > 0, do: "positive"
  def describe(n) when n < 0, do: "negative"

  # Default arguments
  def greet(name, greeting \\ "Hello") do
    "#{greeting}, #{name}!"
  end
end

Math.add(1, 2)              # => 3
Math.describe(-5)           # => "negative"
Math.greet("Alice")        # => "Hello, Alice!"
Math.greet("Alice", "Hi")  # => "Hi, Alice!"
```

### 1.5 The Pipe Operator |>

Transforms nested calls into readable pipelines:

```elixir
# Without pipes (read inside-out)
String.split(String.upcase(String.trim("  hello world  ")))

# With pipes (read left-to-right)
"  hello world  "
|> String.trim()
|> String.upcase()
|> String.split()
# => ["HELLO", "WORLD"]

# Real-world example
users
|> Enum.filter(&(&1.active))
|> Enum.map(&(&1.email))
|> Enum.sort()
|> Enum.take(10)
```

The pipe passes the result as the **first argument** to the next function.

### 1.6 Control Flow

```elixir
# ===== if/else =====
if true do
  "yes"
else
  "no"
end

# One-liner
if true, do: "yes", else: "no"

# unless (inverse of if)
unless false, do: "yes"

# ===== case - Pattern matching on values =====
case {:ok, 42} do
  {:ok, result} -> "Success: #{result}"
  {:error, msg} -> "Error: #{msg}"
  _ -> "Unknown"
end

# With guards
case value do
  x when is_integer(x) and x > 0 -> "positive integer"
  x when is_integer(x) -> "non-positive integer"
  _ -> "not an integer"
end

# ===== cond - First truthy condition wins =====
cond do
  2 + 2 == 5 -> "nope"
  1 + 1 == 2 -> "yes!"
  true -> "fallback"
end

# ===== with - Chain pattern matches, bail on failure =====
with {:ok, user} <- fetch_user(id),
     {:ok, posts} <- fetch_posts(user.id),
     {:ok, comments} <- fetch_comments(posts) do
  {:ok, %{user: user, posts: posts, comments: comments}}
else
  {:error, :not_found} -> {:error, "Resource not found"}
  {:error, reason} -> {:error, reason}
end
```

### 1.7 Modules and Structs

```elixir
defmodule User do
  # Struct: typed map with compile-time guarantees
  defstruct [:name, :email, age: 0, active: true]

  # Constructor function
  def new(name, email) do
    %User{name: name, email: email}
  end

  # Functions that operate on the struct
  def adult?(%User{age: age}) when age >= 18, do: true
  def adult?(_), do: false

  def activate(%User{} = user) do
    %{user | active: true}
  end
end

# Usage
user = User.new("Alice", "y@example.com")
user = %{user | age: 30}
User.adult?(user)     # => true
```

### 1.8 Enumerables and Recursion

```elixir
# ===== Enum module - Your bread and butter =====
Enum.map([1, 2, 3], fn x -> x * 2 end)           # => [2, 4, 6]
Enum.map([1, 2, 3], &(&1 * 2))                   # Same, shorthand

Enum.filter([1, 2, 3, 4], fn x -> rem(x, 2) == 0 end)  # => [2, 4]
Enum.reject([1, 2, 3, 4], &(rem(&1, 2) == 0))          # => [1, 3]

Enum.reduce([1, 2, 3], 0, fn x, acc -> x + acc end)    # => 6
Enum.reduce([1, 2, 3], 0, &(&1 + &2))                  # Same

Enum.find([1, 2, 3], &(&1 > 1))     # => 2
Enum.all?([1, 2, 3], &(&1 > 0))     # => true
Enum.any?([1, 2, 3], &(&1 > 2))     # => true

Enum.sort([3, 1, 2])                # => [1, 2, 3]
Enum.sort_by(users, & &1.name)      # Sort by field

Enum.group_by(users, & &1.role)     # Group by field
Enum.frequencies(["a", "b", "a"])   # => %{"a" => 2, "b" => 1}

# ===== Recursion (no loops in Elixir!) =====
defmodule MyList do
  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)

  # Tail-call optimized (accumulator pattern)
  def sum_tco(list), do: do_sum(list, 0)
  defp do_sum([], acc), do: acc
  defp do_sum([head | tail], acc), do: do_sum(tail, acc + head)
end

MyList.sum([1, 2, 3, 4, 5])  # => 15
```

### 1.9 Processes (Concurrency Model)

Elixir processes are NOT OS threads. They're extremely lightweight (~2KB each).

```elixir
# Spawn a process
pid = spawn(fn ->
  IO.puts("Hello from process #{inspect(self())}")
end)

# Send/receive messages
pid = spawn(fn ->
  receive do
    {:greet, name} -> IO.puts("Hello, #{name}!")
    {:add, a, b} -> IO.puts("#{a} + #{b} = #{a + b}")
  after
    5000 -> IO.puts("Timeout!")
  end
end)

send(pid, {:greet, "World"})  # Prints "Hello, World!"

# Link processes (crash together)
spawn_link(fn -> raise "oops" end)  # Will crash the parent too

# Monitor processes (get notified of crashes)
{pid, ref} = spawn_monitor(fn -> raise "oops" end)
receive do
  {:DOWN, ^ref, :process, ^pid, reason} -> IO.puts("Process died: #{inspect(reason)}")
end
```

---

## Part 2: Phoenix Framework

### 2.1 What is Phoenix?

Phoenix is a web framework for Elixir, similar to Rails/Django/Laravel but with:

- **Real-time by default** - WebSockets built in
- **Functional** - No ORM magic, explicit data flow
- **Fault-tolerant** - Inherits Erlang's reliability
- **Fast** - Microsecond response times

### 2.2 Request Lifecycle

```
+--------------------------------------------------------------+
|                         Browser                               |
+--------------------------------------------------------------+
                              |
                              v
+--------------------------------------------------------------+
|  Endpoint (endpoint.ex)                                       |
|  - Cowboy/Bandit HTTP server                                  |
|  - Plug middleware pipeline                                   |
|  - WebSocket handling                                         |
+--------------------------------------------------------------+
                              |
                              v
+--------------------------------------------------------------+
|  Router (router.ex)                                           |
|  - Pattern matches URL -> handler                             |
|  - Applies pipeline (session, CSRF, etc.)                     |
+--------------------------------------------------------------+
                              |
           +------------------+------------------+
           v                                      v
+-------------------------+         +-------------------------+
|  Controller             |         |  LiveView               |
|  - Request/Response     |         |  - WebSocket            |
|  - Stateless            |         |  - Stateful             |
|  - Renders once         |         |  - Real-time updates    |
+-------------------------+         +-------------------------+
           |                                      |
           +------------------+-------------------+
                              v
+--------------------------------------------------------------+
|  Context (chat.ex, accounts.ex, etc.)                         |
|  - Business logic                                             |
|  - Data access                                                |
|  - External services                                          |
+--------------------------------------------------------------+
                              |
                              v
+--------------------------------------------------------------+
|  Schema + Repo (message.ex, user.ex)                          |
|  - Database mapping                                           |
|  - Validations                                                |
|  - Queries                                                    |
+--------------------------------------------------------------+
                              |
                              v
+--------------------------------------------------------------+
|  Database (SQLite/PostgreSQL)                                 |
+--------------------------------------------------------------+
```

### 2.3 Plugs (Middleware)

Everything in Phoenix is a Plug. A plug transforms a connection:

```elixir
# Function plug
def my_plug(conn, _opts) do
  conn
  |> assign(:current_time, DateTime.utc_now())
end

# Module plug
defmodule MyApp.AuthPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil -> conn |> redirect(to: "/login") |> halt()
      user_id -> assign(conn, :current_user, Accounts.get_user!(user_id))
    end
  end
end
```

### 2.4 LiveView (Real-Time UI)

LiveView is server-rendered reactive UI over WebSockets:

```elixir
defmodule MyAppWeb.CounterLive do
  use MyAppWeb, :live_view

  # Called once when user connects
  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  # Handle events from the browser
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  # Handle messages from other processes
  def handle_info({:count_updated, new_count}, socket) do
    {:noreply, assign(socket, count: new_count)}
  end

  # Render HTML - called whenever assigns change
  def render(assigns) do
    ~H"""
    <div class="counter">
      <h1>Count: <%= @count %></h1>
      <button phx-click="decrement">-</button>
      <button phx-click="increment">+</button>
    </div>
    """
  end
end
```

**How it works:**

1. Server renders initial HTML (SEO-friendly, fast first paint)
2. Browser loads JS, connects WebSocket to server
3. User clicks button -> `phx-click` sends event to server
4. Server updates state -> computes HTML diff -> sends minimal patch
5. Browser patches DOM (no full page reload)

### 2.5 Contexts (Business Logic)

Contexts group related functionality. They're the API for your domain:

```elixir
defmodule MyApp.Accounts do
  alias MyApp.Repo
  alias MyApp.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
```

**Why contexts?**

- Separation of concerns (web != business logic)
- Easier testing
- Clear boundaries
- Reusable across web, API, CLI, etc.

### 2.6 Ecto (Database)

Ecto is NOT an ORM. It's a toolkit for data mapping and querying.

```elixir
# ===== Schema - Maps to database table =====
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :age, :integer
    field :password_hash, :string

    has_many :posts, MyApp.Blog.Post
    belongs_to :organization, MyApp.Accounts.Organization

    timestamps()  # inserted_at, updated_at
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :age])
    |> validate_required([:email, :name])
    |> validate_format(:email, ~r/@/)
    |> validate_number(:age, greater_than: 0)
    |> unique_constraint(:email)
  end
end

# ===== Queries =====
import Ecto.Query

# Simple
Repo.all(User)
Repo.get(User, 1)
Repo.get_by(User, email: "y@example.com")

# Composable queries
User
|> where([u], u.age > 18)
|> where([u], u.active == true)
|> order_by([u], desc: u.inserted_at)
|> limit(10)
|> Repo.all()

# Preload associations
User
|> preload(:posts)
|> Repo.get(1)

# ===== Changesets - Track and validate changes =====
changeset = User.changeset(%User{}, %{email: "invalid"})
changeset.valid?     # => false
changeset.errors     # => [email: {"has invalid format", [validation: :format]}]
```

### 2.7 PubSub (Real-Time Broadcasting)

Phoenix PubSub enables real-time features:

```elixir
# Subscribe to a topic
Phoenix.PubSub.subscribe(MyApp.PubSub, "room:lobby")

# Broadcast to all subscribers
Phoenix.PubSub.broadcast(MyApp.PubSub, "room:lobby", {:new_message, message})

# In LiveView - handle broadcasts
def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, &(&1 ++ [message]))}
end
```

---

## Part 3: This Codebase

### 3.1 File Structure

```
lib/
+-- chatroom/                      # Business logic (Context)
|   +-- application.ex             # OTP supervisor - starts all processes
|   +-- repo.ex                    # Database connection
|   +-- chat.ex                    # Chat context - CRUD + broadcast
|   +-- chat/
|       +-- message.ex             # Message schema
|
+-- chatroom_web/                  # Web layer
|   +-- endpoint.ex                # HTTP entry point
|   +-- router.ex                  # URL routing
|   +-- components/
|   |   +-- core_components.ex     # Reusable UI components
|   |   +-- layouts.ex             # Page layouts
|   +-- live/
|       +-- chat_live.ex           # Real-time chat UI
|
+-- chatroom.ex                    # Main module
+-- chatroom_web.ex                # Web helpers

priv/
+-- repo/migrations/               # Database migrations
+-- static/                        # Static assets (generated)

config/
+-- config.exs                     # Base config
+-- dev.exs                        # Development config
+-- test.exs                       # Test config
+-- runtime.exs                    # Runtime config (env vars)
```

### 3.2 Data Flow

```
User types message and hits Enter
            |
            v
+-------------------------------------------------------------+
|  Browser: phx-submit="send_message"                         |
|  Sends event over WebSocket                                 |
+-------------------------------------------------------------+
            |
            v
+-------------------------------------------------------------+
|  ChatLive.handle_event("send_message", ...)                 |
|  Calls Chat.create_message()                                |
+-------------------------------------------------------------+
            |
            v
+-------------------------------------------------------------+
|  Chat.create_message()                                      |
|  1. Creates changeset                                       |
|  2. Inserts into database                                   |
|  3. Broadcasts {:new_message, message} via PubSub           |
+-------------------------------------------------------------+
            |
            v
+-------------------------------------------------------------+
|  All subscribed ChatLive processes receive broadcast        |
|  ChatLive.handle_info({:new_message, message}, ...)         |
|  Updates assigns -> triggers render()                       |
+-------------------------------------------------------------+
            |
            v
+-------------------------------------------------------------+
|  Phoenix diffs new HTML vs old HTML                         |
|  Sends minimal patch to browser                             |
|  Browser updates DOM                                        |
+-------------------------------------------------------------+
```

### 3.3 Key Files Explained

#### `lib/chatroom/application.ex`

```elixir
def start(_type, _args) do
  children = [
    ChatroomWeb.Telemetry,                          # Metrics
    Chatroom.Repo,                                  # Database pool
    {Phoenix.PubSub, name: Chatroom.PubSub},       # Pub/Sub system
    ChatroomWeb.Endpoint                            # HTTP server
  ]

  Supervisor.start_link(children, strategy: :one_for_one)
end
```

This is an **OTP Supervisor**. If any child crashes, it restarts automatically.

#### `lib/chatroom/chat/message.ex`

```elixir
schema "messages" do
  field :username, :string
  field :body, :string
  timestamps()
end

def changeset(message, attrs) do
  message
  |> cast(attrs, [:username, :body])
  |> validate_required([:username, :body])
  |> validate_length(:body, max: 500)
end
```

Defines the Message struct and validation rules.

#### `lib/chatroom/chat.ex`

```elixir
def create_message(attrs) do
  %Message{}
  |> Message.changeset(attrs)
  |> Repo.insert()
  |> broadcast(:new_message)
end

defp broadcast({:ok, message}, event) do
  Phoenix.PubSub.broadcast(Chatroom.PubSub, "chat:lobby", {event, message})
  {:ok, message}
end
```

Creates message AND broadcasts to all subscribers in one operation.

#### `lib/chatroom_web/live/chat_live.ex`

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Chat.subscribe()
  {:ok, assign(socket, messages: Chat.list_messages(), ...)}
end

def handle_event("send_message", %{"body" => body}, socket) do
  Chat.create_message(%{username: socket.assigns.username, body: body})
  {:noreply, socket}
end

def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, &(&1 ++ [message]))}
end
```

- `mount/3` - Initial setup, subscribe to broadcasts
- `handle_event/3` - Handle user interactions
- `handle_info/2` - Handle PubSub broadcasts

---

## Part 4: Exercises

Complete these exercises to solidify your understanding. Each builds on the previous.

### Exercise 1: Display Message Count

**Goal:** Show total message count in the header

**Steps:**

1. Add `message_count` to socket assigns in `mount/3`
2. Update count when new message arrives in `handle_info/2`
3. Display in template: `<span>Messages: <%= @message_count %></span>`

**Concepts practiced:** Assigns, LiveView lifecycle

---

### Exercise 2: Add Message Deletion

**Goal:** Allow users to delete their own messages

**Steps:**

1. Add delete button in template (only show for user's own messages):
   ```heex
   <%= if message.username == @username do %>
     <button phx-click="delete" phx-value-id={message.id}>Delete</button>
   <% end %>
   ```
2. Add `handle_event("delete", %{"id" => id}, socket)` in ChatLive
3. Add `delete_message/1` in Chat context
4. Broadcast `{:message_deleted, id}` event
5. Handle in `handle_info/2` to remove from list

**Concepts practiced:** Events with values, pattern matching, list operations

---

### Exercise 3: Add "User is typing" Indicator

**Goal:** Show when other users are typing

**Steps:**

1. Add `phx-keyup="typing"` to the message input
2. Track typing users in assigns: `typing_users: MapSet.new()`
3. Broadcast `{:user_typing, username}` on keyup
4. In `handle_info`, add user to typing set
5. Use `Process.send_after(self(), {:clear_typing, username}, 2000)` to clear
6. Display: `<%= for user <- @typing_users do %><%= user %> is typing...<% end %>`

**Concepts practiced:** Process messages, MapSet, timers

---

### Exercise 4: Add Multiple Chat Rooms

**Goal:** Support multiple chat rooms with URL routing

**Steps:**

1. Update router: `live "/rooms/:room_id", ChatLive`
2. In `mount/3`, get room_id from params: `socket.assigns.room_id = params["room_id"]`
3. Use room-specific PubSub topic: `"chat:room:#{room_id}"`
4. Add `list_rooms/0` and room selection UI
5. Create Room schema and migration (optional)

**Concepts practiced:** URL parameters, dynamic topics, routing

---

### Exercise 5: Add User Authentication

**Goal:** Real user accounts instead of self-reported usernames

**Steps:**

1. Generate auth scaffold:
   ```bash
   mix phx.gen.auth Accounts User users
   mix ecto.migrate
   ```
2. Update Message schema to reference User
3. In ChatLive, get current user from session
4. Protect route with authentication plug

**Concepts practiced:** Code generation, associations, session handling

---

### Exercise 6: Add Message Reactions

**Goal:** Allow emoji reactions on messages

**Steps:**

1. Create Reaction schema: `message_id`, `user`, `emoji`
2. Create migration
3. Add reaction buttons to messages
4. Create `add_reaction/3` and `remove_reaction/3` in Chat context
5. Broadcast reactions
6. Display reaction counts per message

**Concepts practiced:** Associations, aggregations, complex state

---

### Exercise 7: Add Direct Messages

**Goal:** Private messaging between users

**Steps:**

1. Create Conversation schema (between two users)
2. Create DirectMessage schema
3. Add DM routes and LiveView
4. Use user-specific PubSub topics: `"dm:#{user_id}"`
5. Add UI for starting/viewing conversations

**Concepts practiced:** Many-to-many relationships, complex queries

---

## Part 5: Running the App

```bash
# Install dependencies
mix deps.get

# Setup database
mix ecto.create
mix ecto.migrate

# Start server
mix phx.server

# Start with interactive shell (recommended for learning)
iex -S mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000)

### Useful Commands

```bash
mix phx.routes                    # List all routes
mix ecto.gen.migration add_field  # Create migration
mix ecto.migrate                  # Run migrations
mix ecto.rollback                 # Undo last migration
mix test                          # Run tests
mix format                        # Format code
mix deps.get                      # Install dependencies
mix hex.info package_name         # Package info
```

### IEx (Interactive Shell) Tips

```elixir
# In iex -S mix phx.server

# Query database
Chatroom.Repo.all(Chatroom.Chat.Message)

# Create a message
Chatroom.Chat.create_message(%{username: "test", body: "Hello!"})

# Reload module after editing
r Chatroom.Chat

# Get help
h Enum.map

# Inspect a value
i %{foo: "bar"}
```

---

## Resources

### Learning

- [Elixir School](https://elixirschool.com/) - Free, comprehensive tutorials
- [Exercism Elixir Track](https://exercism.org/tracks/elixir) - Practice problems

### Documentation

- [Elixir Docs](https://hexdocs.pm/elixir/)
- [Phoenix Docs](https://hexdocs.pm/phoenix/)
- [LiveView Docs](https://hexdocs.pm/phoenix_live_view/)
- [Ecto Docs](https://hexdocs.pm/ecto/)

### Books

- "Programming Phoenix LiveView" - Bruce Tate & Sophie DeBenedetto
- "Elixir in Action" - Sasa Juric
- "Programming Elixir" - Dave Thomas

### Community

- [Elixir Forum](https://elixirforum.com/)
- [Elixir Discord](https://discord.gg/elixir)
- [r/elixir](https://reddit.com/r/elixir)

---

## Next Steps

After completing the exercises, try:

1. **Deploy to Fly.io** - Phoenix has first-class Fly.io support
2. **Add Presence** - Show who's online using Phoenix.Presence
3. **Add Tests** - Write ExUnit tests for your contexts
4. **Try Ash Framework** - A declarative framework built on Phoenix
5. **Build an API** - Add JSON API endpoints alongside LiveView
