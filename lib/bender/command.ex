defmodule Bender.Command do
  defmacro __using__(_opts) do
    quote do
      use GenEvent
    end
  end
end
