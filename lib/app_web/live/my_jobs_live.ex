defmodule AppWeb.MyJobsLive do
  use AppWeb, :live_view

  import AppWeb.JobsLive.Components, only: [job_detail_modal: 1, job_form_modal: 1, job_row: 1]

  alias App.Job
  alias App.Jobs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, paginate_jobs(socket, 1)}
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
        socket = stream_insert(socket, :jobs, job, at: 0)

        {:noreply,
         socket
         |> put_flash(:info, "Trabajo publicado: #{job.title}")
         |> push_patch(to: ~p"/my-jobs")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Jobs.get_my_job(id, socket.assigns.current_user.id)
    |> Jobs.delete_job()
    |> case do
      {:ok, job} ->
        socket = stream_delete(socket, :jobs, job)

        {:noreply,
         socket
         |> put_flash(:info, "Trabajo borrado: #{job.title}")
         |> push_patch(to: ~p"/my-jobs")}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "El trabajo no pudo borrarse: #{socket.assigns.job.title}")}
    end
  end

  @impl true
  def handle_event("next-page", _params, socket) do
    new_page = socket.assigns.page + 1

    {:noreply, paginate_jobs(socket, new_page)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <div id="jobs" phx-update="stream" phx-viewport-bottom={!@end_of_timeline? && "next-page"}>
        <.job_row
          :for={{dom_id, job} <- @streams.jobs}
          id={dom_id}
          job={job}
          current_user={@current_user}
        />
      </div>

      <div :if={@end_of_timeline?} class="mt-5 text-center">
        🎉 <%= gettext("Ya no existen mas trabajos") %> 🎉
      </div>
    </div>

    <.job_form_modal :if={@live_action in [:new, :edit]} changeset={@changeset} job={@job} />
    <.job_detail_modal :if={@live_action == :show} job={@job} />
    """
  end

  defp apply_action(:index, _params, socket) do
    socket
  end

  defp apply_action(:new, _params, socket) do
    job = %Job{user_id: socket.assigns.current_user.id}
    changeset = Job.changeset(job)

    assign(socket, job: job, changeset: changeset)
  end

  defp apply_action(:edit, %{"id" => id}, socket) do
    job = Jobs.get_my_job(id, socket.assigns.current_user.id)
    changeset = Job.changeset(job)

    assign(socket, job: job, changeset: changeset)
  end

  defp apply_action(:show, %{"id" => id}, socket) do
    job = Jobs.get_job(id)

    assign(socket, job: job)
  end

  defp apply_action(:my_jobs, _params, socket) do
    socket
  end

  defp paginate_jobs(socket, new_page) do
    jobs = Jobs.list_jobs(new_page, socket.assigns.current_user.id)

    if Enum.empty?(jobs) do
      socket
      |> assign(end_of_timeline?: true)
      |> stream(:jobs, [])
    else
      socket
      |> assign(end_of_timeline?: false)
      |> assign(page: new_page)
      |> stream(:jobs, jobs)
    end
  end
end
