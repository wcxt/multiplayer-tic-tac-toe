defmodule TicTacToeWeb.SessionDefaults do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    defaults = %{"username" => "Guest"}

    Enum.reduce(defaults, conn, fn {key, value}, acc_conn ->
      new_value = get_session(acc_conn, key) || value
      put_session(acc_conn, key, new_value)
    end)
  end
end
