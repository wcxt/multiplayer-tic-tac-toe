defmodule TicTacToe.Game.Match do
  @symbols [:X, :O]
  @turn_timeout 30_000

  defstruct status: :waiting,
            board: nil,
            turn: nil,
            players: %{},
            winner: nil,
            id: nil,
            timer: nil

  def new(opts) do
    id = Keyword.get(opts, :id)

    %__MODULE__{id: id, board: Map.from_keys(Enum.to_list(0..8), nil)}
  end

  def is_open?(match), do: match.status == :waiting

  def join(match, player) do
    match
    |> add_player(player)
    |> handle_player_change()
    |> update()
  end

  def move(match, square, player) do
    symbol = match.players[player].symbol

    if match.turn == symbol and match.board[square] == nil do
      match
      |> place_symbol(square, symbol)
      |> change_turn()
      |> cancel_timer()
      |> set_timer()
      |> check_draw()
      |> check_winner(player)
      |> handle_player_change()
      |> update()
    else
      match
    end
  end

  def leave(match, player) do
    match
    |> remove_player(player)
    |> cancel_timer()
    |> handle_player_change()
    |> update()
  end

  def change_turn(match) do
    %__MODULE__{match | turn: opposite_symbol(match.turn)}
  end

  defp check_winner(match, player) do
    symbol = match.players[player].symbol

    case match.board do
      %{0 => ^symbol, 1 => ^symbol, 2 => ^symbol} -> set_winner(match, player)
      %{3 => ^symbol, 4 => ^symbol, 5 => ^symbol} -> set_winner(match, player)
      %{6 => ^symbol, 7 => ^symbol, 8 => ^symbol} -> set_winner(match, player)
      %{0 => ^symbol, 3 => ^symbol, 6 => ^symbol} -> set_winner(match, player)
      %{1 => ^symbol, 4 => ^symbol, 7 => ^symbol} -> set_winner(match, player)
      %{2 => ^symbol, 5 => ^symbol, 8 => ^symbol} -> set_winner(match, player)
      %{0 => ^symbol, 4 => ^symbol, 8 => ^symbol} -> set_winner(match, player)
      %{2 => ^symbol, 4 => ^symbol, 6 => ^symbol} -> set_winner(match, player)
      _ -> match
    end
  end

  defp check_draw(match) do
    if Enum.all?(Map.values(match.board), &(&1 != nil)),
      do: set_winner(match, :draw),
      else: match
  end

  defp play(match) do
    %__MODULE__{match | turn: :X}
    |> set_status(:playing)
    |> set_timer()
  end

  defp stop_early(match) do
    match
    |> set_status(:done)
    |> set_winner(hd(Map.keys(match.players)))
  end

  defp handle_player_change(%__MODULE__{players: players} = match) when map_size(players) == 0, do: set_status(match, :kill)
  defp handle_player_change(%__MODULE__{status: :waiting, players: players} = match) when map_size(players) == 2, do: play(match)
  defp handle_player_change(%__MODULE__{status: :playing, winner: winner} = match) when winner != nil, do: set_status(match, :done)
  defp handle_player_change(%__MODULE__{status: :playing, players: players} = match) when map_size(players) < 2, do: stop_early(match)
  defp handle_player_change(match), do: match

  defp add_player(match, player) do
    player_with_symbol = Map.merge(player, %{symbol: Enum.random(available_symbols(match))})
    %__MODULE__{match | players: Map.put(match.players, player.id, player_with_symbol)}
  end

  defp remove_player(match, player_id) do
    %__MODULE__{match | players: Map.delete(match.players, player_id)}
  end

  defp place_symbol(match, square, symbol) do
    %__MODULE__{match | board: Map.put(match.board, square, symbol)}
  end

  defp set_winner(match, player_id) do
    %__MODULE__{match | winner: player_id}
  end

  defp set_status(match, new_status) do
    %__MODULE__{match | status: new_status}
  end

  defp set_timer(match) do
    %__MODULE__{match | timer: Process.send_after(self(), :turn_timeout, @turn_timeout)}
  end

  defp cancel_timer(match) do
    Process.cancel_timer(match.timer)
    %__MODULE__{match | timer: nil}
  end

  defp available_symbols(match),
    do: @symbols -- Enum.map(match.players, fn {_, value} -> Map.get(value, :symbol) end)

  defp opposite_symbol(:X), do: :O
  defp opposite_symbol(:O), do: :X

  defp update(match) do
    Phoenix.PubSub.broadcast(
      TicTacToe.PubSub,
      "room:#{match.id}",
      {:update,
       %{
         id: match.id,
         board: match.board,
         turn: match.turn,
         players: match.players,
         status: match.status,
         winner: match.winner
       }}
    )

    match
  end
end
