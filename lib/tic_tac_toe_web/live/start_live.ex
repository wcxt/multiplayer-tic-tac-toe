defmodule TicTacToeWeb.StartLive do
  use TicTacToeWeb, :live_view
  import TicTacToeWeb.LiveHelpers
  require Logger
  alias TicTacToe.Game.Lobby

  # TODO: Try a different method when it comes to changing username for not logged in
  #       - current method: https://thepugautomatic.com/2020/05/persistent-session-data-in-phoenix-liveview/
  def mount(_, session, socket) do
    {:ok, assign(socket, :form, %{name: session["username"]})}
  end

  # TODO: Cleanup heex
  def render(assigns) do
    ~H"""
    <p class="font-title text-8xl text-gray-600">Tic<span class="text-red-300">Tac</span>Toe</p>
    <div class="grid grid-flow-col grid-cols-3 gap-14">
    <.button phx-click="create-room" class="mb-6" >Create room</.button>
    <.button phx-click="play-online" class="place-self-center" >Online</.button>
    <form id="join-form" phx-submit="join-room">
      <input name="code" placeholder="Join room" class="p-3 rounded-full shadow-lg text-center" />
    </form>
    </div>
    <form id="name-form" phx-change="change-name" class="flex flex-col gap-6" phx-hook="NameInput">
      <label for="name" class="text-center text-gray-600 border-b-[1px] h-4 border-gray-600"><span class="bg-gray-100 p-2">Play as</span></label>
      <input name="name" value={@form[:name]} placeholder="Guest" class="p-3 rounded-full shadow-lg text-center" phx-debounce="500"/>
    </form>
    """
  end

  def handle_event("change-name", %{"name" => name}, socket) do
    {:noreply, assign(socket, :form, %{name: name})}
  end

  def handle_event("play-online", _, socket) do
    {:noreply, push_redirect(socket, to: "/game/#{Lobby.find_or_create_server()}")}
  end

  def handle_event("create-room", _, socket) do
    id = TicTacToe.Game.Server.id(Lobby.create_server(:private))
    {:noreply, push_redirect(socket, to: "/game/#{id}")}
  end

  def handle_event("join-room", %{"code" => code}, socket) do
    Logger.info("Finding a server with given code: #{code}")
    Logger.info("Redirect if server found flash error if server does not exist")

    {:noreply, socket}
  end
end
