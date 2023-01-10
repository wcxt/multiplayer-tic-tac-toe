defmodule TicTacToe.Game.Server do
  use GenServer, restart: :temporary
  alias Phoenix.PubSub

  def start_link(room_id) do
    GenServer.start_link(__MODULE__, room_id, name: via_tuple(room_id))
  end

  def via_tuple(room_id) do
    TicTacToe.Registry.via_tuple({__MODULE__, room_id})
  end

  @impl true
  def init(_room_id) do
    PubSub.subscribe(TicTacToe.PubSub, "room:1")
    {:ok, Map.from_keys(Enum.to_list(0..8), nil)}
  end

  @impl true
  def handle_info({"move", id}, game) do
    {:noreply, Map.replace(game, id, :X)}
  end
end
