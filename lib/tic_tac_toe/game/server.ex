defmodule TicTacToe.Game.Server do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub

  @possible_letters [:X, :O]

  defstruct board: nil,
            players: %{},
            turn: nil,
            is_ready: false,
            id: nil

  def start_link(room_id) do
    GenServer.start_link(__MODULE__, room_id, name: via_tuple(room_id))
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

  def is_open?(room_id) do
    GenServer.call(via_tuple(room_id), {:is_open})
  end

  @impl true
  def init(room_id) do
    {:ok, %__MODULE__{board: Map.from_keys(Enum.to_list(0..8), nil), id: room_id}}
  end

  @impl true
  def handle_call({:move, %{square: square, id: id}}, _, state) do
    case current_turn?(state, id) do
      true ->
        board = Map.replace(state.board, square, state.players[id])
        broadcast(state.id, {:update, board})
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
        broadcast(state.id, {:ready, nil})
        new_state = Map.put(state, :players, players)
        {:reply, state.id, start_game(new_state)}

      _ ->
        {:reply, state.id, %__MODULE__{state | players: players}}
    end
  end

  @impl true
  def handle_call({:disconnect, %{id: id}}, _, state) do
    players = Map.delete(state.players, id)
    new_state = Map.put(state, :players, players)
    broadcast(state.id, {:stop, nil})

    {:reply, state.id, reset_game(new_state)}
  end

  @impl true
  def handle_call({:is_open}, _, state) do
    case Enum.count(state.players) do
      2 -> {:reply, false, state}
      _ -> {:reply, true, state}
    end
  end

  defp broadcast(id, message) do
    PubSub.broadcast(TicTacToe.PubSub, "room:#{id}", message)
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
