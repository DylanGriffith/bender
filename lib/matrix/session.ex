defmodule Matrix.Session do
  @derive [Poison.Encoder]
  defstruct [:access_token, :home_server, :user_id, :home_server_protocol, :home_server_port]
end
