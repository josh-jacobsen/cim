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
    port = Application.fetch_env!(:cim, :port)

    with {:ok, value} <- valid_port(port),
         {:ok, port_as_integer} <- convert_to_integer(value) do
      port_as_integer
    else
      _ ->
        raise ArgumentError, message: "#{port} is not a valid integer value"
    end
  end

  defp valid_port(port) do
    if Regex.match?(~r{\A\d*\z}, port) do
      {:ok, port}
    else
      {:error, :invalid_port}
    end
  end

  defp convert_to_integer(port) do
    case Integer.parse(port) do
      {value, _} ->
        {:ok, value}

      :error ->
        {:error, :invalid_integer}
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
