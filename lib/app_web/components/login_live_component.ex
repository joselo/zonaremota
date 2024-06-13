defmodule AppWeb.LoginLiveComponent do
  use AppWeb, :live_component

  import AppWeb.CoreComponents, only: [modal: 1, button: 1, input: 1, show_modal: 1]
  import AppWeb.Gettext

  alias App.User
  alias App.Users

  @impl true
  def mount(socket) do
    user = %User{}
    changeset = User.login_changeset(user)

    socket = assign(socket, user: user, changeset: changeset)

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, current_user: assigns.current_user)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.user
      |> User.login_changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    case Users.save_user(params) do
      {:ok, user} ->
        magic_link_url = &(~p"/users/sessions/#{&1}" |> url())
        Users.deliver_magic_link(user, magic_link_url)

        {:noreply,
         socket
         |> put_flash(
           :info,
           gettext("Enviamos un enlace a %{email} para ingresar", %{email: user.email})
         )
         |> push_navigate(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={!@current_user}>
        <.button phx-click={show_modal("login-form-modal")}>
          <%= gettext("Publicar oferta") %>
        </.button>

        <.modal id="login-form-modal">
          <.user_form changeset={@changeset} target={@myself} />
        </.modal>
      </div>

      <div :if={@current_user}>
        <.button phx-click={JS.navigate(%JS{}, ~p"/new")}>
          <%= gettext("Publicar") %>
        </.button>

        <.link href={~p"/users/logout"} method="delete">
          <%= gettext("Salir") %>
        </.link>
      </div>
    </div>
    """
  end

  attr :changeset, Ecto.Changeset, required: true
  attr :target, :string, required: true

  defp user_form(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@changeset}
      phx-change="validate"
      phx-submit="save"
      phx-target={@target}
      class="space-y-6"
      autocomplete="off"
    >
      <.input type="text" field={f[:email]} label={gettext("Email")} />

      <.button>
        <%= gettext("Enviar link magico") %>
      </.button>
    </.form>
    """
  end
end
