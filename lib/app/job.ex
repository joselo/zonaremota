defmodule App.Job do
  use Ecto.Schema

  import Ecto.Changeset

  schema "jobs" do
    field :title, :string

    timestamps()
  end

  def changeset(job, attrs \\ %{}) do
    job
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
