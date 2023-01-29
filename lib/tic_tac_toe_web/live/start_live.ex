defmodule TicTacToeWeb.StartLive do
  alias TicTacToe.MatchMaker
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div class="grid h-screen place-items-center bg-gray-100">
    <p class="font-title text-8xl text-gray-600">Tic<span class="text-red-300">Tac</span>Toe</p>
    <button phx-click="start" class="rounded-full bg-red-300 px-10 py-4 text-white text-2xl font-semibold">Start</button>
    </div>
    """
  end

  def handle_event("start", _, socket) do
    room_id = MatchMaker.get()

    {:noreply, push_redirect(socket, to: "/game/#{room_id}")}
  end
end
