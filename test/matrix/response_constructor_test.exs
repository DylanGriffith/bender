defmodule Matrix.ResponseConstructorTest do
  use ExUnit.Case, async: true

  test "#events: transforms typing events in Matrix.Events" do
    input = %{
      "chunk" => [
        %{
          "content" => %{"user_ids" => ["@bob:matrix.org"]},
          "room_id" => "!abc123:matrix.org",
          "type" => "m.typing"
        }
      ],
      "end" => "s12345",
      "start" => "s12344"
    }

    output = %Matrix.Events{
      events: [
        %Matrix.Event{
          content: %Matrix.Content{
            users: [
              %Matrix.User{user_id: "@bob:matrix.org"}
            ],
            original_response: input |> Map.get("chunk") |> Enum.at(0) |> Map.get("content")
          },
          original_response: input["chunk"] |> Enum.at(0),
          room: %Matrix.Room{room_id: "!abc123:matrix.org"},
          type: "m.typing"
        }
      ],
      endd: "s12345",
      start: "s12344"
    }

    assert Matrix.ResponseConstructor.events(input) == output
  end

  test "transforms message events in Matrix.Events" do
    input = %{
      "chunk" => [
        %{
          "age" => 136,
          "content" => %{"body" => "bender echo hello", "msgtype" => "m.text"},
          "event_id" => "$1446024043133ABC:matrix.org",
          "origin_server_ts" => 1_446_024_043_133,
          "room_id" => "!abc123:matrix.org",
          "type" => "m.room.message",
          "user_id" => "@bob:matrix.org"
        }
      ],
      "end" => "s12345",
      "start" => "s12344"
    }

    output = %Matrix.Events{
      events: [
        %Matrix.Event{
          event_id: "$1446024043133ABC:matrix.org",
          age: 136,
          original_response: input |> Map.get("chunk") |> Enum.at(0),
          content: %Matrix.Content{
            body: "bender echo hello",
            original_response: input |> Map.get("chunk") |> Enum.at(0) |> Map.get("content"),
            msg_type: "m.text"
          },
          origin_server_ts: 1_446_024_043_133,
          room: %Matrix.Room{room_id: "!abc123:matrix.org"},
          type: "m.room.message",
          user: %Matrix.User{user_id: "@bob:matrix.org"}
        }
      ],
      endd: "s12345",
      start: "s12344"
    }

    assert Matrix.ResponseConstructor.events(input) == output
  end
end
