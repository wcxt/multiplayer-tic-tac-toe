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

    test "returns match with changed players map when players joined" do
      new =
        Match.new(1)
        |> Match.join(1)
        |> Match.join(2)
        |> Match.leave(1)

      assert Enum.count(new.players) == 1
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

  describe "Match.move/3" do
    setup do
      match =
        Match.new(1)
        |> Match.join(1)
        |> Match.join(2)

      {:ok, %{match: match}}
    end

    test "returns match with changed board", %{match: new} do
      expected_symbol = new.turn
      assert %Match{board: %{0 => ^expected_symbol}} = Match.move(new, 0, new.turn)
    end

    test "return unchanged board when the pos isn't nil", %{match: new} do
      expected_symbol = new.turn
      new = Match.move(new, 0, new.turn)

      assert %Match{board: %{0 => ^expected_symbol}} = Match.move(new, 0, new.turn)
    end

    test "returns match with changed turn", %{match: new} do
      expected_turn = new.turn
      new = Match.move(new, 0, new.turn)

      assert %Match{turn: ^expected_turn} = Match.move(new, 1, new.turn)
    end

    test "stops game when board winning pattern is detected", %{match: new} do
      opposite_symbol = if new.turn == :X, do: :O, else: :X

      new =
        new
        |> Match.move(0, new.turn)
        |> Match.move(3, opposite_symbol)
        |> Match.move(1, new.turn)
        |> Match.move(4, opposite_symbol)
        |> Match.move(2, new.turn)

      assert %Match{status: :done} = new
    end
  end
end
