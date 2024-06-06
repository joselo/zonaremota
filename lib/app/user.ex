defmodule App.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias App.Job

  schema "users" do
    has_many :jobs, Job

    field :email, :string

    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
