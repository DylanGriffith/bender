defmodule Bender.Commands.Ping do
  use Bender.Command

  @usage "ping"
  @short_description "responds with \"pong\""

  def handle_event({{:command, "ping", _message}, meta}, parent) do
    respond("pong", meta)
    {:ok, parent}
  end
end
