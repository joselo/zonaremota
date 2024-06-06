defmodule App.Repo.Migrations.AddUserIdToJobs do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :user_id, references(:users)
    end
  end
end
