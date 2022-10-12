defmodule Cim.Router do
  alias Cim.Store

  use Plug.Router
  import Plug.Conn
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
    # TODO: Validation
    value =
      case conn.body_params do
        %{"value" => a_value} -> a_value
        _ -> nil
      end

    if value do
      Store.put_key(database, key, value)
      send_resp(conn, 200, [])
    else
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

  # TODO: Add match that returns 404 for any other route
end
