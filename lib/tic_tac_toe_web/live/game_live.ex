defmodule TicTacToeWeb.GameLive do
  use Phoenix.LiveView
  alias TicTacToeWeb.Components
  alias TicTacToe.Game.Server

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    player_id = :rand.uniform()
    {room_id, _} = Float.parse(room_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(TicTacToe.PubSub, "room:#{room_id}")
      Server.join(room_id, player_id)
    end

    new =
      socket
      |> assign(:match, %{status: :waiting, id: room_id})
      |> assign(:player_id, player_id)

    {:ok, new}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid h-screen place-items-center bg-gray-100">
      <%= case @match.status do %>
      <% :playing -> %>
        <div class="flex flex-col gap-4">
        <section class="flex gap-2 justify-center items-center">
        <h2 class="font-title text-4xl">Turn: </h2>
        <div class="w-12 h-12">
        <Components.symbol value={@match.turn} id={"turn-symbol"} />
        </div>
        </section>
        <div class="grid w-72 rounded-lg h-72 border-2 p-2 border-gray-400 grid-cols-[1fr_1fr_1fr] grid-rows-[1fr_1fr_1fr] gap-2">
          <%= for {index, value} <- @match.board do %>
            <div phx-click="move" phx-value-square={index} class="rounded-xl bg-white shadow-md">
              <Components.symbol value={value} id={"symbol-#{index}"} />
            </div>
          <% end %>
        </div>
        </div>
      <% :waiting -> %>
        <Components.loader id={"main-loader"} />
      <% :done -> %>
        <%= if @match.winner == @player_id do %>
          <h1 class="font-title text-6xl">Victory</h1>
        <% else %>
          <%= if @match.winner == :draw do %>
          <h1 class="font-title text-6xl">Draw</h1>
        <% else %>
          <h1 class="font-title text-6xl">Defeat</h1>
        <% end %>
        <% end %>
        <button phx-click="return" class="rounded-full bg-red-300 px-10 py-4 text-white text-2xl font-semibold">Return to menu</button>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("move", %{"square" => square}, socket) do
    {square, _} = Integer.parse(square)
    Server.move(socket.assigns.match.id, socket.assigns.player_id, square)
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
    Server.leave(socket.assigns.match.id, socket.assigns.player_id)
  end
end
