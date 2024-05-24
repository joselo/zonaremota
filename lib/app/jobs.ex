defmodule App.Jobs do
  import Ecto.Query

  alias App.Repo
  alias App.Job

  def create_job(attr) do
    %Job{}
    |> Job.changeset(attr)
    |> Repo.insert()
  end

  def list_jobs do
    query = from(jobs in Job, order_by: [desc: :inserted_at])

    Repo.all(query)
  end
end
