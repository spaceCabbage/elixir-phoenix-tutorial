defmodule Chatroom.Chat do
  @moduledoc """
  The Chat context - handles all chat message operations.
  """
  import Ecto.Query
  alias Chatroom.Repo
  alias Chatroom.Chat.Message

  @topic "chat:lobby"

  @doc """
  Returns the last 50 messages, oldest first.
  """
  def list_messages do
    Message
    |> order_by(asc: :inserted_at)
    |> limit(50)
    |> Repo.all()
  end

  @doc """
  Creates a message and broadcasts it to all subscribers.
  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:new_message)
  end

  @doc """
  Subscribe to chat messages.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(Chatroom.PubSub, @topic)
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(Chatroom.PubSub, @topic, {event, message})
    {:ok, message}
  end

  defp broadcast({:error, _} = error, _event), do: error
end
