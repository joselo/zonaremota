defmodule App.Env do
  def s3_bucket? do
    System.get_env("BUCKET_NAME")
  end

  def list_avatar_formats do
    ~w(.jpg .jpeg .png .webp)
  end

  def format_date_time(date_time) do
    Calendar.strftime(date_time, "%y-%m-%d %I:%M:%S %p")
  end
end
