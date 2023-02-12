defmodule TicTacToe.Game.MatchTest do
  use ExUnit.Case
  alias TicTacToe.Game.Match

  @id 1
  @player1 1
  @player2 2

  describe "Match.new/1" do
    test "returns new match with given id and empty board" do
      empty = Map.from_keys(Enum.to_list(0..8), nil)
      new = Match.new(@id)

      assert %Match{id: @id, board: ^empty} = new
    end
  end

  describe "Match.join/2" do
    test "returns new match with new players map" do
      new = Match.new(@id)
      new = Match.join(new, @player1)

      assert %Match{players: %{@player1 => _symbol}} = new
    end

    test "returns playing match when second player joined" do
      new =
        Match.new(@id)
        |> Match.join(@player1)
        |> Match.join(@player2)

      assert %Match{status: :playing} = new
    end
  end

  describe "Match.leave/2" do
    test "returns done match when 2 players joined the game" do
      new =
        Match.new(@id)
        |> Match.join(@player1)
        |> Match.join(@player2)
        |> Match.leave(@player1)

      assert %Match{status: :done} = new
    end

    test "returns match with changed players map when players joined" do
      new =
        Match.new(@id)
        |> Match.join(@player1)
        |> Match.join(@player2)
        |> Match.leave(@player1)

      assert Enum.count(new.players) == 1
    end
  end

  describe "Match.is_open?/1" do
    test "returns false when 2 players joined" do
      new =
        Match.new(@id)
        |> Match.join(@player1)
        |> Match.join(@player2)

      assert false == Match.is_open?(new)
    end

    test "returns false when game ended" do
      new =
        Match.new(@id)
        |> Match.join(@player1)
        |> Match.join(@player2)

      opposite_symbol = if new.turn == :X, do: :O, else: :X

      new =
        new
        |> Match.move(0, new.turn)
        |> Match.move(3, opposite_symbol)
        |> Match.move(1, new.turn)
        |> Match.move(4, opposite_symbol)
        |> Match.move(2, new.turn)

      assert false == Match.is_open?(new)
    end

    test "returns true when game is waiting" do
      new = Match.new(@id)

      assert true == Match.is_open?(new)
    end
  end

  describe "Match.move/3" do
    setup do
      match =
        Match.new(@id)
        |> Match.join(@player1)
        |> Match.join(@player2)

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

    test "stops game when board is filled up", %{match: new} do
      opposite_symbol = if new.turn == :X, do: :O, else: :X

      new =
        new
        |> Match.move(0, new.turn)
        |> Match.move(1, opposite_symbol)
        |> Match.move(2, new.turn)
        |> Match.move(3, opposite_symbol)
        |> Match.move(4, new.turn)
        |> Match.move(5, opposite_symbol)
        |> Match.move(6, new.turn)
        |> Match.move(7, opposite_symbol)
        |> Match.move(8, new.turn)

      assert %Match{status: :done} = new
    end
  end
end
