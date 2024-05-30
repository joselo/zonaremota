defmodule App.Jobs do
  import Ecto.Query

  alias App.Repo
  alias App.Job

  def save_job(%Job{} = job, attr) do
    job
    |> Job.changeset(attr)
    |> Repo.insert_or_update()
  end

  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  def list_jobs do
    query = from(jobs in Job, order_by: [desc: :inserted_at])

    Repo.all(query)
  end
end
