defmodule AppWeb.JobsLive.Components do
  use Phoenix.Component
  use AppWeb, :verified_routes

  import AppWeb.CoreComponents,
    only: [modal: 1, button: 1, input: 1, show_modal: 2, simple_form: 1]

  import AppWeb.Gettext

  alias Phoenix.LiveView.JS
  alias App.Job
  alias App.User

  attr :changeset, Ecto.Changeset, required: true
  attr :job, Job, required: true

  def job_form_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:modal_config, fn ->
        if assigns.job.id do
          %{
            title: gettext("Editar oferta"),
            submit_text: gettext("Guardar")
          }
        else
          %{
            title: gettext("Publicar oferta"),
            submit_text: gettext("Publicar")
          }
        end
      end)

    ~H"""
    <.modal id="job-form-modal" show={true} on_cancel={JS.patch(%JS{}, ~p"/")}>
      <div class="mb-8 text-lg font-semibold">
        <%= @modal_config.title %>
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
        <.button>
          <%= @modal_config.submit_text %>
        </.button>
      </.form>
    </.modal>
    """
  end

  attr :job, Job, required: true

  def job_detail_modal(assigns) do
    ~H"""
    <.modal id="job-detail-modal" show={true} on_cancel={JS.patch(%JS{}, ~p"/")}>
      <div class="mb-8 text-lg font-semibold">
        <%= @job.title %>
      </div>

      <.other_jobs :if={Enum.any?(@job.other_jobs)} jobs={@job.other_jobs} />
    </.modal>
    """
  end

  attr :jobs, :list, required: true

  def other_jobs(assigns) do
    ~H"""
    <div class="space-y-8">
      <h3 class="font-semibold"><%= gettext("Otras ofertas de la empresa") %></h3>

      <div :for={job <- @jobs}>
        <.link patch={~p"/#{job.id}"} class="underline">
          <%= job.title %>
        </.link>
      </div>
    </div>
    """
  end

  attr :job, Job, required: true
  attr :id, :string, required: true

  def job_row(assigns) do
    ~H"""
    <div id={@id} class="border-b last:border-b-0 py-2 flex justify-between">
      <div>
        <.link patch={~p"/#{@job.id}"} class="hover:underline">
          <%= @job.title %>
        </.link>

        <div :if={@job.user}>
          <div :if={@job.user.avatar}>
            <img src={~p"/uploads/#{@job.user.avatar}"} width="22" height="22" />
          </div>

          <div>
            <%= @job.user.email %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :job, Job, required: true
  attr :id, :string, required: true

  def my_job_row(assigns) do
    ~H"""
    <div id={@id} class="border-b last:border-b-0 py-2 flex justify-between">
      <div>
        <.link patch={~p"/#{@job.id}"} class="hover:underline">
          <%= @job.title %>
        </.link>
      </div>

      <div>
        <.button phx-click={JS.patch(%JS{}, ~p"/edit/#{@job.id}") |> show_modal("job-form-modal")}>
          <%= gettext("Editar") %>
        </.button>

        <.button
          phx-click="delete"
          phx-value-id={@job.id}
          data-confirm={gettext("Estas seguro de borrar?")}
        >
          <%= gettext("Borrar") %>
        </.button>
      </div>
    </div>
    """
  end

  attr :form, :map, required: true

  def search_job_form(assigns) do
    ~H"""
    <.simple_form for={@form} autocomplete="off" method="GET">
      <.input field={@form[:search_text]} placeholder={gettext("Buscar oferta...")} />
      <:actions>
        <.button><%= gettext("Buscar") %></.button>
      </:actions>
    </.simple_form>
    """
  end
end
