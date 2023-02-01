defmodule TicTacToe.Game.Server do
  use GenServer, restart: :temporary
  alias TicTacToe.Game.Match

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  defp via_tuple(id) do
    TicTacToe.Registry.via_tuple({__MODULE__, id})
  end

  def move(id, player_id, square) do
    GenServer.call(via_tuple(id), {:move, %{player: player_id, square: square}})
  end

  def join(id, player_id) do
    GenServer.call(via_tuple(id), {:join, %{player: player_id}})
  end

  def leave(id, player_id) do
    GenServer.call(via_tuple(id), {:leave, %{player: player_id}})
  end

  def is_open?(id) do
    GenServer.call(via_tuple(id), {:is_open})
  end

  def id(pid) do
    case TicTacToe.Registry.keys(pid) do
      [{_, id} | _] -> id
      _ -> nil
    end
  end

  @impl true
  def init(id) do
    {:ok, Match.new(id)}
  end

  @impl true
  def handle_call({:move, %{square: square, player: player}}, _, match) do
    match = Match.move(match, square, match.players[player])
    {:reply, match.status, match}
  end

  @impl true
  def handle_call({:join, %{player: player}}, _, match) do
    match = Match.join(match, player)
    {:reply, match.status, match}
  end

  @impl true
  def handle_call({:leave, %{player: player}}, _, match) do
    match = Match.leave(match, player)
    {:reply, match.status, match}
  end

  @impl true
  def handle_call({:is_open}, _, match) do
    {:reply, Match.is_open?(match), match}
  end
end
