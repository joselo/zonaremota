defmodule App.Repo.Migrations.AddDescriptionToJobs do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :description, :text
    end
  end
end
