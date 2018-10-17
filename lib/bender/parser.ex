defmodule Bender.Parser do
  def try_parse(message, command_prefix \\ Application.get_env(:bender, :command_prefix)) do
    match =
      Regex.named_captures(
        ~r/\s*@?#{command_prefix}:?\s*(?<command>[\w-]+)\s*(?<message>.*)/sim,
        message
      )
      |> IO.inspect()

    if match && match["command"] do
      {:command, match["command"], match["message"]}
    else
      nil
    end
  end
end
