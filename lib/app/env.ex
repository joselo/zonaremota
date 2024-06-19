defmodule App.Env do
  def s3_bucket? do
    System.get_env("BUCKET_NAME")
  end
end
