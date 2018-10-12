defmodule Bender do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    home_server = Application.get_env(:bender, :matrix_home_server)
    user = Application.get_env(:bender, :matrix_user)
    password = Application.get_env(:bender, :matrix_password)
    room_names = Application.get_env(:bender, :room_names)
    commands = Application.get_env(:bender, :commands)

    children = [
      worker(Bender.Bot, [
        %Matrix.Config{home_server: home_server, user: user, password: password},
        room_names,
        commands
      ])
    ]

    opts = [strategy: :one_for_one, name: Bender.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
