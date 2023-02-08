defmodule TicTacToeWeb.Components do
  use Phoenix.Component

  def symbol(%{value: nil} = assigns), do: ~H||

  def symbol(%{value: :X} = assigns) do
    ~H"""
    <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
        <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
        <g id="SVGRepo_iconCarrier">
            <path d="M17 7L7 17M7 7L17 17" class="stroke-red-300" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
        </g>
        </svg>
    """
  end

  def symbol(%{value: :O} = assigns) do
    ~H"""
    <svg fill="#4b5563" viewBox="0 0 64 64" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve"
         xmlns:serif="http://www.serif.com/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linejoin:round;stroke-miterlimit:2;" stroke="#4b5563">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier"> <rect id="Icons" x="-448" y="-320" width="1280" height="800" style="fill:none;"></rect> <g id="Icons1" serif:id="Icons">
          <g id="Strike"> </g> <g id="H1"> </g> <g id="H2"> </g> <g id="H3"> </g> <g id="list-ul"> </g> <g id="hamburger-1"> </g>
          <g id="hamburger-2"> </g> <g id="list-ol"> </g> <g id="list-task"> </g> <g id="trash"> </g> <g id="vertical-menu">
          </g> <g id="horizontal-menu"> </g> <g id="sidebar-2"> </g> <g id="Pen"> </g> <g id="Pen1" serif:id="Pen">
          </g> <g id="clock"> </g> <g id="external-link"> </g> <g id="hr"> </g> <g id="info"> </g> <g id="warning"> </g> <g id="plus-circle">
          </g> <g id="minus-circle"> </g> <g id="vue"> </g> <g id="cog"> </g> <g id="logo"> </g> <g id="radio-check"> </g> <g id="eye-slash"> </g> <g id="eye">
          </g> <g id="toggle-off"> </g> <g id="shredder"> </g> <g id="spinner--loading--dots-" serif:id="spinner [loading, dots]"> </g> <g id="react">
          </g> <path d="M32.142,56.043c6.179,-0.06 12.297,-2.62 16.696,-6.967c5.225,-5.163 7.916,-12.803 6.978,-20.096c-1.609,-12.499 -11.883,-20.98 -23.828,-20.98c-9.075,0 -17.896,5.677 -21.765,13.909c-2.961,6.303 -2.967,13.911 0,20.225c3.842,8.174 12.517,13.821 21.61,13.909c0.103,0 0.206,0 0.309,0Zm-0.283,-4.004c-9.23,-0.089 -17.841,-7.227 -19.553,-16.378c-1.208,-6.452 1.071,-13.433 5.818,-18.015c5.543,-5.35 14.253,-7.142 21.496,-4.11c6.481,2.714 11.331,9.014 12.225,15.955c0.766,5.949 -1.369,12.185 -5.565,16.48c-3.68,3.767 -8.841,6.017 -14.164,6.068c-0.085,0 -0.171,0 -0.257,0Z" style="fill-rule:nonzero;"></path> <g id="check-selected"> </g> <g id="turn-off"> </g> <g id="code-block"> </g> <g id="user"> </g> <g id="coffee-bean"> </g> <g id="coffee-beans"> <g id="coffee-bean1" serif:id="coffee-bean"> </g> </g> <g id="coffee-bean-filled"> </g> <g id="coffee-beans-filled"> <g id="coffee-bean2" serif:id="coffee-bean"> </g> </g> <g id="clipboard"> </g> <g id="clipboard-paste"> </g> <g id="clipboard-copy"> </g> <g id="Layer1"> </g> </g> </g></svg>
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
end
