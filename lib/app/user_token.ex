defmodule App.UserToken do
  use Ecto.Schema

  import Ecto.Changeset

  alias App.User

  schema "users_tokens" do
    belongs_to :user, User

    field :token, :binary

    timestamps(updated_at: false)
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
