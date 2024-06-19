defmodule AppWeb.SharedComponents do
  use Phoenix.Component
  use AppWeb, :verified_routes

  alias App.Storage

  attr :avatar, :string, required: true

  def user_avatar(assigns) do
    assigns =
      assign_new(assigns, :avatar_url, fn ->
        gen_avatar_url(assigns.avatar)
      end)

    ~H"""
    <div :if={@avatar_url}>
      <img src={@avatar_url} width="42" height="42" />
    </div>
    """
  end

  defp gen_avatar_url(nil) do
    nil
  end

  defp gen_avatar_url(avatar) do
    if App.Env.s3_bucket?() do
      case Storage.get_download_url(avatar) do
        {:ok, url} -> url
        _ -> nil
      end
    else
      ~p"/uploads/#{avatar}"
    end
  end
end
