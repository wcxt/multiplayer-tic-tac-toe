defmodule TicTacToe.Game.Match do
  alias Phoenix.PubSub

  @symbols [:X, :O]

  defstruct status: :waiting,
            board: nil,
            turn: nil,
            players: %{},
            winner: nil,
            id: nil

  def new(id), do: %__MODULE__{board: Map.from_keys(Enum.to_list(0..8), nil), id: id}

  def is_open?(match), do: Enum.count(match.players) != 2

  def move(match, pos, symbol) do
    with {:ok, _} <- check_turn(match, symbol),
         {:ok, _} <- check_placement(match, pos) do
      match
      |> place_symbol(pos)
      |> maybe_choose_draw()
      |> maybe_choose_winner()
      |> maybe_end_game()
      |> change_turn()
      |> update()
    else
      _ -> match
    end
  end

  defp check_turn(%__MODULE__{turn: turn}, symbol) when symbol != turn,
    do: {:error, "Incorrect turn"}

  defp check_turn(match, _), do: {:ok, match}

  defp check_placement(match, pos) do
    case match.board[pos] do
      nil -> {:ok, match}
      _ -> {:error, "Already placed"}
    end
  end

  defp place_symbol(match, pos) do
    %__MODULE__{
      match
      | board: Map.put(match.board, pos, match.turn)
    }
  end

  defp change_turn(match) do
    %__MODULE__{
      match
      | turn: opposite_symbol(match.turn)
    }
  end

  defp maybe_choose_winner(%__MODULE__{turn: turn} = match) do
    case match.board do
      %{0 => ^turn, 1 => ^turn, 2 => ^turn} -> make_winner(match, turn)
      %{3 => ^turn, 4 => ^turn, 5 => ^turn} -> make_winner(match, turn)
      %{6 => ^turn, 7 => ^turn, 8 => ^turn} -> make_winner(match, turn)
      %{0 => ^turn, 3 => ^turn, 6 => ^turn} -> make_winner(match, turn)
      %{1 => ^turn, 4 => ^turn, 7 => ^turn} -> make_winner(match, turn)
      %{2 => ^turn, 5 => ^turn, 8 => ^turn} -> make_winner(match, turn)
      %{0 => ^turn, 4 => ^turn, 8 => ^turn} -> make_winner(match, turn)
      %{2 => ^turn, 4 => ^turn, 6 => ^turn} -> make_winner(match, turn)
      _ -> match
    end
  end

  defp maybe_choose_draw(match) do
    case Enum.all?(Map.values(match.board), &(&1 != nil)) do
      true -> %__MODULE__{match | winner: :draw}
      false -> match
    end
  end

  defp make_winner(match, symbol) do
    [id] = for {id, ^symbol} <- match.players, do: id
    %__MODULE__{match | winner: id}
  end

  defp maybe_end_game(%__MODULE__{winner: winner} = match) when winner != nil, do: stop(match)
  defp maybe_end_game(match), do: match

  def join(match, player) do
    match
    |> add_player(player)
    |> maybe_start()
  end

  def leave(match, player) do
    match
    |> remove_player(player)
    |> stop()
  end

  defp add_player(match, player) do
    %__MODULE__{
      match
      | players: Map.put(match.players, player, Enum.random(available_symbols(match)))
    }
  end

  defp maybe_start(match) do
    case Enum.count(match.players) do
      2 -> start(match)
      _ -> match
    end
  end

  defp start(match) do
    update(%__MODULE__{
      match
      | board: Map.from_keys(Enum.to_list(0..8), nil),
        turn: Enum.random(@symbols),
        status: :playing
    })
  end

  defp stop(match) do
    update(%__MODULE__{
      match
      | status: :done
    })
  end

  defp remove_player(match, player) do
    %__MODULE__{
      match
      | players: Map.delete(match, player)
    }
  end

  defp available_symbols(match) do
    @symbols -- Map.values(match.players)
  end

  defp opposite_symbol(:X), do: :O
  defp opposite_symbol(:O), do: :X

  defp broadcast(id, message), do: PubSub.broadcast(TicTacToe.PubSub, "room:#{id}", message)

  defp update(match) do
    broadcast(
      match.id,
      {:update,
       %{
         id: match.id,
         board: match.board,
         turn: match.turn,
         players: match.players,
         status: match.status,
         winner: match.winner
       }}
    )

    match
  end
end
