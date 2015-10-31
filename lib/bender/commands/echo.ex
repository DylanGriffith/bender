defmodule Bender.Commands.Echo do
  use Bender.Command

  def handle_event({{:command, "echo", message}, meta}, parent) do
    respond(message, meta)
    {:ok, parent}
  end
end
