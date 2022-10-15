defmodule Cim.Test do
  use ExUnit.Case
  use Plug.Test

  alias Cim.Router

  @opts Router.init([])

  test "puts value into new database" do
    response =
      conn(:put, "/hello/my_key", %{value: "james"})
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 200
    assert response.resp_body == ""
  end

  test "puts value into existing database" do
    conn(:put, "/hello/my_key", %{value: "james"})
    |> Router.call(@opts)

    response =
      conn(:put, "/hello/my__other_key", %{value: "james_the_second"})
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 200
    assert response.resp_body == ""
  end

  test "puts and retrieves value from database" do
    value = "james"

    conn(:put, "/hello/my_key", value)
    |> Router.call(@opts)

    response =
      conn(:get, "/hello/my_key")
      |> Router.call(@opts)

    assert Enum.member?(
             response.resp_headers,
             {"content-type", "application/octet-stream; charset=utf-8"}
           )

    assert response.state == :sent
    assert response.status == 200
    assert response.resp_body == value
  end

  test "returns 404 when route does not exist" do
    response =
      conn(:get, "/notfound")
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 404
    assert response.resp_body == "Page not found"
  end

  test "deletes database" do
    conn(:put, "/hello/my_key", "james")
    |> Router.call(@opts)

    response =
      conn(:delete, "/hello")
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 200
  end

  test "deletes key from database" do
    conn(:put, "/hello/my_key", "james")
    |> Router.call(@opts)

    response =
      conn(:delete, "/hello/my_key")
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 200
    assert response.resp_body == ""
  end

  test "returns 404 if database to delete does not exist" do
    response =
      conn(:delete, "/nulldb")
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 404
    assert response.resp_body == "Not found"
  end

  test "returns 404 if key to delete does not exist" do
    response =
      conn(:delete, "/hello/key")
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 404
    assert response.resp_body == "Not found"
  end
end
