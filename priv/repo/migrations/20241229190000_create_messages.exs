defmodule Chatroom.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :username, :string, null: false
      add :body, :text, null: false

      timestamps()
    end

    create index(:messages, [:inserted_at])
  end
end
