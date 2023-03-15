defmodule TicTacToe.Game.Lobby do
  alias TicTacToe.Game.Supervisor
  alias TicTacToe.Game.Server

  def create_server() do
    case Supervisor.start_child(id: generate_room_id(6)) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def generate_room_id(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  # FIXME: Inefficient use of selecting game servers
  def find_or_create_server() do
    # Selects every game server pid and id from registry -> [{pid, id}]
    TicTacToe.Registry.select([{{{Server, :"$1"}, :"$2", :_}, [], [:"$1"]}])
    |> find_free_server()
    |> maybe_start_new_server()
  end

  defp find_free_server(games) do
    Enum.find(games, nil, fn id -> Server.is_open?(id) end)
  end

  # handle starting new server error
  defp maybe_start_new_server(nil), do: Server.id(create_server())
  defp maybe_start_new_server(id), do: id
end
