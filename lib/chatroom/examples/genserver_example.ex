defmodule Chatroom.Examples.Counter do
  @moduledoc """
  Example GenServer - a stateful process.

  GenServer is the fundamental building block for stateful processes in OTP.
  It handles:
  - State management
  - Synchronous calls (call - waits for response)
  - Asynchronous casts (cast - fire and forget)
  - Info messages (handle_info - from other processes)

  ## Usage

      # Start the server
      {:ok, pid} = Chatroom.Examples.Counter.start_link(initial: 10)

      # Get current value (synchronous)
      Chatroom.Examples.Counter.get(pid)  # => 10

      # Increment (asynchronous)
      Chatroom.Examples.Counter.increment(pid)
      Chatroom.Examples.Counter.get(pid)  # => 11

      # Increment by amount (synchronous, returns new value)
      Chatroom.Examples.Counter.increment_by(pid, 5)  # => 16

      # Reset
      Chatroom.Examples.Counter.reset(pid)
      Chatroom.Examples.Counter.get(pid)  # => 0
  """

  use GenServer

  # ============================================================
  # CLIENT API (Public interface - called by other code)
  # ============================================================

  @doc "Start the counter process"
  def start_link(opts \\ []) do
    initial_value = Keyword.get(opts, :initial, 0)
    # GenServer.start_link(module, init_arg, options)
    GenServer.start_link(__MODULE__, initial_value, opts)
  end

  @doc "Get the current count (synchronous call)"
  def get(pid) do
    GenServer.call(pid, :get)
  end

  @doc "Increment by 1 (asynchronous cast)"
  def increment(pid) do
    GenServer.cast(pid, :increment)
  end

  @doc "Decrement by 1 (asynchronous cast)"
  def decrement(pid) do
    GenServer.cast(pid, :decrement)
  end

  @doc "Increment by amount and return new value (synchronous call)"
  def increment_by(pid, amount) do
    GenServer.call(pid, {:increment_by, amount})
  end

  @doc "Reset to zero (asynchronous cast)"
  def reset(pid) do
    GenServer.cast(pid, :reset)
  end

  # ============================================================
  # SERVER CALLBACKS (Implement GenServer behavior)
  # ============================================================

  @impl true
  def init(initial_value) do
    IO.puts("[Counter] Starting with initial value: #{initial_value}")
    # Return {:ok, state} to indicate successful initialization
    {:ok, initial_value}
  end

  # handle_call/3 - Synchronous, must reply
  # Arguments: request, from (caller), state
  # Returns: {:reply, response, new_state}

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:increment_by, amount}, _from, state) do
    new_state = state + amount
    {:reply, new_state, new_state}
  end

  # handle_cast/2 - Asynchronous, no reply
  # Arguments: request, state
  # Returns: {:noreply, new_state}

  @impl true
  def handle_cast(:increment, state) do
    {:noreply, state + 1}
  end

  @impl true
  def handle_cast(:decrement, state) do
    {:noreply, state - 1}
  end

  @impl true
  def handle_cast(:reset, _state) do
    {:noreply, 0}
  end

  # handle_info/2 - Handle messages from other processes
  # This is how PubSub messages are received!

  @impl true
  def handle_info({:set, value}, _state) do
    IO.puts("[Counter] Received set message: #{value}")
    {:noreply, value}
  end

  @impl true
  def handle_info(msg, state) do
    IO.puts("[Counter] Unknown message: #{inspect(msg)}")
    {:noreply, state}
  end
end

defmodule Chatroom.Examples.ChatRoom do
  @moduledoc """
  A more realistic GenServer example - a chat room process.

  This demonstrates:
  - Maintaining complex state (users, messages)
  - Broadcasting with PubSub
  - Using handle_info for subscriptions

  ## Usage

      # Start a chat room
      {:ok, room} = Chatroom.Examples.ChatRoom.start_link(name: "general")

      # Join the room
      Chatroom.Examples.ChatRoom.join(room, "alice")

      # Send a message
      Chatroom.Examples.ChatRoom.send_message(room, "alice", "Hello!")

      # Get history
      Chatroom.Examples.ChatRoom.get_messages(room)

      # Get users
      Chatroom.Examples.ChatRoom.get_users(room)
  """

  use GenServer

  defstruct [:name, users: MapSet.new(), messages: []]

  # ============================================================
  # CLIENT API
  # ============================================================

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, name)
  end

  def join(room, username) do
    GenServer.call(room, {:join, username})
  end

  def leave(room, username) do
    GenServer.call(room, {:leave, username})
  end

  def send_message(room, username, body) do
    GenServer.call(room, {:send_message, username, body})
  end

  def get_messages(room) do
    GenServer.call(room, :get_messages)
  end

  def get_users(room) do
    GenServer.call(room, :get_users)
  end

  # ============================================================
  # SERVER CALLBACKS
  # ============================================================

  @impl true
  def init(name) do
    IO.puts("[ChatRoom] Room '#{name}' created")
    {:ok, %__MODULE__{name: name}}
  end

  @impl true
  def handle_call({:join, username}, _from, state) do
    if MapSet.member?(state.users, username) do
      {:reply, {:error, :already_joined}, state}
    else
      new_users = MapSet.put(state.users, username)
      IO.puts("[ChatRoom] #{username} joined #{state.name}")
      {:reply, :ok, %{state | users: new_users}}
    end
  end

  @impl true
  def handle_call({:leave, username}, _from, state) do
    new_users = MapSet.delete(state.users, username)
    IO.puts("[ChatRoom] #{username} left #{state.name}")
    {:reply, :ok, %{state | users: new_users}}
  end

  @impl true
  def handle_call({:send_message, username, body}, _from, state) do
    if MapSet.member?(state.users, username) do
      message = %{
        username: username,
        body: body,
        timestamp: DateTime.utc_now()
      }

      # Keep last 100 messages
      new_messages = Enum.take([message | state.messages], 100)

      IO.puts("[ChatRoom] #{username}: #{body}")
      {:reply, {:ok, message}, %{state | messages: new_messages}}
    else
      {:reply, {:error, :not_joined}, state}
    end
  end

  @impl true
  def handle_call(:get_messages, _from, state) do
    # Return messages oldest-first
    {:reply, Enum.reverse(state.messages), state}
  end

  @impl true
  def handle_call(:get_users, _from, state) do
    {:reply, MapSet.to_list(state.users), state}
  end
end
