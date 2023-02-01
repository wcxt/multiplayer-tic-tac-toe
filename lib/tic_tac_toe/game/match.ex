defmodule TicTacToe.Game.Match do
  alias Phoenix.PubSub

  @symbols [:X, :O]

  defstruct status: :waiting,
            board: nil,
            turn: nil,
            players: %{},
            id: nil

  def new(id), do: %__MODULE__{board: Map.from_keys(Enum.to_list(0..8), nil), id: id}

  def is_open?(match), do: Enum.count(match.players) != 2

  def move(%__MODULE__{turn: turn} = match, _pos, symbol) when symbol != turn, do: match
  def move(match, pos, _symbol), do: do_move(match, pos)

  defp do_move(match, pos) do
    update(%__MODULE__{
      match
      | board: Map.put(match.board, pos, match.turn),
        turn: opposite_symbol(match.turn)
    })
  end

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
    broadcast(match.id, {:start})

    %__MODULE__{
      match
      | board: Map.from_keys(Enum.to_list(0..8), nil),
        turn: Enum.random(@symbols),
        status: :playing
    }
  end

  defp stop(match) do
    broadcast(match.id, {:done})

    %__MODULE__{
      match
      | status: :done
    }
  end

  defp remove_player(match, player) do
    %__MODULE__{
      match
      | players: Map.delete(match, player)
    }
  end

  defp available_symbols(match) do
    @symbols -- Map.keys(match.players)
  end

  defp opposite_symbol(:X), do: :O
  defp opposite_symbol(:O), do: :X

  defp broadcast(id, message), do: PubSub.broadcast(TicTacToe.PubSub, "room:#{id}", message)

  defp update(match) do
    broadcast(match.id, {:update, %{board: match.board}})
    match
  end
end
