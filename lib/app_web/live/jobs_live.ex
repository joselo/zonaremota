defmodule AppWeb.JobsLive do
  use AppWeb, :live_view

  import AppWeb.JobsLive.Components, only: [job_detail_modal: 1, job_row: 1]

  alias App.Jobs
  alias Phoenix.PubSub

  @pub_sub_topic "new_jobs_posted"

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(App.PubSub, @pub_sub_topic)

    socket =
      socket
      |> assign(refresh_jobs: false)
      |> paginate_jobs(1)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = apply_action(socket.assigns.live_action, params, socket)

    {:noreply, socket}
  end

  @impl true
  def handle_event("next-page", _params, socket) do
    new_page = socket.assigns.page + 1

    {:noreply, paginate_jobs(socket, new_page)}
  end

  @impl true
  def handle_event("refresh_jobs", _params, socket) do
    new_jobs_list =
      socket.assigns.last_job_inserted
      |> Jobs.list_new_jobs()
      |> Enum.reverse()

    socket =
      socket
      |> assign(refresh_jobs: false)
      |> stream(:jobs, new_jobs_list, at: 0)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_jobs_posted}, socket) do
    {:noreply, assign(socket, refresh_jobs: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <div class="sticky top-0 underline bg-white">
        <.link :if={@refresh_jobs} href="#top-page" phx-click="refresh_jobs">
          <%= gettext("Nuevas ofertas fueron publicadas") %>
        </.link>
      </div>

      <div id="jobs" phx-update="stream" phx-viewport-bottom={!@end_of_timeline? && "next-page"}>
        <.job_row :for={{dom_id, job} <- @streams.jobs} id={dom_id} job={job} />
      </div>

      <div :if={@end_of_timeline?} class="mt-5 text-center">
        🎉 <%= gettext("Ya no existen mas trabajos") %> 🎉
      </div>
    </div>

    <.job_detail_modal :if={@live_action == :show} job={@job} />
    """
  end

  defp apply_action(:index, _params, socket) do
    socket
  end

  defp apply_action(:show, %{"id" => id}, socket) do
    job = Jobs.get_job(id)

    assign(socket, job: job)
  end

  defp paginate_jobs(socket, new_page) do
    jobs = Jobs.list_jobs(new_page)
    last_job_inserted = if new_page == 1, do: List.first(jobs)

    if Enum.empty?(jobs) do
      socket
      |> assign(end_of_timeline?: true)
      |> stream(:jobs, [])
      |> assign_new(:last_job_inserted, fn -> last_job_inserted end)
    else
      socket
      |> assign(end_of_timeline?: false, page: new_page)
      |> stream(:jobs, jobs)
      |> assign_new(:last_job_inserted, fn -> last_job_inserted end)
    end
  end
end
