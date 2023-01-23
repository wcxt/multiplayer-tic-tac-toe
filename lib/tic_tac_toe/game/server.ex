defmodule TicTacToe.Game.Server do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub

  defstruct game: nil,
            players: [],
            turn: nil,
            is_ready: false

  def start_link(room_id) do
    GenServer.start_link(__MODULE__, nil, name: via_tuple(room_id))
  end

  defp via_tuple(room_id) do
    TicTacToe.Registry.via_tuple({__MODULE__, room_id})
  end

  def move(room_id, player_id, id) do
    GenServer.call(via_tuple(room_id), {:move, %{player_id: player_id, id: id}})
  end

  def join(room_id, id) do
    GenServer.call(via_tuple(room_id), {:join, %{id: id}})
  end

  def disconnect(room_id, id) do
    GenServer.call(via_tuple(room_id), {:disconnect, %{id: id}})
  end

  @impl true
  def init(_) do
    {:ok, %__MODULE__{game: Map.from_keys(Enum.to_list(0..8), nil)}}
  end

  @impl true
  def handle_call({:move, %{id: id, player_id: player_id}}, _, state) do
    case state.turn do
      ^player_id ->
        game = Map.replace(state.game, id, :X)
        new_turn = Enum.find_value(state.players, nil, fn x -> if x != state.turn, do: x end)
        PubSub.broadcast(TicTacToe.PubSub, "room:1", {:update, game})

        {:reply, game,
         %__MODULE__{
           state
           | game: game,
             turn: new_turn
         }}

      _ ->
        {:reply, state.game, state}
    end
  end

  @impl true
  def handle_call({:join, %{id: id}}, _, state) do
    players = [id | state.players]

    case length(players) do
      2 ->
        turn = Enum.random(players)
        PubSub.broadcast(TicTacToe.PubSub, "room:1", {:ready, turn})

        {:reply, players,
         %__MODULE__{
           state
           | players: players,
             turn: Enum.random(players),
             is_ready: true
         }}

      _ ->
        {:reply, players, %__MODULE__{state | players: players}}
    end
  end

  @impl true
  def handle_call({:disconnect, %{id: id}}, _, state) do
    players = List.delete(state.players, id)
    {:reply, players, %__MODULE__{state | players: players}}
  end
end
