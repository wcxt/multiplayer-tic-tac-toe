defmodule TicTacToe.MatchMaker do
  alias TicTacToe.Game.Server

  def get() do
    # Selects every game server pid and id from registry -> [{pid, id}]
    TicTacToe.Registry.select([{{{Server, :"$1"}, :"$2", :_}, [], [:"$1"]}])
    |> find()
    |> maybe_start_new_server()
  end

  defp find(games) do
    Enum.find(games, nil, fn id -> TicTacToe.Game.Server.is_open?(id) end)
  end

  # handle starting new server error
  defp maybe_start_new_server(nil), do: Server.id(TicTacToe.Game.Supervisor.start_child())
  defp maybe_start_new_server(id), do: id
end
