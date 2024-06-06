defmodule AppWeb.UserAuth do
  use AppWeb, :verified_routes

  import AppWeb.Gettext
  import Phoenix.Component, only: [assign_new: 3]
  import Phoenix.LiveView, only: [put_flash: 3, redirect: 2]

  alias App.UserTokens

  def on_mount(:mount_current_user, _params, session, socket) do
    socket = assign_new(socket, :current_user, fn -> fetch_current_user(session) end)

    {:cont, socket}
  end

  def on_mount(:ensure_authenticated, _params, _session, socket) do
    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> put_flash(:error, gettext("Para acceder a esta pagina debes ingresar"))
        |> redirect(to: ~p"/") 

      {:halt, socket}
    end
  end

  defp fetch_current_user(session) do
    if token = session["user_token"] do
      UserTokens.get_user_by_email_token(token)
    end
  end
end
