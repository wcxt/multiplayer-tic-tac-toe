defmodule TicTacToeWeb.GameLive do
  use Phoenix.LiveView
  require Logger
  alias TicTacToeWeb.Components
  alias TicTacToe.Game.Server

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    case connected?(socket) do
      true ->
        player_id = :rand.uniform()
        {room_id, _} = Float.parse(room_id)

        Phoenix.PubSub.subscribe(TicTacToe.PubSub, "room:#{room_id}")
        Server.join(room_id, player_id)
        Logger.info("LiveView: Joined game: id: #{room_id}")

        new =
          socket
          |> assign(:status, :waiting)
          |> assign(:board, Map.from_keys(Enum.to_list(0..8), nil))
          |> assign(:player_id, player_id)
          |> assign(:room_id, room_id)
          |> assign(:winner_id, nil)

        {:ok, new}

      false ->
        {:ok, assign(socket, :status, :waiting)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid h-screen place-items-center bg-gray-100">
      <%= case @status do %>
      <% :playing -> %>
        <div class="grid w-72 rounded-lg h-72 border-2 p-2 border-gray-400 grid-cols-[1fr_1fr_1fr] grid-rows-[1fr_1fr_1fr] gap-2">
          <%= for {index, value} <- @board do %>
            <div phx-click="move" phx-value-square={index} class="rounded-xl bg-white shadow-md">
              <Components.symbol value={value} id={"symbol-#{index}"} />
            </div>
          <% end %>
        </div>
      <% :waiting -> %>
        <Components.loader id={"main-loader"} />
      <% :done -> %>
        <%= if @winner_id == @player_id do %>
          <h1 class="font-title text-6xl">Victory</h1>
        <% else %>
          <h1 class="font-title text-6xl">Defeat</h1>
        <% end %>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("move", %{"square" => square}, socket) do
    {square, _} = Integer.parse(square)
    Server.move(socket.assigns.room_id, socket.assigns.player_id, square)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, %{board: board}}, socket) do
    {:noreply, assign(socket, :board, board)}
  end

  @impl true
  def handle_info({:start}, socket) do
    {:noreply, assign(socket, :status, :playing)}
  end

  @impl true
  def handle_info({:done, %{winner: winner}}, socket) do
    new =
      socket
      |> assign(:board, Map.from_keys(Enum.to_list(0..8), nil))
      |> assign(:status, :done)
      |> assign(:winner_id, winner)

    {:noreply, new}
  end

  @impl true
  def terminate(_, socket) do
    Server.leave(socket.assigns.room_id, socket.assigns.player_id)
  end
end
