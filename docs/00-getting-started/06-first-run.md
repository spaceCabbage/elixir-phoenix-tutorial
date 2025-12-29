# First Run: Running This Chat Application

Let's get the chat app running and see it in action.

---

## Step 1: Clone the Repository

```bash
git clone <repository-url>
cd elixir-phoenix-tutorial
```

---

## Step 2: Install Dependencies

```bash
# Fetch Elixir dependencies
mix deps.get

# Install Node.js dependencies (for assets)
cd assets && npm install && cd ..
```

Or use the setup command (does everything):

```bash
mix setup
```

---

## Step 3: Create the Database

This project uses SQLite - no database server needed!

```bash
mix ecto.create
mix ecto.migrate
```

You should see:

```
The database for Chatroom.Repo has been created
== Running migrations...
```

---

## Step 4: Start the Server

```bash
mix phx.server
```

Or with IEx (recommended for learning):

```bash
iex -S mix phx.server
```

You should see:

```
[info] Running ChatroomWeb.Endpoint with Bandit at 127.0.0.1:4000 (http)
[info] Access ChatroomWeb.Endpoint at http://localhost:4000
```

---

## Step 5: Open the App

Visit **http://localhost:4000** in your browser.

You'll see:

1. A "Join" screen asking for your username
2. Enter a name and click "Join"
3. You're in the chat!

---

## Step 6: Test Real-Time Features

Open **two browser tabs** (or use different browsers):

1. Tab 1: Join as "Alice"
2. Tab 2: Join as "Bob"
3. Send messages from each tab
4. Watch them appear instantly in both tabs!

This demonstrates **Phoenix LiveView** and **PubSub** - the core real-time features you'll learn about.

---

## What's Happening?

### When You Load the Page

```
Browser → HTTP Request → Phoenix Endpoint → Router → ChatLive
                                                        ↓
                                               mount() called
                                                        ↓
                                               Initial HTML rendered
                                                        ↓
Browser ← HTML Response ← WebSocket connection established
```

### When You Send a Message

```
Browser → WebSocket → handle_event("send_message")
                            ↓
                     Chat.create_message()
                            ↓
                     Repo.insert() + PubSub.broadcast()
                            ↓
All connected users ← handle_info({:new_message, msg})
                            ↓
                     UI updates automatically
```

---

## Explore in IEx

With the server running (`iex -S mix phx.server`):

```elixir
# See all messages
Chatroom.Chat.list_messages()

# Create a message programmatically
Chatroom.Chat.create_message(%{username: "System", body: "Hello from IEx!"})
# Check your browser - it appeared!

# See the database
Chatroom.Repo.all(Chatroom.Chat.Message)
```

---

## Useful Commands

```bash
# Stop server
Ctrl+C (twice)

# Run tests
mix test

# Format code
mix format

# Check for issues
mix compile --warnings-as-errors

# See all routes
mix phx.routes
```

---

## File Structure Overview

```
lib/
├── chatroom/                 # Business logic
│   ├── application.ex        # Starts the app (supervision tree)
│   ├── repo.ex               # Database connection
│   ├── chat.ex               # Chat context (message operations)
│   └── chat/
│       └── message.ex        # Message schema
│
└── chatroom_web/             # Web layer
    ├── endpoint.ex           # HTTP entry point
    ├── router.ex             # URL → controller/LiveView
    ├── live/
    │   └── chat_live.ex      # The chat UI (LiveView)
    └── components/
        └── core_components.ex # Reusable UI components
```

---

## Common Issues

### Port Already in Use

```bash
# Find what's using port 4000
lsof -i :4000

# Kill it
kill -9 <PID>

# Or use a different port
PORT=4001 mix phx.server
```

### Database Issues

```bash
# Reset the database
mix ecto.drop
mix ecto.create
mix ecto.migrate
```

### Dependencies Out of Date

```bash
mix deps.get
mix deps.compile
```

### Live Reload Not Working

Install file watcher:

```bash
# Linux
sudo apt install inotify-tools

# macOS
brew install fswatch
```

---

## What's Next?

Now that the app is running, you're ready to learn how it all works!

**Recommended order:**

1. [Erlang Primer](../00b-erlang-primer/) - Understand the foundation
2. [Elixir Fundamentals](../01-elixir-fundamentals/) - Learn the language
3. [OTP Fundamentals](../02-otp-fundamentals/) - Understand processes
4. [Phoenix Framework](../03-phoenix-framework/) - Web architecture
5. [Ecto Database](../04-ecto-database/) - Data persistence
6. [LiveView](../05-liveview/) - Real-time UI
7. [This Codebase](../06-this-codebase/) - Guided code tour

---

**Start learning:** [Erlang Primer →](../00b-erlang-primer/)
