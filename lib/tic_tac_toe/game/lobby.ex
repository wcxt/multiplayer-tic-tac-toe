defmodule TicTacToe.Game.Lobby do
  alias TicTacToe.Game.Supervisor
  alias TicTacToe.Game.Server

  def create_server(type \\ :public) do
    case Supervisor.start_child(id: generate_room_id(6), type: type) do
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

  def find_server_by_id(id) do
    TicTacToe.Registry.lookup({Server, id})
  end

  # FIXME: Inefficient use of selecting game servers
  def find_or_create_server() do
    # Selects every game server pid and id from registry -> [id]
    ids = TicTacToe.Registry.select([{{{Server, :"$1"}, :"$2", :_}, [], [:"$1"]}])

    case find_free_server(ids) do
      nil -> Server.id(create_server())
      id -> id
    end
  end

  defp find_free_server(ids) do
    Enum.find(ids, nil, fn id -> Server.is_open?(id) end)
  end
end
