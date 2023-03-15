defmodule TicTacToeWeb.GameLive do
  use TicTacToeWeb, :live_view
  import TicTacToeWeb.LiveHelpers
  alias TicTacToeWeb.Icons
  alias TicTacToe.Game.Server

  @impl true
  def mount(%{"id" => server_id}, session, socket) do
    player = %{id: :rand.uniform(), name: session["username"]}

    if connected?(socket) do
      Phoenix.PubSub.subscribe(TicTacToe.PubSub, "room:#{server_id}")
      Server.join(server_id, player)
    end

    socket =
      socket
      |> assign(:match, %{status: :waiting, id: server_id})
      |> assign(:player, player)

    {:ok, socket}
  end

  # TODO: Cleanup heex
  @impl true
  def render(%{match: %{status: :playing}} = assigns) do
    ~H"""
      <div class="flex flex-col w-screen h-screen">
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
            <span class="font-title text-xl text-gray-600 ml-auto"><%= get_opponent(@match.players, @player).name %></span>
            <Icons.account class="w-6 h-6" />
          </div>
        </section>
        <div class="grid h-full place-items-center">
        <div class="flex flex-col gap-4">
          <div class="grid w-72 rounded-lg h-72 border-2 p-2 border-gray-400 grid-cols-[1fr_1fr_1fr] grid-rows-[1fr_1fr_1fr] gap-2">
          <%= for {index, value} <- @match.board do %>
            <.square phx_click={"move"} value={value} index={index} />
          <% end %>
          </div>
        </div>
        </div>
      </div>
    """
  end

  @impl true
  def render(%{match: %{status: :waiting}} = assigns) do
    ~H"""
      <.loader id={"main-loader"} />
    """
  end

  @impl true
  def render(%{match: %{status: :done}} = assigns) do
    ~H"""
      <%= if @match.winner == @player.id do %>
        <h1 class="font-title text-6xl">Victory</h1>
      <% else %>
        <%= if @match.winner == :draw do %>
          <h1 class="font-title text-6xl">Draw</h1>
        <% else %>
          <h1 class="font-title text-6xl">Defeat</h1>
        <% end %>
      <% end %>
      <.button phx-click="return">Return to menu</.button>
    """
  end

  defp get_opponent(players, curremt_player) do
    Enum.find(Map.values(players), fn plr -> plr.id != curremt_player.id end)
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
