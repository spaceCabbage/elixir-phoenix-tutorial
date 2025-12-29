defmodule Chatroom.Repo do
  use Ecto.Repo,
    otp_app: :chatroom,
    adapter: Ecto.Adapters.SQLite3
end
