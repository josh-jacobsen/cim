defmodule Cim.StoreServerTest do
  use ExUnit.Case

  alias Cim.StoreServer

  test "retrieve_key returns nil if key not found" do
    assert StoreServer.retrieve_key("db", "new_key") == {:ok, nil}
  end

  test "retrieve_key returns key if found" do
    StoreServer.put_key_new_database("db", "key", "hello, world")
    assert StoreServer.retrieve_key("db", "key") == {:ok, "hello, world"}
  end

  test "execute lua reads key" do
    StoreServer.put_key_new_database("db_exists", "my_key", "hello, world!")
    result = StoreServer.execute_lua("db_exists", "return cim.read(\"my_key\")")
    assert result == {:ok, "hello, world!"}
  end

  test "executing lua against a database that does not exist returns a :db_not_found error" do
    assert StoreServer.execute_lua("db_does_not_exist", "return cim.read(\"my_key\")") ==
             {:error, :db_not_found}
  end

  test "executing lua when key does not exist returns empty string" do
    StoreServer.put_key_new_database("db_exists", "my_key", "hello, world!")

    assert StoreServer.execute_lua("db_exists", "return cim.read(\"key_does_not_exist\")") ==
             {:ok, ""}
  end

  test "invalid lua returns verbose lua error" do
    StoreServer.put_key_new_database("db_exists", "my_key", "hello, world!")

    assert StoreServer.execute_lua("db_exists", "return this.is.not.lua(\"my_key\")") ==
             {:error,
              {:lua_error,
               %MatchError{
                 term: {:error, [{1, :luerl_parse, ['syntax error before: ', '\'not\'']}], []}
               }}}
  end
end
