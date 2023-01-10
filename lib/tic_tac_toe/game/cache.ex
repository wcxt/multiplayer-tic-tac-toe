defmodule TicTacToe.Game.Cache do
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, strategy: :one_for_one, name: __MODULE__)
  end

  def child_spec(_) do
    DynamicSupervisor.child_spec(name: __MODULE__)
  end

  def join(room_id) do
    case start_child(room_id) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def start_child(room_id) do
    DynamicSupervisor.start_child(__MODULE__, {TicTacToe.Game.Server, room_id})
  end
end
