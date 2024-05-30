defmodule AppWeb.JobsLive do
  use AppWeb, :live_view

  alias App.Job
  alias App.Jobs

  @impl true
  def mount(_params, _session, socket) do
    jobs = Jobs.list_jobs()

    socket = assign(socket, jobs: jobs)

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
    case Jobs.save_job(socket.assigns.job, params) do
      {:ok, job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Trabajo publicado: #{job.title}")
         |> push_navigate(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket.assigns.jobs
    |> find_job(id)
    |> Jobs.delete_job()
    |> case do
      {:ok, job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Trabajo borrado: #{job.title}")
         |> push_navigate(to: ~p"/")}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "El trabajo no pudo borrarse: #{socket.assigns.job.title}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <.button phx-click={JS.patch(%JS{}, ~p"/new") |> show_modal("job-form-modal")}>
        <%= gettext("Publicar") %>
      </.button>

      <div>
        <div :for={job <- @jobs} class="border-b last:border-b-0 py-2 flex justify-between">
          <div>
            <%= job.title %>
          </div>

          <div>
            <.button phx-click={JS.patch(%JS{}, ~p"/edit/#{job.id}") |> show_modal("job-form-modal")}>
              <%= gettext("Editar") %>
            </.button>

            <.button phx-click="delete" phx-value-id={job.id} data-confirm={gettext("Estas seguro de borrar?")}>
              <%= gettext("Borrar") %>
            </.button>
          </div>
        </div>
      </div>
    </div>

    <.modal id="job-form-modal" show={@live_action in [:new, :edit]} on_cancel={JS.patch(%JS{}, ~p"/")}>
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

  defp apply_action(:index, _params, socket) do
    assign(socket, job: nil, changeset: nil)
  end

  defp apply_action(:new, _params, socket) do
    job = %Job{}
    changeset = Job.changeset(job)

    assign(socket, job: job, changeset: changeset)
  end

  defp apply_action(:edit, %{"id" => id}, socket) do
    job = find_job(socket.assigns.jobs, id)
    changeset = Job.changeset(job)

    assign(socket, job: job, changeset: changeset)
  end

  defp find_job(jobs, id) do
    {id, _} = Integer.parse(id)
    job = Enum.find(jobs, fn job -> job.id == id end)
  end
end
