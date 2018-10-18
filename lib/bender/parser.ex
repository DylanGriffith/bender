defmodule Bender.Parser do
  require Logger

  def try_parse(message, command_prefix \\ Application.get_env(:bender, :command_prefix)) do
    match =
      Regex.named_captures(
        ~r/\s*@?#{command_prefix}:?\s*(?<command>[\w-]+)\s*(?<message>.*)/sim,
        message
      )

    Logger.debug(fn ->
      "Bender.Parser.try_parse() - Event ({msg, regex_match}): #{inspect({message, match}, pretty: true)}"
    end)

    if match && match["command"] do
      {:command, match["command"], match["message"]}
    else
      nil
    end
  end
end
