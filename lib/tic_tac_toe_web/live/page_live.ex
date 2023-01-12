defmodule TicTacToeWeb.PageLive do
  alias TicTacToe.Game.Server
  use Phoenix.LiveView
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # subcribes to message queue of this room
    Phoenix.PubSub.subscribe(TicTacToe.PubSub, "room:1")
    # creates game server that manages logic and socket communication
    pid = TicTacToe.Game.Cache.join(1)
    Logger.info("LiveView: Joined game: id: #{1} pid: #{inspect(pid)}")

    new =
      socket
      |> assign(:server, pid)
      |> assign(:room_id, 1)
      |> assign(:game, Map.from_keys(Enum.to_list(0..8), nil))

    {:ok, new}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid h-screen place-items-center">
      <div class="grid w-72 h-72 grid-cols-[1fr_1fr_1fr] grid-rows-[1fr_1fr_1fr] gap-2 bg-white">
        <%= for {index, value} <- @game do %>
          <div phx-click="move" phx-value-id={index} class="rounded-lg bg-gray-200">
            <%= if value != nil do %>
              <%= value %>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("move", %{"id" => id}, socket) do
    {id, _} = Integer.parse(id)
    # for now client state is updated only by server
    Server.move(socket.assigns.room_id, id)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, game}, socket) do
    {:noreply, assign(socket, :game, game)}
  end
end
