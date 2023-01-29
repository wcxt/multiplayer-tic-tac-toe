defmodule TicTacToeWeb.GameLive do
  use Phoenix.LiveView
  require Logger
  alias TicTacToe.Game.Server

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    case connected?(socket) do
      true ->
        # Just to ensure game server exist
        player = :rand.uniform()
        {room_id, _} = Float.parse(room_id)

        Phoenix.PubSub.subscribe(TicTacToe.PubSub, "room:#{room_id}")
        Server.join(room_id, player)
        Logger.info("LiveView: Joined game: id: #{room_id}")

        new =
          socket
          |> assign(:is_ready, false)
          |> assign(:player_id, player)
          |> assign(:room_id, room_id)
          |> assign(:game, Map.from_keys(Enum.to_list(0..8), nil))

        {:ok, new}

      false ->
        {:ok, assign(socket, :is_ready, false)}
    end
  end

  defp display_square(%{value: nil} = assigns), do: ~H||

  defp display_square(%{value: :X} = assigns),
    do: ~H|<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <path d="M17 7L7 17M7 7L17 17" class="stroke-red-300" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
                </g>
           </svg>|

  defp display_square(%{value: :O} = assigns),
    do:
      ~H|<svg fill="#4b5563" viewBox="0 0 64 64" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve"
         xmlns:serif="http://www.serif.com/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linejoin:round;stroke-miterlimit:2;" stroke="#4b5563">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier"> <rect id="Icons" x="-448" y="-320" width="1280" height="800" style="fill:none;"></rect> <g id="Icons1" serif:id="Icons">
          <g id="Strike"> </g> <g id="H1"> </g> <g id="H2"> </g> <g id="H3"> </g> <g id="list-ul"> </g> <g id="hamburger-1"> </g>
          <g id="hamburger-2"> </g> <g id="list-ol"> </g> <g id="list-task"> </g> <g id="trash"> </g> <g id="vertical-menu">
          </g> <g id="horizontal-menu"> </g> <g id="sidebar-2"> </g> <g id="Pen"> </g> <g id="Pen1" serif:id="Pen">
          </g> <g id="clock"> </g> <g id="external-link"> </g> <g id="hr"> </g> <g id="info"> </g> <g id="warning"> </g> <g id="plus-circle">
          </g> <g id="minus-circle"> </g> <g id="vue"> </g> <g id="cog"> </g> <g id="logo"> </g> <g id="radio-check"> </g> <g id="eye-slash"> </g> <g id="eye">
          </g> <g id="toggle-off"> </g> <g id="shredder"> </g> <g id="spinner--loading--dots-" serif:id="spinner [loading, dots]"> </g> <g id="react">
          </g> <path d="M32.142,56.043c6.179,-0.06 12.297,-2.62 16.696,-6.967c5.225,-5.163 7.916,-12.803 6.978,-20.096c-1.609,-12.499 -11.883,-20.98 -23.828,-20.98c-9.075,0 -17.896,5.677 -21.765,13.909c-2.961,6.303 -2.967,13.911 0,20.225c3.842,8.174 12.517,13.821 21.61,13.909c0.103,0 0.206,0 0.309,0Zm-0.283,-4.004c-9.23,-0.089 -17.841,-7.227 -19.553,-16.378c-1.208,-6.452 1.071,-13.433 5.818,-18.015c5.543,-5.35 14.253,-7.142 21.496,-4.11c6.481,2.714 11.331,9.014 12.225,15.955c0.766,5.949 -1.369,12.185 -5.565,16.48c-3.68,3.767 -8.841,6.017 -14.164,6.068c-0.085,0 -0.171,0 -0.257,0Z" style="fill-rule:nonzero;"></path> <g id="check-selected"> </g> <g id="turn-off"> </g> <g id="code-block"> </g> <g id="user"> </g> <g id="coffee-bean"> </g> <g id="coffee-beans"> <g id="coffee-bean1" serif:id="coffee-bean"> </g> </g> <g id="coffee-bean-filled"> </g> <g id="coffee-beans-filled"> <g id="coffee-bean2" serif:id="coffee-bean"> </g> </g> <g id="clipboard"> </g> <g id="clipboard-paste"> </g> <g id="clipboard-copy"> </g> <g id="Layer1"> </g> </g> </g></svg>|

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid h-screen place-items-center bg-gray-100">
      <%= if @is_ready do %>
      <div class="grid w-72 rounded-lg h-72 border-2 p-2 border-gray-400 grid-cols-[1fr_1fr_1fr] grid-rows-[1fr_1fr_1fr] gap-2">
        <%= for {index, value} <- @game do %>
          <div phx-click="move" phx-value-id={index} class="rounded-xl bg-white shadow-md">
            <.display_square value={value} />
          </div>
        <% end %>
      </div>
      <% else %>
        <div class="flex gap-4">
        <div class="w-5 h-5 rounded- bg-gray-600 radius-xl animate-[loader_1.5s_infinite_100ms]"></div>
        <div class="w-5 h-5 bg-red-300 radius-xl animate-[loader_1.5s_infinite_300ms]"></div>
        <div class="w-5 h-5 bg-gray-600 radius-xl animate-[loader_1.5s_infinite_500ms]"></div>
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
  def handle_info({:ready, _}, socket) do
    {:noreply, assign(socket, :is_ready, true)}
  end

  @impl true
  def handle_info({:stop, _}, socket) do
    new =
      socket
      |> assign(:game, Map.from_keys(Enum.to_list(0..8), nil))
      |> assign(:is_ready, false)

    {:noreply, new}
  end

  @impl true
  def terminate(_, socket) do
    Server.disconnect(socket.assigns.room_id, socket.assigns.player_id)
  end
end
