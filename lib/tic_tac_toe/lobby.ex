defmodule TicTacToe.Lobby do
  alias TicTacToe.Game.Server

  def enqueue(player) do
    # Selects every game server pid and id from registry -> [{pid, id}]
    games = TicTacToe.Registry.select([{{{Server, :"$1"}, :"$2", :_}, [], [{{:"$2", :"$1"}}]}])

    case Enum.find(games, nil, fn {_, id} -> Server.is_open?(id) end) do
      nil ->
        id = :rand.uniform()
        TicTacToe.Game.Cache.get(id)
        id

      {_, id} ->
        TicTacToe.Game.Cache.get(id)
        id
    end
  end
end
