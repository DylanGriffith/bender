defmodule Bender.Commands.Echo do
  use Bender.Command

  @usage "echo <message>"
  @short_description "responds with <message>"

  def handle_event({{:command, "echo", message}, meta}, state) do
    respond(message, meta)
    {:ok, state}
  end
end
