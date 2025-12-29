# Forms

LiveView forms provide instant validation and a smooth user experience.

---

## Basic Form

```elixir
def mount(_params, _session, socket) do
  {:ok, assign(socket, form: to_form(%{"name" => "", "email" => ""}))}
end

def handle_event("save", %{"name" => name, "email" => email}, socket) do
  # Handle form submission
  {:noreply, socket}
end

def render(assigns) do
  ~H"""
  <form phx-submit="save">
    <input name="name" value={@form[:name].value} />
    <input name="email" type="email" value={@form[:email].value} />
    <button>Submit</button>
  </form>
  """
end
```

---

## With Changesets (Recommended)

```elixir
def mount(_params, _session, socket) do
  changeset = Accounts.change_user(%User{})
  {:ok, assign(socket, form: to_form(changeset))}
end

def handle_event("validate", %{"user" => params}, socket) do
  changeset =
    %User{}
    |> Accounts.change_user(params)
    |> Map.put(:action, :validate)

  {:noreply, assign(socket, form: to_form(changeset))}
end

def handle_event("save", %{"user" => params}, socket) do
  case Accounts.create_user(params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, "User created!")
       |> push_navigate(to: ~p"/users/#{user}")}

    {:error, changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

---

## Using Core Components

```heex
<.simple_form for={@form} phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} label="Name" />
  <.input field={@form[:email]} type="email" label="Email" />
  <.input field={@form[:bio]} type="textarea" label="Bio" />
  <.input field={@form[:role]} type="select" label="Role" options={["user", "admin"]} />
  <.input field={@form[:active]} type="checkbox" label="Active" />

  <:actions>
    <.button>Save</.button>
  </:actions>
</.simple_form>
```

---

## Live Validation

Add `phx-change` for instant validation:

```heex
<.simple_form for={@form} phx-change="validate" phx-submit="save">
  <%# Errors show instantly as user types %>
</.simple_form>
```

```elixir
def handle_event("validate", %{"user" => params}, socket) do
  changeset =
    %User{}
    |> User.changeset(params)
    |> Map.put(:action, :validate)  # Shows errors in form

  {:noreply, assign(socket, form: to_form(changeset))}
end
```

### Debounce Validation

```heex
<%# Wait 300ms after typing stops %>
<.input field={@form[:email]} phx-debounce="300" />

<%# Only validate on blur %>
<.input field={@form[:name]} phx-debounce="blur" />
```

---

## Error Display

The `<.input>` component shows errors automatically:

```elixir
# core_components.ex (simplified)
def input(assigns) do
  ~H"""
  <div>
    <label><%= @label %></label>
    <input type={@type} name={@field.name} value={@field.value} />
    <p :for={error <- @field.errors} class="error">
      <%= error %>
    </p>
  </div>
  """
end
```

---

## Edit Forms

```elixir
def mount(%{"id" => id}, _session, socket) do
  user = Accounts.get_user!(id)
  changeset = Accounts.change_user(user)

  {:ok, assign(socket, user: user, form: to_form(changeset))}
end

def handle_event("save", %{"user" => params}, socket) do
  case Accounts.update_user(socket.assigns.user, params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, "Updated!")
       |> push_navigate(to: ~p"/users/#{user}")}

    {:error, changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

---

## Form Recovery

LiveView can recover form data if connection drops:

```heex
<.simple_form for={@form} phx-submit="save" phx-change="validate">
  <%# Form data persists across reconnections %>
</.simple_form>
```

---

## File Uploads

```elixir
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> assign(:uploaded_files, [])
   |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
end

def handle_event("validate", _params, socket) do
  {:noreply, socket}
end

def handle_event("save", _params, socket) do
  uploaded_files =
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
      dest = Path.join("priv/static/uploads", entry.client_name)
      File.cp!(path, dest)
      {:ok, "/uploads/#{entry.client_name}"}
    end)

  {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
end

def render(assigns) do
  ~H"""
  <form phx-submit="save" phx-change="validate">
    <.live_file_input upload={@uploads.avatar} />

    <%= for entry <- @uploads.avatar.entries do %>
      <div>
        <.live_img_preview entry={entry} />
        <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>
        <button phx-click="cancel-upload" phx-value-ref={entry.ref}>Cancel</button>
      </div>

      <%= for err <- upload_errors(@uploads.avatar, entry) do %>
        <p class="error"><%= err %></p>
      <% end %>
    <% end %>

    <button type="submit">Upload</button>
  </form>
  """
end

def handle_event("cancel-upload", %{"ref" => ref}, socket) do
  {:noreply, cancel_upload(socket, :avatar, ref)}
end
```

---

## Nested Forms

For associations:

```elixir
def mount(_params, _session, socket) do
  post = %Post{comments: [%Comment{}]}
  changeset = Blog.change_post(post)
  {:ok, assign(socket, form: to_form(changeset))}
end
```

```heex
<.simple_form for={@form} phx-submit="save">
  <.input field={@form[:title]} label="Title" />

  <.inputs_for :let={comment_form} field={@form[:comments]}>
    <.input field={comment_form[:body]} label="Comment" />
  </.inputs_for>

  <button type="button" phx-click="add-comment">Add Comment</button>

  <:actions>
    <.button>Save</.button>
  </:actions>
</.simple_form>
```

```elixir
def handle_event("add-comment", _, socket) do
  changeset = socket.assigns.form.source
  comments = Ecto.Changeset.get_field(changeset, :comments) ++ [%Comment{}]
  changeset = Ecto.Changeset.put_assoc(changeset, :comments, comments)
  {:noreply, assign(socket, form: to_form(changeset))}
end
```

---

## This Codebase

```elixir
# lib/chatroom_web/live/chat_live.ex
def mount(_params, session, socket) do
  username = session["username"] || "Anonymous"
  {:ok, assign(socket, username: username, form: to_form(%{}))}
end

def handle_event("send_message", %{"body" => body}, socket) do
  attrs = %{username: socket.assigns.username, body: body}

  case Chat.create_message(attrs) do
    {:ok, _message} ->
      {:noreply, assign(socket, form: to_form(%{}))}

    {:error, _changeset} ->
      {:noreply, socket}
  end
end
```

```heex
<.simple_form for={@form} phx-submit="send_message">
  <.input field={@form[:body]} placeholder="Type a message..." />
  <:actions>
    <.button>Send</.button>
  </:actions>
</.simple_form>
```

---

## Form Tips

### Clear Form After Submit

```elixir
{:noreply, assign(socket, form: to_form(%{}))}
# Or with changeset
{:noreply, assign(socket, form: to_form(Accounts.change_user(%User{})))}
```

### Focus Input After Action

```heex
<.input field={@form[:body]} id="message-input" phx-hook="AutoFocus" />
```

### Disable Submit Until Valid

```heex
<.button disabled={!@form.source.valid?}>Save</.button>
```

### Show Loading State

```heex
<.button phx-disable-with="Saving...">Save</.button>
```

---

## Key Takeaways

1. **`to_form/1`** - Convert changeset/map to form
2. **`phx-change="validate"`** - Live validation
3. **`phx-submit="save"`** - Handle submission
4. **`Map.put(:action, :validate)`** - Show errors
5. **Core components** - `<.simple_form>`, `<.input>`
6. **Debounce** - Control validation frequency

---

**You've completed LiveView!**

Congratulations! You've learned the fundamentals of:

- Elixir language
- OTP patterns
- Phoenix framework
- Ecto database
- LiveView real-time UI

**Next:** Explore [This Codebase](../06-this-codebase/) for a guided tour of the chat application.
