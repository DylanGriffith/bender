defmodule Bender do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    home_server = Application.get_env(:bender, :matrix_home_server)
    home_server_protocol = Application.get_env(:bender, :matrix_home_server_protocol, "https")
    user = Application.get_env(:bender, :matrix_user)
    password = Application.get_env(:bender, :matrix_password)
    room_names = Application.get_env(:bender, :room_names)
    commands = Application.get_env(:bender, :commands)
    event_reactions = Application.get_env(:bender, :event_reactions)

    children = [
      worker(Bender.Bot, [
        %Matrix.Config{
          home_server: home_server,
          user: user,
          password: password,
          home_server_protocol: home_server_protocol
        },
        room_names,
        commands,
        event_reactions
      ])
    ]

    opts = [strategy: :one_for_one, name: Bender.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
