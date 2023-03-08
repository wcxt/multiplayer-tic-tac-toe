defmodule TicTacToeWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers
  alias TicTacToeWeb.Icons

  def button(assigns) do
    assigns = assigns
      |> assign_new(:class, fn -> "" end)
      |> assign(:rest, assigns_to_attributes(assigns))

    ~H"""
      <button class={"rounded-full bg-red-300 px-10 py-4 text-white text-2xl font-semibold #{@class}"} {@rest}>
          <%= render_slot(@inner_block) %>
      </button>
    """
  end

  def loader(assigns) do
    ~H"""
    <div class="flex gap-4">
      <div class="w-5 h-5 rounded- bg-gray-600 radius-xl animate-[loader_1.5s_infinite_100ms]"></div>
      <div class="w-5 h-5 bg-red-300 radius-xl animate-[loader_1.5s_infinite_300ms]"></div>
      <div class="w-5 h-5 bg-gray-600 radius-xl animate-[loader_1.5s_infinite_500ms]"></div>
    </div>
    """
  end

  def square(assigns) do
    ~H"""
    <div phx-click={@phx_click} phx-value-square={@index} id={"square-#{@index}"} class="rounded-xl bg-white shadow-md">
      <%= case @value do %>
      <% :X -> %>
        <Icons.symbol_X class="fill-red-400" id={"symbol-x-#{@index}"}/>
      <% :O -> %>
        <Icons.symbol_O class="fill-gray-500" id={"symbol-o-#{@index}"} />
      <% nil -> %>
      <% end %>
    </div>
    """
  end
end
