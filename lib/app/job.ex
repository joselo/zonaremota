defmodule App.Job do
  use Ecto.Schema

  import Ecto.Changeset

  alias App.User

  @required_fields [:title, :description]

  schema "jobs" do
    belongs_to :user, User
    has_many :other_jobs, through: [:user, :jobs]

    field :title, :string
    field :description, :string

    timestamps()
  end

  def changeset(job, attrs \\ %{}) do
    job
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:user)
  end
end
