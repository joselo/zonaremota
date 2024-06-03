defmodule App.Jobs do
  import Ecto.Query

  alias App.Repo
  alias App.Job

  @per_page 20

  def save_job(%Job{} = job, attr) do
    job
    |> Job.changeset(attr)
    |> Repo.insert_or_update()
  end

  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  def list_jobs(page \\ 1) do
    offset = (page - 1) * @per_page

    query = from(jobs in Job, limit: @per_page, offset: ^offset, order_by: [desc: :inserted_at])

    Repo.all(query)
  end

  def get_job(id) do
    Repo.get!(Job, id)
  end
end
