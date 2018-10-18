defmodule Matrix.Event do
  defstruct [:event_id, :age, :user, :room, :type, :content, :origin_server_ts, :original_response]
end
