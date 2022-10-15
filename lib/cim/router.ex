defmodule Cim.Router do
  import Plug.Conn

  use Plug.Router
  use Plug.ErrorHandler

  alias Cim.Store

  plug(:match)

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
    # TODO: Clean up this implementation
    case read_body(conn) do
      {:ok, body, _} ->
        Store.put_key(database, key, body)
        send_resp(conn, 200, [])

      _ ->
        send_resp(conn, 400, "Bad request")
    end
  end

  delete "/:database" do
    case Store.delete_database(database) do
      :ok ->
        send_resp(conn, 200, [])

      {:error, :not_found} ->
        send_resp(conn, 404, "Not found")
    end
  end

  delete "/:database/:key" do
    case Store.delete_key(database, key) do
      {:ok, _} ->
        send_resp(conn, 200, [])

      {:error, :not_found} ->
        send_resp(conn, 404, "Not found")
    end
  end

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, 500, "Something went wrong")
  end
end
