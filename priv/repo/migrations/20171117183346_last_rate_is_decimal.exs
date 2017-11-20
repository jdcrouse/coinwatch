defmodule Coinwatch.Repo.Migrations.LastRateIsDecimal do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
       modify :last_rate, :decimal, default: 0.0
    end
  end
end
