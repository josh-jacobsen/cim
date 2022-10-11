defmodule Cim.Router do
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
    case Cim.Database.retrieve_key(database, key) do
      {:ok, value} ->
        conn
        |> put_resp_content_type("application/octet-stream")
        |> send_resp(200, value)

      {:error, _reason} ->
        send_resp(conn, 404, "Not found")
    end
  end

  put "/:database/:key" do
    # TODO validate that they input is of a sane length and sanitize
    # Consider calling `to_atom` if I can find a way of doing it that won't blow up the system
    # on long input
    # Make sure that value is a string
    value =
      case conn.body_params do
        %{"value" => a_value} -> a_value
        _ -> ""
      end

    # TODO: Validation
    if value do
      Cim.Database.put_key(database, key, value)
      send_resp(conn, 200, [])
    else
      send_resp(conn, 400, "Bad request")
    end
  end

  delete "/:database" do
    IO.inspect("Delete database")
    send_resp(conn, 200, [])
  end

  delete "/:database/:key" do
    IO.inspect("Delete database key")
    send_resp(conn, 200, [])
  end
end
