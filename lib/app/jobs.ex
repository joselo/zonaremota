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

  def list_jobs(page, search_params) do
    offset = (page - 1) * @per_page

    query =
      from(jobs in Job,
        limit: @per_page,
        offset: ^offset,
        order_by: [desc: :inserted_at],
        preload: [:user]
      )
      |> filter_by_search_params(search_params)

    Repo.all(query)
  end

  defp filter_by_search_params(query, %{"search_text" => search_text}) do
    where(query, [jobs], ilike(jobs.title, ^"%#{search_text}%"))
  end

  defp filter_by_search_params(query, _search_params) do
    query
  end

  def list_my_jobs(page, user_id) do
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
    other_jobs_query =
      from(jobs in Job, where: jobs.id != ^id, order_by: [desc: jobs.inserted_at], limit: 10)

    Job
    |> Repo.get!(id)
    |> Repo.preload(other_jobs: other_jobs_query)
  end

  def list_new_jobs(%Job{} = last_job_inserted) do
    query =
      from(jobs in Job,
        where: jobs.inserted_at > ^last_job_inserted.inserted_at,
        order_by: [desc: :inserted_at],
        preload: [:user]
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
