defmodule Bender.Bot do
  use GenServer

  require Logger

  def start_link(config = %Matrix.Config{}, room_names, commands, event_reactions) do
    GenServer.start_link(__MODULE__, [config, room_names, commands, event_reactions],
      name: __MODULE__
    )
  end

  def init([config = %Matrix.Config{}, room_names, commands, event_reactions]) do
    event_manager = setup_event_manager(commands, event_reactions)

    # Login
    session = Matrix.Client.login!(config)

    Logger.debug(fn -> "Login Result (Session): #{inspect(session)}" end)

    # Join Rooms
    rooms =
      Enum.map(room_names, fn room_name ->
        Matrix.Client.join!(session, room_name)
      end)

    Logger.debug(fn -> "Rooms: #{inspect(rooms)}" end)

    # Trigger first poll for events
    GenServer.cast(self(), :poll_matrix)

    {:ok,
     %{
       session: session,
       rooms: rooms,
       event_manager: event_manager,
       from: nil,
       commands: commands,
       event_reactions: event_reactions
     }}
  end

  # this call primarily exists to allow an optional eval command to modify the
  # bot during runtime
  def handle_call({:set_state, new_state}, _from, state),
    do: {:reply, {state, new_state}, new_state}

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_cast(
        :poll_matrix,
        state = %{session: session = %Matrix.Session{}, event_manager: event_manager, from: from}
      ) do
    # Get latest events
    events = Matrix.Client.events!(session, from)

    state = Map.put(state, :from, events.endd)

    Logger.debug(fn -> "Matrix Events: #{inspect(events)}" end)

    # Dispatch events
    Enum.each(events.events, fn event ->
      GenEvent.notify(
        event_manager,
        {:matrix_event, {session, event}}
      )
    end)

    # Extract commands
    command_events =
      events.events
      |> Enum.reject(fn e -> e.user && e.user.user_id == session.user_id end)
      |> Enum.filter(fn e -> e.type == "m.room.message" end)
      |> Enum.filter(fn e -> e.content.msg_type == "m.text" end)
      |> Enum.map(fn e -> {Bender.Parser.try_parse(e.content.body), e} end)
      |> Enum.filter(fn {c, _e} -> !is_nil(c) end)

    # Dispatch commands
    Enum.each(command_events, fn {command, event} ->
      GenEvent.notify(
        event_manager,
        {command, %{session: session, room: event.room, author: event.user}}
      )
    end)

    # Poll again for events
    GenServer.cast(self(), :poll_matrix)

    {:noreply, state}
  end

  def handle_info(
        {:gen_event_EXIT, _, _},
        state = %{commands: commands, event_reactions: event_reactions}
      ) do
    state = Map.put(state, :event_manager, setup_event_manager(commands, event_reactions))
    {:noreply, state}
  end

  def setup_event_manager(commands, event_reactions) do
    # Start the GenEvent manager
    {:ok, event_manager} = GenEvent.start_link()

    Process.monitor(event_manager)

    Enum.each(commands, fn c ->
      :ok = GenEvent.add_mon_handler(event_manager, c, self())
    end)

    Enum.each(event_reactions, fn er ->
      :ok = GenEvent.add_mon_handler(event_manager, er, self())
    end)

    event_manager
  end
end
