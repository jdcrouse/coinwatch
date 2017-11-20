defmodule Coinwatch.ReleaseTasks do
  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
  ]

  @coinwatch [
    :coinwatch,
  ]

  @repos [
    Coinwatch.Repo,
  ]

  def seed do
    IO.puts "Loading Coinwatch . . . "
    # load code, but don't start
    :ok = Application.load(:coinwatch)

    IO.puts "Starting dependencies . . ."
    # start apps needed for migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # start the Repos
    IO.puts "Starting Repos . . ."
    Enum.each(@repos, &(&1.start_link(pool_size: 1)))

    # run migrations
    Enum.each(@coinwatch, &run_migrations_for/1)

    # run seed script, if exists
    seed_script = Path.join([priv_dir(:coinwatch), "repo", "seeds.exs"])
    if File.exists?(seed_script) do
      IO.puts "Running seed script . . ."
      Code.eval_file(seed_script)
    end

    #signal shutdown
    IO.puts "Success!"
    :init.stop()
  end

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations_for(app) do
    IO.puts "Running migrations for #{app}"
    Ecto.Migrator.run(Coinwatch.Repo, migrations_path(app), :up, all: true)
  end

  defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])
  defp seed_path(app), do: Path.join([priv_dir(app), "repo", "seeds.exs"])
end
