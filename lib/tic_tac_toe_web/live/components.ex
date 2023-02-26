defmodule TicTacToeWeb.Components do
  use Phoenix.Component
  alias TicTacToeWeb.Icons

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
