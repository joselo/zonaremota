defmodule App.Users do
  alias App.Repo
  alias App.User
  alias App.UserTokens
  alias App.UserEmail

  def save_user(attrs) do
    if user = find_user(attrs) do
      {:ok, user}
    else
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()
    end
  end

  def deliver_magic_link(user, magic_link_url) do
    {email_token, user_token} = UserTokens.build_hashed_token(user)

    Repo.insert!(user_token)

    UserEmail.magic_link_email(user, magic_link_url.(email_token))
  end

  def find_user(%{"email" => email}) do
    Repo.get_by(User, %{email: email})
  end

  def find_user(_) do
    nil
  end
end
