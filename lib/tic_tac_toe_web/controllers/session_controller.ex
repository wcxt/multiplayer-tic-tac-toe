defmodule TicTacToeWeb.SessionController do
  use TicTacToeWeb, :controller

  def set(conn, %{"username" => username}) do
    conn
    |> fetch_session()
    |> put_session("username", username)
    |> json(%{success: true})
  end
end
