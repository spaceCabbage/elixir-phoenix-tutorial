# Exercises

Hands-on challenges to solidify your understanding. Each builds on the previous.

---

## Exercise 1: Display Message Count

**Goal:** Show total message count in the header

**Difficulty:** Beginner

**Concepts:** Assigns, LiveView lifecycle

### Steps

1. In `mount/3`, add a `message_count` assign:

   ```elixir
   |> assign(:message_count, length(Chat.list_messages()))
   ```

2. Update the count in `handle_info/2`:

   ```elixir
   def handle_info({:new_message, message}, socket) do
     {:noreply,
      socket
      |> update(:messages, &(&1 ++ [message]))
      |> update(:message_count, &(&1 + 1))}
   end
   ```

3. Display in the template:
   ```heex
   <span>Messages: <%= @message_count %></span>
   ```

### Bonus

Show "1 message" vs "2 messages" (handle pluralization).

---

## Exercise 2: Add Message Deletion

**Goal:** Allow users to delete their own messages

**Difficulty:** Intermediate

**Concepts:** Events with values, pattern matching, PubSub

### Steps

1. Add delete button in template (only for user's own messages):

   ```heex
   <%= if message.username == @username do %>
     <button phx-click="delete" phx-value-id={message.id}>Delete</button>
   <% end %>
   ```

2. Handle the event in ChatLive:

   ```elixir
   def handle_event("delete", %{"id" => id}, socket) do
     Chat.delete_message(String.to_integer(id))
     {:noreply, socket}
   end
   ```

3. Add `delete_message/1` to Chat context:

   ```elixir
   def delete_message(id) do
     Repo.get!(Message, id)
     |> Repo.delete()
     |> broadcast(:message_deleted)
   end
   ```

4. Handle the broadcast:
   ```elixir
   def handle_info({:message_deleted, message}, socket) do
     {:noreply, update(socket, :messages, fn messages ->
       Enum.reject(messages, &(&1.id == message.id))
     end)}
   end
   ```

### Bonus

Add confirmation before delete.

---

## Exercise 3: Add "User is Typing" Indicator

**Goal:** Show when other users are typing

**Difficulty:** Intermediate

**Concepts:** Process messages, MapSet, timers

### Steps

1. Add `phx-keyup="typing"` to the message input

2. Track typing users in assigns:

   ```elixir
   |> assign(:typing_users, MapSet.new())
   ```

3. Handle typing event:

   ```elixir
   def handle_event("typing", _, socket) do
     Phoenix.PubSub.broadcast(
       Chatroom.PubSub,
       "chat:lobby",
       {:user_typing, socket.assigns.username}
     )
     {:noreply, socket}
   end
   ```

4. Handle typing broadcast:

   ```elixir
   def handle_info({:user_typing, username}, socket) do
     if username != socket.assigns.username do
       Process.send_after(self(), {:clear_typing, username}, 2000)
       {:noreply, update(socket, :typing_users, &MapSet.put(&1, username))}
     else
       {:noreply, socket}
     end
   end

   def handle_info({:clear_typing, username}, socket) do
     {:noreply, update(socket, :typing_users, &MapSet.delete(&1, username))}
   end
   ```

5. Display:
   ```heex
   <%= if MapSet.size(@typing_users) > 0 do %>
     <div class="typing">
       <%= Enum.join(@typing_users, ", ") %> is typing...
     </div>
   <% end %>
   ```

---

## Exercise 4: Add Multiple Chat Rooms

**Goal:** Support multiple chat rooms with URL routing

**Difficulty:** Advanced

**Concepts:** URL parameters, dynamic topics, routing

### Steps

1. Update router:

   ```elixir
   live "/rooms/:room_id", ChatLive
   ```

2. Get room from params in `mount/3`:

   ```elixir
   def mount(%{"room_id" => room_id}, _session, socket) do
     if connected?(socket), do: Chat.subscribe(room_id)

     {:ok,
      socket
      |> assign(:room_id, room_id)
      |> assign(:messages, Chat.list_messages(room_id))}
   end
   ```

3. Update Chat context to take room_id:

   ```elixir
   def subscribe(room_id) do
     Phoenix.PubSub.subscribe(Chatroom.PubSub, "chat:room:#{room_id}")
   end

   def create_message(room_id, attrs) do
     # ... broadcast to "chat:room:#{room_id}"
   end
   ```

4. Add room list and navigation

---

## Exercise 5: Add User Authentication

**Goal:** Real user accounts instead of self-reported usernames

**Difficulty:** Advanced

**Concepts:** Code generation, associations, session handling

### Steps

1. Generate auth scaffold:

   ```bash
   mix phx.gen.auth Accounts User users
   mix ecto.migrate
   ```

2. Add `user_id` to messages schema:

   ```elixir
   belongs_to :user, Chatroom.Accounts.User
   ```

3. Create migration:

   ```bash
   mix ecto.gen.migration add_user_to_messages
   ```

4. Update ChatLive to use current user from session

5. Protect route with `require_authenticated_user` plug

---

## Exercise 6: Add Message Reactions

**Goal:** Allow emoji reactions on messages

**Difficulty:** Advanced

**Concepts:** Associations, aggregations, complex state

### Steps

1. Create Reaction schema:

   ```elixir
   schema "reactions" do
     field :emoji, :string
     field :username, :string
     belongs_to :message, Message
     timestamps()
   end
   ```

2. Create migration

3. Add reaction buttons to messages

4. Create `add_reaction/3` and `remove_reaction/2` in Chat context

5. Broadcast reactions

6. Display reaction counts grouped by emoji

---

## Exercise 7: Add Direct Messages

**Goal:** Private messaging between users

**Difficulty:** Expert

**Concepts:** Many-to-many relationships, complex queries

### Steps

1. Create Conversation schema (between two users)

2. Create DirectMessage schema

3. Add DM routes and LiveView

4. Use user-specific PubSub topics: `"dm:#{user_id}"`

5. Add UI for starting/viewing conversations

---

## Tips for All Exercises

### Debugging

```elixir
# Add IO.inspect anywhere
|> IO.inspect(label: "after filter")

# Use IEx.pry for breakpoints
require IEx
IEx.pry
```

### Testing Your Changes

```bash
mix test
```

### Formatting

```bash
mix format
```

---

## Need Help?

1. Check the relevant documentation section
2. Look at how similar things are done in the existing code
3. Try it in IEx first
4. Ask your AI tutor for hints (not solutions!)
