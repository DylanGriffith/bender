defmodule Bender.Bot do
  use GenServer

  def start_link(config = %Matrix.Config{}, room_names, commands) do
    GenServer.start_link(__MODULE__, [config, room_names, commands], name: __MODULE__)
  end

  def init([config = %Matrix.Config{}, room_names, commands]) do
    # Start the GenEvent manager
    {:ok, event_manager} = GenEvent.start_link

    Enum.each commands, fn(c) ->
      :ok = GenEvent.add_mon_handler(event_manager, c, self)
    end

    # Login
    session = Matrix.Client.login!(config)

    # Join Rooms
    rooms = Enum.map room_names, fn(room_name) ->
      Matrix.Client.join!(session, room_name)
    end

    # Trigger first poll for events
    GenServer.cast(self, :poll_matrix)
    {:ok, %{session: session, rooms: rooms, event_manager: event_manager, from: nil}}
  end

  def handle_cast(:poll_matrix, state = %{session: session = %Matrix.Session{}, event_manager: event_manager, from: from}) do

    # Get latest events
    events = Matrix.Client.events!(session, from)

    state = Dict.put state, :from, events.endd

    # Extract commands
    command_events = (events.events
                      |> Enum.reject(fn (e) -> e.user && e.user.user_id == session.user_id end)
                      |> Enum.filter(fn (e) -> e.type == "m.room.message" end)
                      |> Enum.filter(fn (e) -> e.content.msg_type == "m.text" end)
                      |> Enum.map(fn (e) -> {Bender.Parser.try_parse(e.content.body), e} end)
                      |> Enum.filter(fn ({c, _e}) -> !is_nil(c) end))

    # Dispatch commands
    Enum.each command_events, fn ({command, event}) ->
      GenEvent.notify(event_manager, {command, {session, event.room, event.user}})
    end

    # Poll again for events
    GenServer.cast(self, :poll_matrix)

    {:noreply, state}
  end
end
