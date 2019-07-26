defmodule Matrix.ResponseConstructor do
  def events(response) do
    %Matrix.Events{
      events: response["chunk"] |> Enum.map(&event/1),
      start: response["start"],
      endd: response["end"]
    }
  end

  def event(response) do
    %Matrix.Event{
      event_id: response["event_id"],
      age: response["age"],
      content: content(response["type"], response["content"]),
      room: room(response["room_id"]),
      type: response["type"],
      origin_server_ts: response["origin_server_ts"],
      user: user(response["user_id"]),
      original_response: response
    }
  end

  def content("m.typing", response) do
    %Matrix.Content{
      users: Enum.map(response["user_ids"], &user/1),
      original_response: response
    }
  end

  def content("m.room.message", response) do
    %Matrix.Content{
      body: response["body"],
      msg_type: response["msgtype"],
      original_response: response
    }
  end

  def content(_type, response) do
    %Matrix.Content{
      original_response: response
    }
  end

  def user(nil) do
    nil
  end

  def user(user_id) do
    %Matrix.User{user_id: user_id}
  end

  def room(room_id) do
    %Matrix.Room{room_id: room_id}
  end
end
