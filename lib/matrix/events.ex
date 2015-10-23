defmodule Matrix.Events do
  @derive [Poison.Encoder]
  defstruct [:events, :start, :endd]
end
