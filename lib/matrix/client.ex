defmodule Matrix.Client do
  defp base_url(
         %Matrix.Config{home_server_protocol: protocol, home_server: host, home_server_port: port} =
           config
       ) do
    "#{protocol}://#{host}:#{port}/_matrix"
  end

  defp base_url(%Matrix.Session{} = session) do
    "https://#{session.home_server}/_matrix"
  end

  def login!(
        %Matrix.Config{
          home_server: home_server,
          user: user,
          password: password,
          home_server_protocol: home_server_protocol,
          home_server_port: home_server_port
        } = config
      ) do
    data = %{user: user, password: password, type: "m.login.password"}

    response =
      HTTPoison.post!(
        "#{base_url(config)}/client/api/v1/login",
        Poison.encode!(data),
        [],
        timeout: 10_000
      )

        Poison.decode!(response.body, as: %Matrix.Session{})
        |> IO.inspect()
        |> Map.put(:home_server, "#{home_server_protocol}://#{home_server}:#{home_server_port}"
  end

  def leave!(session, room_name) do
    room_response =
      HTTPoison.post!(
        "#{session}/client/api/v1/leave/#{room_name}?access_token=#{session.access_token}",
        "",
        [],
        timeout: 10_000
      )
  end

  def join!(session, room_name) do
    room_response =
      HTTPoison.post!(
        "#{base_url(session)}/client/api/v1/join/#{room_name}?access_token=#{session.access_token}",
        "",
        [],
        timeout: 10_000
      )

    Poison.decode!(room_response.body, as: %Matrix.Room{})
  end

  def events!(session, from \\ nil) do
    params = [timeout: 30000, access_token: session.access_token]

    params =
      if from do
        Keyword.put(params, :from, from)
      else
        params
      end

    response =
      HTTPoison.get!(
        "#{base_url(session)}/client/api/v1/events",
        [Accept: "application/json"],
        params: params,
        recv_timeout: 40000,
        timeout: 10_000
      )

    response.body
    |> Poison.decode!()
    |> Matrix.ResponseConstructor.events()
  end

  def post!(
        session = %Matrix.Session{},
        room = %Matrix.Room{},
        message,
        msg_type \\ "m.text",
        event_type \\ "m.room.message",
        extra_fields \\ %{}
      ) do
    data = Map.merge(%{msgtype: msg_type, body: message}, extra_fields)

    response =
      HTTPoison.post!(
        "#{base_url(session)}/client/api/v1/rooms/#{room.room_id}/send/#{event_type}?access_token=#{
          session.access_token
        }",
        Poison.encode!(data)
      )

    Poison.decode!(response.body, as: %Matrix.EventId{})
  end
end
