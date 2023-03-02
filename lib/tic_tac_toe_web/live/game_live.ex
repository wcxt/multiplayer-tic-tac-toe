defmodule TicTacToeWeb.GameLive do
  use Phoenix.LiveView
  alias TicTacToeWeb.Components
  alias TicTacToeWeb.Icons
  alias TicTacToe.Game.Server

  @impl true
  def mount(%{"id" => room_id}, session, socket) do
    player = %{id: :rand.uniform(), name: session["username"]}
    {room_id, _} = Float.parse(room_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(TicTacToe.PubSub, "room:#{room_id}")
      Server.join(room_id, player)
    end

    new =
      socket
      |> assign(:match, %{status: :waiting, id: room_id})
      |> assign(:player, player)

    {:ok, new}
  end

  @impl true
  def render(assigns) do

    ~H"""
      <div class="flex flex-col w-screen h-screen bg-gray-100">
      <%= case @match.status do %>
      <% :playing -> %>
        <section class="flex items-center w-full border-2 p-4 border-gray-500 bg-transparent">
          <div class="grow basis-1/3 flex gap-3 items-center">
            <Icons.account class="w-6 h-6" />
            <span class="font-title text-xl text-gray-600">You</span>
          </div>
          <div class="grow basis-1/3 font-title text-4xl text-center">
          <%= if @match.turn == @match.players[@player.id].symbol do %>
            <span class={if(@match.turn == :X, do: "text-red-400", else: "text-gray-500")}>Your Turn</span>
          <% else %>
            <span class={if(@match.turn == :X, do: "text-red-400", else: "text-gray-500")}>Opponent Turn</span>
          <% end %>
          </div>
          <div class="grow basis-1/3 flex gap-3 items-center">
            <span class="font-title text-xl text-gray-600 ml-auto">Opponent</span>
            <Icons.account class="w-6 h-6" />
          </div>
        </section>
        <div class="grid h-full place-items-center">
        <div class="flex flex-col gap-4">
          <div class="grid w-72 rounded-lg h-72 border-2 p-2 border-gray-400 grid-cols-[1fr_1fr_1fr] grid-rows-[1fr_1fr_1fr] gap-2">
          <%= for {index, value} <- @match.board do %>
            <Components.square phx_click={"move"} value={value} index={index} />
          <% end %>
          </div>
        </div>
        </div>
      <% :waiting -> %>

        <div class="grid h-screen place-items-center">
          <Components.loader id={"main-loader"} />
        </div>
      <% :done -> %>

        <div class="grid h-screen place-items-center">
        <%= if @match.winner == @player.id do %>
          <h1 class="font-title text-6xl">Victory</h1>
        <% else %>
          <%= if @match.winner == :draw do %>
          <h1 class="font-title text-6xl">Draw</h1>
        <% else %>
          <h1 class="font-title text-6xl">Defeat</h1>
        <% end %>
        <% end %>
        <button phx-click="return" class="rounded-full bg-red-300 px-10 py-4 text-white text-2xl font-semibold">Return to menu</button>
        </div>
      <% end %>
      </div>
    """
  end

  @impl true
  def handle_event("move", %{"square" => square}, socket) do
    {square, _} = Integer.parse(square)
    Server.move(socket.assigns.match.id, socket.assigns.player.id, square)
    {:noreply, socket}
  end

  @impl true
  def handle_event("return", _, socket) do
    {:noreply, push_redirect(socket, to: "/")}
  end

  @impl true
  def handle_info({:update, match}, socket) do
    {:noreply, assign(socket, :match, match)}
  end

  @impl true
  def terminate(_, socket) do
    Server.leave(socket.assigns.match.id, socket.assigns.player.id)
  end
end
