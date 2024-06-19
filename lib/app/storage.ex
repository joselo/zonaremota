defmodule App.Storage do
  def upload(filepath, content) do
    bucket()
    |> ExAws.S3.put_object(filepath, content)
    |> ExAws.request()
  end

  def download(filepath) do
    bucket()
    |> ExAws.S3.get_object(filepath)
    |> ExAws.request()
  end

  def get_download_url(filepath) do
    :s3
    |> ExAws.Config.new([])
    |> ExAws.S3.presigned_url(:get, bucket(), filepath)
  end

  def bucket(), do: Application.get_env(:ex_aws, :s3)[:bucket]
end
