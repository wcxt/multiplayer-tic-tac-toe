defmodule TicTacToe.Game.ServerTest do
  alias TicTacToe.Game.Server
  use ExUnit.Case

  @id 1

  setup do
    start_supervised({TicTacToe.Registry, nil})

    case start_supervised({Server, @id}) do
      {:ok, pid} -> {:ok, %{server: pid}}
      _ -> :error
    end
  end

  describe "join/2" do
    test "returns :ok response" do
      assert :ok = Server.join(@id, 1)
    end
  end

  describe "move/3" do
    test "returns :ok response" do
      Server.join(@id, 1)
      Server.join(@id, 2)
      assert :ok = Server.move(@id, 1, 0)
    end
  end

  describe "leave/2" do
    test "returns :ok response when 1 player remains" do
      Server.join(@id, 1)
      Server.join(@id, 2)
      assert :ok = Server.leave(@id, 1)
    end

    test "terminates itself when 0 players remains", %{server: pid} do
      Server.join(@id, 1)
      Server.join(@id, 2)
      Server.leave(@id, 1)
      Server.leave(@id, 2)
      assert Process.alive?(pid) == false
    end
  end

  describe "id/1" do
    test "returns correct id for process with given pid", %{server: pid} do
      assert Server.id(pid) == @id
    end

    test "returns nil for non server process" do
      assert Server.id(self()) == nil
    end
  end

  describe "is_open?/1" do
    test "returns true when there is less than 2 players" do
      assert Server.is_open?(@id) == true
    end

    test "returns false when there is 2 players" do
      Server.join(@id, 1)
      Server.join(@id, 2)
      assert Server.is_open?(@id) == false
    end
  end
end
