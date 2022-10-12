defmodule Cim.RouterTest do
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
    conn(:put, "/hello/my_key", %{value: "james"})
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
    assert response.resp_body == "james"
  end

  test "returns 400 when value is not a string" do
    response =
      conn(:put, "/hello/my_key", %{value: 12})
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 400
    assert response.resp_body == "Bad request"
  end

  test "returns 400 when body of put is missing" do
    response =
      conn(:put, "/hello/my_key")
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 400
    assert response.resp_body == "Bad request"
  end

  test "returns 404 when route does not exist" do
    response =
      conn(:get, "/hello")
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 404
    assert response.resp_body == "Page not found"
  end

  test "deletes database" do
    conn(:put, "/hello/my_key")
    |> Router.call(@opts)

    response =
      conn(:delete, "/hello")
      |> Router.call(@opts)

    assert response.state == :sent
    assert response.status == 200
  end

  test "deletes key from database" do
  end

  test "returns 404 if database to delete does not exist" do
  end

  test "returns 404 if key to delete does not exist" do
  end
end
