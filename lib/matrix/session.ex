defmodule Matrix.Session do
  @derive [Poison.Encoder]
  defstruct [:access_token, :home_server, :user_id]
end
