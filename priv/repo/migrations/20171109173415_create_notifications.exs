defmodule Coinwatch.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :pair, :string
      add :threshold, :integer
      add :high, :boolean, default: false, null: false
      add :notified, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:notifications, [:user_id])
  end
end
