defmodule Bender.Commands.Echo do
  use Bender.Command

  @usage "echo <message>"
  @short_description "responds with <message>"

  def handle_event({{:command, "echo", message}, meta}, parent) do
    respond(message, meta)
    {:ok, parent}
  end
end
