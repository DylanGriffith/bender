defmodule Bender.Commands.Echo do
  use GenEvent

  def handle_event({{:command, "echo", message}, {session = %Matrix.Session{}, room = %Matrix.Room{}, author = %Matrix.User{}}}, parent) do
    Matrix.Client.post!(session, room, message)
    {:ok, parent}
  end
end
