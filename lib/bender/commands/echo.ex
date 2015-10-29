defmodule Bender.Commands.Echo do
  use GenEvent

  def handle_event({{:command, "echo", message}, {session = %Matrix.Session{}, room = %Matrix.Room{}, author = %Matrix.User{}}}, parent) do
    Matrix.Client.post!(session, room, message)
    {:ok, parent}
  end

  # Need to ignore everything else since by default it will crash if no
  # function clause matches
  def handle_event(_, parent) do
    {:ok, parent}
  end
end
