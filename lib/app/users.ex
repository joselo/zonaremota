defmodule App.Users do
  alias App.Repo
  alias App.User

  def save_user(attrs) do
    if user = find_user(attrs) do
      {:ok, user}
    else
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()
    end
  end

  defp find_user(%{"email" => email}) do
    Repo.get_by(User, %{email: email})
  end

  defp find_user(_) do
    nil
  end
end
