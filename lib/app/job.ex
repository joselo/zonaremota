defmodule App.Job do
  use Ecto.Schema

  import Ecto.Changeset

  alias App.User

  schema "jobs" do
    belongs_to :user, User
    has_many :other_jobs, through: [:user, :jobs]

    field :title, :string

    timestamps()
  end

  def changeset(job, attrs \\ %{}) do
    job
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> assoc_constraint(:user)
  end
end
