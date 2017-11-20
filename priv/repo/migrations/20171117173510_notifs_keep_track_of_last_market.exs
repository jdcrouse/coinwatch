defmodule Coinwatch.Repo.Migrations.NotifsKeepTrackOfLastMarket do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :market_id, references(:markets)
    end
  end
end
