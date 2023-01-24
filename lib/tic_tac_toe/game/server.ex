defmodule TicTacToe.Game.Server do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub

  @possible_letters [:X, :O]

  defstruct board: nil,
            players: %{},
            turn: nil,
            is_ready: false

  def start_link(room_id) do
    GenServer.start_link(__MODULE__, nil, name: via_tuple(room_id))
  end

  defp via_tuple(room_id) do
    TicTacToe.Registry.via_tuple({__MODULE__, room_id})
  end

  def move(room_id, player_id, square) do
    GenServer.call(via_tuple(room_id), {:move, %{id: player_id, square: square}})
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
  def handle_call({:move, %{square: square, id: id}}, _, state) do
    case current_turn?(state, id) do
      true ->
        board = Map.replace(state.board, square, state.players[id])
        broadcast({:update, board})
        {:reply, board, make_move(state, board)}

      false ->
        {:reply, state.board, state}
    end
  end

  @impl true
  def handle_call({:join, %{id: id}}, _, state) do
    players = Map.put(state.players, id, get_available_letter(state))

    case Enum.count(players) do
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
    players = Map.delete(state.players, id)
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
    %__MODULE__{state | turn: Enum.random(@possible_letters), is_ready: true}
  end

  defp opposite_letter(:X), do: :O
  defp opposite_letter(:O), do: :X

  defp current_turn?(state, id) do
    state.turn == state.players[id]
  end

  defp make_move(state, board) do
    %__MODULE__{state | board: board, turn: opposite_letter(state.turn)}
  end

  defp get_available_letter(state) do
    Enum.random(@possible_letters -- Map.values(state.players))
  end
end
