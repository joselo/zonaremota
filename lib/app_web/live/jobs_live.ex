defmodule AppWeb.JobsLive do
  use AppWeb, :live_view

  import AppWeb.JobsLive.Components, only: [job_detail_modal: 1, job_form_modal: 1, job_row: 1]

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
        <.job_row :for={job <- @jobs} job={job} />
      </div>
    </div>

    <.job_form_modal :if={@live_action in [:new, :edit]} changeset={@changeset} job={@job} />
    <.job_detail_modal :if={@live_action == :show} job={@job} />
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

  defp apply_action(:show, %{"id" => id}, socket) do
    job = find_job(socket.assigns.jobs, id)

    assign(socket, job: job)
  end

  defp find_job(jobs, id) do
    {id, _} = Integer.parse(id)
    Enum.find(jobs, fn job -> job.id == id end)
  end
end
