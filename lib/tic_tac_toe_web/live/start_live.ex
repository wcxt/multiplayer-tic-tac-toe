defmodule TicTacToeWeb.StartLive do
  alias TicTacToe.MatchMaker
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :form, %{name: "Guest"})}
  end

  def render(assigns) do
    ~H"""
    <div class="grid h-screen place-items-center bg-gray-100">
    <p class="font-title text-8xl text-gray-600">Tic<span class="text-red-300">Tac</span>Toe</p>
    <button phx-click="start" class="rounded-full bg-red-300 px-10 py-4 text-white text-2xl font-semibold">Start</button>
    <form id="name-form" phx-change="change-name" class="flex flex-col gap-6" phx-hook="NameInput">
      <label for="name" class="text-center text-gray-600 border-b-[1px] h-4 border-gray-600"><span class="bg-gray-100 p-2">Play as</span></label>
      <input name="name" value={@form[:name]} placeholder="Guest" class="p-3 rounded-full shadow-lg text-center" phx-debounce="500"/>
    </form>
    </div>
    """
  end

  def handle_event("change-name", %{"name" => name}, socket) do
    {:noreply, assign(socket, :form, %{name: name})}
  end

  def handle_event("restore-name", %{"name" => name}, socket) do
    {:noreply, assign(socket, :form, %{name: name})}
  end

  def handle_event("start", _, socket) do
    room_id = MatchMaker.get()

    {:noreply, push_redirect(socket, to: "/game/#{room_id}")}
  end
end
