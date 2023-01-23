defmodule TicTacToeWeb.PageLive do
  use Phoenix.LiveView
  require Logger
  alias TicTacToe.Game.Server

  @impl true
  def mount(_params, _session, socket) do
    case connected?(socket) do
      true ->
        Phoenix.PubSub.subscribe(TicTacToe.PubSub, "room:1")
        # Just to ensure game server exist
        TicTacToe.Game.Cache.get(1)

        player_id = :rand.uniform()
        Server.join(1, player_id)
        Logger.info("LiveView: Joined game: id: #{1}")

        new =
          socket
          |> assign(:is_ready, false)
          |> assign(:player_id, player_id)
          |> assign(:room_id, 1)
          |> assign(:game, Map.from_keys(Enum.to_list(0..8), nil))

        {:ok, new}

      false ->
        {:ok, assign(socket, :is_ready, false)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid h-screen place-items-center bg-gray-100">
      <%= if @is_ready do %>
      <div class="grid w-72 rounded-lg h-72 border-2 p-2 border-gray-400 grid-cols-[1fr_1fr_1fr] grid-rows-[1fr_1fr_1fr] gap-2">
        <%= for {index, value} <- @game do %>
          <div phx-click="move" phx-value-id={index} class="rounded-xl bg-white shadow-md">
            <%= if value != nil do %>
              <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <path d="M17 7L7 17M7 7L17 17" class="stroke-red-300" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
                </g>
              </svg>
            <% end %>
          </div>
        <% end %>
      </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("move", %{"id" => id}, socket) do
    {id, _} = Integer.parse(id)
    # for now client state is updated only by server
    Server.move(socket.assigns.room_id, socket.assigns.player_id, id)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, game}, socket) do
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_info({:ready, _turn}, socket) do
    {:noreply, assign(socket, :is_ready, true)}
  end

  @impl true
  def terminate(_, socket) do
    Server.disconnect(socket.assigns.room_id, socket.assigns.player_id)
  end
end
