defmodule AppWeb.UserSessionController do
  use AppWeb, :controller

  alias App.UserTokens
  alias App.User

  def index(conn, %{"token" => token}) do
    case UserTokens.get_user_by_email_token(token) do
      %User{} = _user ->
        conn
        |> put_flash(:info, gettext("Hola de nuevo"))
        |> put_token_in_session(token)
        |> redirect(to: ~p"/")

      _ ->
        conn
        |> put_flash(:error, gettext("El enlace nos es valido"))
        |> redirect(to: ~p"/")
    end
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, gettext("Hasta pronto"))
    |> remove_token_from_session()
    |> redirect(to: ~p"/")
  end

  defp put_token_in_session(conn, token) do
    put_session(conn, :user_token, token)
  end

  defp remove_token_from_session(conn) do
    delete_session(conn, :user_token)
  end
end
