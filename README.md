# Deprecated

As I no longer use Matrix personally I'm not maintaining this tool anymore. I am aware of at least one fork that is maintained a bit more recently than this but I cannot endorse it as I do not use it https://github.com/lytedev/bender

# Bender

This project attempts to create a simple/flexible bot framework using the best
of Elixir/Erlang/OTP. For now it only supports the [Matrix messaging
protocol](http://matrix.org/), however it would be reasonably straightforward
to introduce some kind of adapter pattern or something to support other chat
services and would happily take PRs for something like that. The recommended
use for this framework is to create your own mix project and bring this in as a
dependency. You can define your own commands or just use the packaged ones and
you configure that in your project.

## Commands
Commands are a way of perfoming an action when someone uses the magic keyword.
The command prefix must be configured, but lets assume it is `"bender"`. An
example command (that comes packaged with this project) is the `echo` command.

The implementation is very simple:

```elixir
defmodule Bender.Commands.Echo do
  use Bender.Command

  @usage "echo <message>"
  @short_description "responds with <message>"

  def handle_event({{:command, "echo", message}, meta}, state) do
    respond(message, meta)
    {:ok, state}
  end
end
```

This framework uses GenEvent for dispatching the commands. You can use all the
deliciousness of pattern matching to match the commands you are interested in.

The important part of the pattern match is `{:command, "echo", message}`. In
the case that someone says `bender echo hello world` these will come through
like `{:command, "echo", "hello world"}`. The other parts of the pattern match
are just metadata/session data. You can use `meta[:author].user_id` if you want
to know who sent the message.

The module attributes `@usage` and `@short_description` will be included in the
output of `bender help` if they are defined.

The commands that your bot actually runs must be configured and you can mix and
match between packaged commands and any commands you define.

## Config
The config setup for this project is as follows:

```elixir
config :bender,
  command_prefix: "bender",
  matrix_home_server: "matrix.org",
  matrix_user: "bender",
  matrix_password: "bender",
  commands: [Bender.Commands.Echo, Bender.Commands.Ping],
  room_names: ["#bender:matrix.org"]
```

You must set all of these when you include this dependency in your project,
however you can easily run this project as is and the above credentials will
log you into matrix.org and you can play around with your bot.


## Installation

The package can be installed as:

  1. Add bender to your list of dependencies in `mix.exs`:

        def deps do
          [{:bender, git: "https://github.com/DylanGriffith/bender.git"}]
        end

  2. Ensure bender is started before your application:

        def application do
          [applications: [:bender]]
        end
