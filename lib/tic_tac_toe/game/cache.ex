defmodule TicTacToe.Game.Cache do
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, name: __MODULE__)
  end

  def child_spec(_) do
    DynamicSupervisor.child_spec(name: __MODULE__)
  end

  def get(room_id) do
    case DynamicSupervisor.start_child(__MODULE__, {TicTacToe.Game.Server, room_id}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
