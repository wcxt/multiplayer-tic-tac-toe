defmodule TicTacToeWeb.PageLive do
  use Phoenix.LiveView

  @impl true
  def mount(_params, _session, socket) do
    board = %{
      0 => nil,
      1 => nil,
      2 => nil,
      3 => nil,
      4 => nil,
      5 => nil,
      6 => nil,
      7 => nil,
      8 => nil
    }

    {:ok, assign(socket, :game, board)}
  end

  @impl true
  def render(assigns) do
    IO.inspect(assigns.game)

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
    {:noreply, assign(socket, :game, Map.replace(socket.assigns.game, id, :X))}
  end
end
