defmodule Cim.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children =
      [
        Cim.StoreServer
        # {Plug.Cowboy, scheme: :http, plug: Cim.Router, options: [port: port()]}
        # Starts a worker by calling: Cim.Worker.start_link(arg)
        # {Cim.Worker, arg}
      ]
      |> add_server()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cim.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end

  defp port() do
    Application.fetch_env!(:cim, :port)
    |> convert_to_integer!()
  end

  defp convert_to_integer!(port) do
    case Integer.parse(port) do
      {value, ""} ->
        value

      _ ->
        raise ArgumentError, message: "Invalid integer value for port"
    end
  end

  defp add_server(children) do
    if start_server?() do
      [
        {Plug.Cowboy, scheme: :http, plug: Cim.Router, options: [port: port()]}
        | children
      ]
    else
      children
    end
  end

  defp start_server?() do
    Application.get_env(:cim, :server, true)
  end
end
