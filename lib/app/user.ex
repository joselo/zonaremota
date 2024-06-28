defmodule App.User do
  use Ecto.Schema

  import Ecto.Changeset
  import AppWeb.Gettext

  alias App.Job

  schema "users" do
    has_many :jobs, Job

    field :email, :string
    field :avatar, :string
    field :name, :string
    field :description, :string

    timestamps()
  end

  def login_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
      message: gettext("debe tener el signo @ y sin espacios")
    )
    |> unique_constraint(:email)
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:avatar, :name, :description])
    |> validate_required([:name])
  end
end
