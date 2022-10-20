defmodule Cim.Store do
  @moduledoc """
  The service that interacts with the database server.
  Logical boundary between the database implementation and the rest of the codebase.
  """
  alias Cim.StoreServer

  @spec retrieve_key(StoreServer.database_name(), StoreServer.key()) ::
          {:error, :not_found} | {:ok, StoreServer.value()}
  def retrieve_key(database_name, key) do
    StoreServer.retrieve_key(database_name, key)
    |> send_response()
  end

  @spec put_key(StoreServer.database_name(), StoreServer.key(), StoreServer.value()) :: :ok
  def put_key(database, key, value) do
    if database_exists?(database) do
      StoreServer.put_key_existing_database(database, key, value)
    else
      StoreServer.put_key_new_database(database, key, value)
    end
  end

  @spec database_exists?(StoreServer.database_name()) :: boolean()
  def database_exists?(database_name) do
    StoreServer.database_exists?(database_name)
  end

  @spec retrieve_database(StoreServer.database_name()) ::
          {:error, :not_found} | {:ok, binary | map}
  def retrieve_database(database_name) do
    StoreServer.retrieve_database(database_name)
    |> send_response()
  end

  @spec delete_key(StoreServer.database_name(), StoreServer.key()) ::
          {:error, :not_found} | {:ok, binary}
  def delete_key(database, key) do
    StoreServer.delete_key(database, key)
    |> send_response()
  end

  @spec delete_database(binary) :: {:error, :not_found} | {:ok, binary | map}
  def delete_database(database) do
    StoreServer.delete_database(database)
    |> send_response()
  end

  def execute_lua(database_name, script) do
    StoreServer.execute_lua(database_name, script)
    |> send_response()
  end

  defp send_response({:ok, value}) when is_binary(value) do
    {:ok, value}
  end

  defp send_response({:ok, value}) when is_map(value) do
    {:ok, value}
  end

  defp send_response({:ok, value}) when is_nil(value) do
    {:ok, nil}
  end

  defp send_response(value) when is_map(value) do
    {:ok, value}
  end

  defp send_response(:ok) do
    {:ok, nil}
  end

  defp send_response({:error, :value_not_found}) do
    {:error, :value_not_found}
  end

  defp send_response({:error, :db_not_found}) do
    {:error, :db_not_found}
  end

  defp send_response(_) do
    {:error, :not_found}
  end
end
