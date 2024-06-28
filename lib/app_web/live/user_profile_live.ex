defmodule AppWeb.UserProfileLive do
  use AppWeb, :live_view

  import AppWeb.SharedComponents, only: [user_avatar: 1]

  alias App.Users
  alias App.Storage
  alias App.User

  @impl true
  def mount(_params, _session, socket) do
    changeset = User.changeset(socket.assigns.current_user)
    form = to_form(changeset)

    socket =
      socket
      |> assign(changeset: changeset, form: form)
      |> allow_upload(:files, accept: App.Env.list_avatar_formats(), max_file_size: 125_000)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    case Users.update_user(socket.assigns.current_user, set_avatar(params, socket)) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Perfil guardado"))
         |> push_navigate(to: ~p"/my-profile")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset, form: to_form(changeset))
         |> put_flash(:error, gettext("No fue posible guardar el perfil"))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-submit="save" phx-change="validate" autocomplete="off">
        <.live_file_input upload={@uploads.files} />

        <.preview_avatar uploads={@uploads} />
        <.user_avatar avatar={@current_user.avatar} />

        <.input field={@form[:name]} label={gettext("Nombre de la empresa")} />
        <.input field={@form[:description]} label={gettext("Descripción")} type="textarea" />

        <.button type="submit"><%= gettext("Guardar") %></.button>
      </.simple_form>
    </div>
    """
  end

  attr :uploads, :any, required: true

  defp preview_avatar(assigns) do
    ~H"""
    <section phx-drop-target={@uploads.files.ref}>
      <%= for entry <- @uploads.files.entries do %>
        <article class="upload-entry">
          <figure>
            <.live_img_preview entry={entry} width="42" height="42" />
            <figcaption><%= entry.client_name %></figcaption>
          </figure>

          <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            aria-label="cancel"
          >
            &times;
          </button>

          <%= for err <- upload_errors(@uploads.files, entry) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
        </article>
      <% end %>

      <%= for err <- upload_errors(@uploads.files) do %>
        <p class="alert alert-danger"><%= error_to_string(err) %></p>
      <% end %>
    </section>
    """
  end

  def set_avatar(params, socket) do
    case consume_files(socket) do
      [file_name | _] ->
        Map.put(params, "avatar", file_name)

      [] ->
        params
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  defp consume_files(socket) do
    consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
      file_name = "#{entry.uuid}.#{ext(entry)}"

      if App.Env.s3_bucket?() do
        file = File.read!(path)
        Storage.upload(file_name, file)
      else
        dest = Path.join(Application.app_dir(:app, "priv/static/uploads"), file_name)
        File.cp!(path, dest)
      end

      {:ok, file_name}
    end)
  end

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end
end
