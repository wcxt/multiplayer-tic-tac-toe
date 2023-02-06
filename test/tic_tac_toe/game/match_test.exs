defmodule TicTacToe.Game.MatchTest do
  use ExUnit.Case
  alias TicTacToe.Game.Match

  describe "Match.new/1" do
    test "returns new match with given id and empty board" do
      empty = Map.from_keys(Enum.to_list(0..8), nil)
      new = Match.new(1)

      assert %Match{id: 1, board: ^empty} = new
    end
  end

  describe "Match.join/2" do
    test "returns new match with new players map" do
      new = Match.new(1)
      new = Match.join(new, 1)

      assert %Match{players: %{1 => _symbol}} = new
    end

    test "returns playing match when there are already 1 player in players map" do
      new =
        Match.new(1)
        |> Match.join(1)
        |> Match.join(2)

      assert %Match{status: :playing} = new
    end
  end

  describe "Match.leave/2" do
    test "returns done match when 2 players joined the game" do
      new =
        Match.new(1)
        |> Match.join(1)
        |> Match.join(2)
        |> Match.leave(1)

      assert %Match{status: :done} = new
    end
  end

  describe "Match.is_open?/1" do
    test "returns false when 2 players joined" do
      new =
        Match.new(1)
        |> Match.join(1)
        |> Match.join(2)

      assert false == Match.is_open?(new)
    end
  end
end
