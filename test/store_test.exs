defmodule Cim.StoreServerTest do
  use ExUnit.Case

  alias Cim.Store

  test "put key creates database if it does not exist" do
    assert Store.put_key("db2", "my_key", "hello, world!") == :ok
  end

  test "put key adds new key to existing database" do
    Store.put_key("db2", "adding_key_creates_db", "hello, db!")
    assert Store.put_key("db2", "my_key", "hello, world!") == :ok
  end

  test "retrieve_key returns not found error if key does not exist" do
    assert Store.retrieve_key("db1", "my_key") == {:error, :not_found}
  end

  test "retrieve_key returns key if it exists" do
    Store.put_key("db2", "my_key", "hello, world!")
    assert Store.retrieve_key("db2", "my_key") == {:ok, "hello, world!"}
  end

  test "database_exists returns false if database does not exist" do
    assert Store.database_exists?("db_does_not_exist") == false
  end

  test "database_exists returns true if database exists" do
    Store.put_key("db_exists", "my_key", "hello, world!")
    assert Store.database_exists?("db_exists") == true
  end

  test "delete key returns not found error if key or database does not exist" do
    result = Store.delete_key("db", "random key")
    assert result == {:error, :not_found}
  end

  test "delete key returns deleted key" do
    Store.put_key("db_exists", "my_key", "hello, world!")
    result = Store.delete_key("db_exists", "my_key")
    assert result == {:ok, "hello, world!"}
  end

  test "execute lua reads key" do
    Store.put_key("db_exists", "my_key", "hello, world!")
    result = Store.execute_lua("db_exists", "return cim.read(\"my_key\")")
    assert result == {:ok, "hello, world!"}
  end

  test "executing lua against a database that does not exist returns a :db_not_found error" do
    assert Store.execute_lua("db_does_not_exist", "return cim.read(\"my_key\")") ==
             {:error, :db_not_found}
  end

  test "executing lua when key does not exist returns nil" do
    Store.put_key("db_exists", "my_key", "hello, world!")

    assert Store.execute_lua("db_exists", "return cim.read(\"key_does_not_exist\")") ==
             {:ok, nil}
  end

  test "invalid lua returns :lua_error" do
    Store.put_key("db_exists", "my_key", "hello, world!")

    assert Store.execute_lua("db_exists", "return this.is.not.lua(\"my_key\")") ==
             {:error, :lua_error}
  end
end
