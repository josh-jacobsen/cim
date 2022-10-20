defmodule Cim.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      Cim.StoreServer,
      {Plug.Cowboy, scheme: :http, plug: Cim.Router, options: [port: port()]}
      # Starts a worker by calling: Cim.Worker.start_link(arg)
      # {Cim.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cim.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end

  defp port() do
    port = Application.fetch_env!(:cim, :port)

    case Integer.parse(port) do
      {value, _} -> value
    end
  end
end
