defmodule AppWeb.JobsLive do
  use AppWeb, :live_view

  alias App.Job
  alias App.Jobs

  @impl true
  def mount(_params, _session, socket) do
    job = %Job{}
    changeset = Job.changeset(job)
    jobs = Jobs.list_jobs()

    socket = assign(socket, changeset: changeset, job: job, jobs: jobs)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = apply_action(socket.assigns.live_action, params, socket)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"job" => params}, socket) do
    changeset =
      socket.assigns.job
      |> Job.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"job" => params}, socket) do
    case Jobs.create_job(params) do
      {:ok, job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Trabajo creado: #{job.title}")
         |> push_navigate(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <.button phx-click={JS.patch(%JS{}, ~p"/new") |> show_modal("new-job-modal")}>
        <%= gettext("Publicar") %>
      </.button>

      <div>
        <div :for={job <- @jobs} class="border-b last:border-b-0 py-2">
          <%= job.title %>
        </div>
      </div>
    </div>

    <.modal id="new-job-modal" show={@live_action == :new} on_cancel={JS.patch(%JS{}, ~p"/")}>
      <div class="mb-8 text-lg font-semibold">
        <%= gettext("Publicar oferta laboral") %>
      </div>

      <.form
        :let={f}
        for={@changeset}
        phx-change="validate"
        phx-submit="save"
        class="space-y-6"
        autocomplete="off"
      >
        <.input type="text" field={f[:title]} label={gettext("Titulo")} />
        <.button>Crear</.button>
      </.form>
    </.modal>
    """
  end

  defp apply_action(:index, params, socket) do
    socket
  end

  defp apply_action(:new, params, socket) do
    socket
  end
end
