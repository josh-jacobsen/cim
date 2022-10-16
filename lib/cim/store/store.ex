defmodule Cim.Store do
  @moduledoc """
  The service that interacts with the database server.
  Logical boundary between the database implementation and the rest of the codebase.
  """
  alias Cim.StoreServer

  @spec retrieve_key(StoreServer.database_name(), StoreServer.key()) ::
          {:error, :not_found} | {:ok, StoreServer.value()}
  def retrieve_key(database, key) do
    StoreServer.retrieve_key(database, key)
    |> send_response()
  end

  @spec put_key(StoreServer.database_name(), StoreServer.key(), StoreServer.value()) :: :ok
  def put_key(database, key, value) do
    if StoreServer.database_exists?(database) do
      StoreServer.put_key_existing_database(database, key, value)
    else
      StoreServer.put_key_new_database(database, key, value)
    end
  end

  @spec delete_key(StoreServer.database_name(), StoreServer.key()) ::
          {:error, :not_found} | {:ok, binary}
  def delete_key(database, key) do
    StoreServer.delete_key(database, key)
    |> send_response()
  end

  @spec delete_database(StoreServer.database_name()) :: :ok | {:error, :not_found}
  def delete_database(database) do
    StoreServer.delete_database(database)
    |> send_response()
  end

  defp send_response({:ok, value}) when is_binary(value) do
    {:ok, value}
  end

  defp send_response({:ok, %{}}) do
    :ok
  end

  defp send_response(_) do
    {:error, :not_found}
  end
end
