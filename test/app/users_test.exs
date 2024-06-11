defmodule App.UsersTest do
  use App.DataCase

  alias App.Users
  alias App.Repo
  alias App.User

  setup do
    {:ok, user} = Repo.insert(%User{email: "test@example.com"})

    {:ok, user: user}
  end

  describe "find_user/1" do
    test "it should return nil without email" do
      assert !Users.find_user("elixir")
    end

    test "it should return nil if the user do not exit" do
      assert !Users.find_user(%{"email" => "test2@example.com"})
    end

    test "it should return the user", %{user: user} do
      assert Users.find_user(%{"email" => user.email})
    end
  end
end
