defmodule Cim.Router do
  import Plug.Conn

  use Plug.Router
  use Plug.ErrorHandler

  alias Cim.Store

  plug(:match)

  plug(:dispatch)

  get "/:database/:key" do
    if Store.database_exists?(database) do
      case Store.retrieve_key(database, key) do
        {:ok, value} ->
          conn
          |> send_success_response(value)

        {:error, _reason} ->
          send_not_found_response(conn, "Key not found")
      end
    else
      send_not_found_response(conn, "Database does not exist")
    end
  end

  put "/:database/:key" do
    case read_body(conn) do
      {:ok, body, _} ->
        Store.put_key(database, key, body)
        send_success_response(conn, [])

      _ ->
        send_400_error_response(conn, "Bad request")
    end
  end

  delete "/:database" do
    case Store.delete_database(database) do
      {:ok, _} ->
        send_success_response(conn, [])

      {:error, :not_found} ->
        send_not_found_response(conn, "Database does not exist")
    end
  end

  delete "/:database/:key" do
    case Store.delete_key(database, key) do
      {:ok, _} ->
        send_success_response(conn, [])

      {:error, :not_found} ->
        send_not_found_response(conn, "Key does not exist")
    end
  end

  post "/:database" do
    with {:ok, body, conn} <- read_body(conn),
         {:ok, retrieved_database} <- Store.retrieve_database(database),
         {:ok, value} <- Store.execute_lua(retrieved_database, database, body) do
      send_success_response(conn, value)
    else
      {:error, :not_found} ->
        send_not_found_response(conn, "Database does not exist")

      {:error, :value_not_found} ->
        send_not_found_response(conn, "Key does not exist")

      {:error, {:lua_error, reason}} ->
        send_400_error_response(conn, reason)

      _ ->
        send_500_error_response(conn)
    end
  end

  match _ do
    send_not_found_response(conn, "Page not found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_500_error_response(conn)
  end

  defp send_success_response(connection, value) do
    connection
    |> put_resp_content_type("application/octet-stream")
    |> send_resp(200, to_string(value))
  end

  defp send_not_found_response(connection, message) do
    connection
    |> send_resp(404, message)
  end

  defp send_400_error_response(connection, error) do
    connection
    |> put_resp_content_type("text/plain")
    |> send_resp(400, to_string(error))
  end

  defp send_500_error_response(connection) do
    connection
    |> put_resp_content_type("text/plain")
    |> send_resp(500, "Internal server error")
  end
end
