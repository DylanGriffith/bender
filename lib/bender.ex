defmodule Bender do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    home_server = Application.get_env(:bender, :matrix_home_server)
    user = Application.get_env(:bender, :matrix_user)
    password = Application.get_env(:bender, :matrix_password)
    room_names = Application.get_env(:bender, :room_names)
    commands = Application.get_env(:bender, :commands)

    children = [
      worker(Bender.Bot, [%Matrix.Config{home_server: home_server, user: user, password: password}, room_names, commands]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bender.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
