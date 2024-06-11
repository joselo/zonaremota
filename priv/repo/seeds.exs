# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias App.Users
alias App.Jobs
alias App.Job

{:ok, user} = Users.save_user(%{"email" => "user@example.com"})

Enum.each(1..50, fn index ->
  :timer.sleep(2000)
  {:ok, _job} = Jobs.save_job(%Job{user_id: user.id}, %{"title" => "Oferta #{index}"})
end)
