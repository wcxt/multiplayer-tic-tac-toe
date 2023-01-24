defmodule TicTacToe.Game.Server do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub

  defstruct board: nil,
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
    {:ok, %__MODULE__{board: Map.from_keys(Enum.to_list(0..8), nil)}}
  end

  @impl true
  def handle_call({:move, %{id: id, player_id: player_id}}, _, state) do
    case state.turn do
      ^player_id ->
        board = Map.replace(state.board, id, :X)
        new_turn = Enum.find_value(state.players, nil, fn x -> if x != state.turn, do: x end)
        broadcast({:update, board})

        {:reply, board,
         %__MODULE__{
           state
           | board: board,
             turn: new_turn
         }}

      _ ->
        {:reply, state.board, state}
    end
  end

  @impl true
  def handle_call({:join, %{id: id}}, _, state) do
    players = [id | state.players]

    case length(players) do
      2 ->
        broadcast({:ready, nil})
        new_state = Map.put(state, :players, players)
        {:reply, players, start_game(new_state)}

      _ ->
        {:reply, players, %__MODULE__{state | players: players}}
    end
  end

  @impl true
  def handle_call({:disconnect, %{id: id}}, _, state) do
    players = List.delete(state.players, id)
    new_state = Map.put(state, :players, players)
    broadcast({:stop, nil})

    {:reply, players, reset_game(new_state)}
  end

  defp broadcast(message) do
    PubSub.broadcast(TicTacToe.PubSub, "room:1", message)
  end

  defp reset_game(state) do
    board = Map.from_keys(Enum.to_list(0..8), nil)
    %__MODULE__{state | turn: nil, is_ready: false, board: board}
  end

  defp start_game(state) do
    %__MODULE__{state | turn: Enum.random(state.players), is_ready: true}
  end
end
