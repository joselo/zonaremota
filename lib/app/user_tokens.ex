defmodule App.UserTokens do
  @rand_size 32
  @hash_algorithm :sha256

  alias App.UserToken

  def build_hashed_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {
      Base.url_encode64(token, padding: false),
      %UserToken{
        user_id: user.id,
        token: hashed_token
      }
    }
  end
end
