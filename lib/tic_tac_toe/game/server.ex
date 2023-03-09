defmodule TicTacToe.Game.Server do
  use GenServer, restart: :temporary
  alias TicTacToe.Game.Match

  def start_link(opts) do
    id = Keyword.fetch!(opts, :id)

    GenServer.start_link(__MODULE__, opts, name: via_tuple(id))
  end

  defp via_tuple(id) do
    TicTacToe.Registry.via_tuple({__MODULE__, id})
  end

  def move(id, player_id, square) do
    GenServer.call(via_tuple(id), {:move, %{player: player_id, square: square}})
  end

  def join(id, player) do
    GenServer.call(via_tuple(id), {:join, %{player: player}})
  end

  def leave(id, player) do
    GenServer.call(via_tuple(id), {:leave, %{player: player}})
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
  def init(opts) do
    {:ok, Match.new(opts)}
  end

  @impl true
  def handle_call({:move, %{square: square, player: player}}, _, match) do
    {:reply, :ok, Match.move(match, square, player)}
  end

  @impl true
  def handle_call({:join, %{player: player}}, _, match) do
    {:reply, :ok, Match.join(match, player)}
  end

  @impl true
  def handle_call({:leave, %{player: player}}, _, match) do
    match = Match.leave(match, player)

    case match.status do
      :done -> {:reply, :ok, match}
      :kill -> {:stop, :normal, :ok, match}
    end
  end

  @impl true
  def handle_call({:is_open}, _, match) do
    {:reply, Match.is_open?(match), match}
  end

  @impl true
  def handle_info(:turn_timeout, match) do
    {:noreply, Match.change_turn(match)}
  end
end
