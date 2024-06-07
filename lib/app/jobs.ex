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

  def list_jobs(page, user_id) do
    offset = (page - 1) * @per_page

    query =
      from(jobs in Job,
        where: jobs.user_id == ^user_id,
        limit: @per_page,
        offset: ^offset,
        order_by: [desc: :inserted_at]
      )

    Repo.all(query)
  end

  def get_job(id) do
    Repo.get!(Job, id)
  end

  def list_new_jobs(%Job{} = last_job_inserted) do
    query =
      from(jobs in Job,
        where: jobs.inserted_at > ^last_job_inserted.inserted_at,
        order_by: [desc: :inserted_at]
      )

    Repo.all(query)
  end

  def list_new_jobs(nil) do
    []
  end

  def get_my_job(id, user_id) do
    Repo.get_by!(Job, %{id: id, user_id: user_id})
  end
end
