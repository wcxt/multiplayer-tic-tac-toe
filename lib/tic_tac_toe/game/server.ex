defmodule TicTacToe.Game.Server do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub

  def start_link(room_id) do
    GenServer.start_link(__MODULE__, room_id, name: via_tuple(room_id))
  end

  defp via_tuple(room_id) do
    TicTacToe.Registry.via_tuple({__MODULE__, room_id})
  end

  def move(room_id, id) do
    game = GenServer.call(via_tuple(room_id), {:move, %{id: id}})
    PubSub.broadcast(TicTacToe.PubSub, "room:1", {:update, game})
  end

  @impl true
  def init(room_id) do
    PubSub.subscribe(TicTacToe.PubSub, "room:#{room_id}")
    {:ok, Map.from_keys(Enum.to_list(0..8), nil)}
  end

  @impl true
  def handle_call({:move, %{id: id}}, _, game) do
    game = Map.replace(game, id, :X)
    {:reply, game, game}
  end
end
