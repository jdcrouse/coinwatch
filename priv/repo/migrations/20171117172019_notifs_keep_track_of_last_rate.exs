defmodule Coinwatch.Repo.Migrations.NotifsKeepTrackOfLastRate do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :last_rate, :integer, default: 0
    end
  end
end
