defmodule TicTacToe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # TicTacToe.Repo,
      # Start the Telemetry supervisor
      TicTacToeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TicTacToe.PubSub},
      # Start the App registry
      TicTacToe.Registry,
      # Start the Game Cache (DynamicSupervisor)
      TicTacToe.Game.Supervisor,
      # Start the Endpoint (http/https)
      TicTacToeWeb.Endpoint
      # Start a worker by calling: TicTacToe.Worker.start_link(arg)
      # {TicTacToe.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicTacToe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TicTacToeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
