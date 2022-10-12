defmodule Cim.Router do
  import Plug.Conn

  use Plug.Router
  use Plug.ErrorHandler

  alias Cim.Store

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/:database/:key" do
    case Store.retrieve_key(database, key) do
      {:ok, value} ->
        conn
        |> put_resp_content_type("application/octet-stream")
        |> send_resp(200, value)

      {:error, _reason} ->
        send_resp(conn, 404, "Not found")
    end
  end

  put "/:database/:key" do
    case validate_input(conn.body_params) do
      {:ok, value} ->
        Store.put_key(database, key, value)
        send_resp(conn, 200, [])

      {:error, :validation_failed} ->
        send_resp(conn, 400, "Bad request")
    end
  end

  delete "/:database" do
    case Store.delete_database(database) do
      :ok ->
        send_resp(conn, 200, [])

      {:error, :database_not_found} ->
        send_resp(conn, 404, "Not found")
    end
  end

  delete "/:database/:key" do
    case Store.delete_key(database, key) do
      :ok -> send_resp(conn, 200, [])
      {:error, :key_not_found} -> send_resp(conn, 404, "Not found")
    end
  end

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)
    send_resp(conn, 500, "Something went wrong")
  end

  defp validate_input(%{"value" => input}) do
    validate_input_is_string(input)
  end

  defp validate_input(_) do
    {:error, :validation_failed}
  end

  defp validate_input_is_string(input) when is_binary(input) do
    {:ok, input}
  end

  defp validate_input_is_string(_) do
    {:error, :validation_failed}
  end
end
