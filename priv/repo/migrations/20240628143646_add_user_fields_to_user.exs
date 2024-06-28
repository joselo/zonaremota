defmodule App.Repo.Migrations.AddUserFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :description, :text
    end
  end
end
