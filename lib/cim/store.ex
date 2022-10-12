defmodule Cim.Store do
  use Agent

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  @doc """
  Starts the in-memory database.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec retrieve_key(String.t(), String.t()) :: {:error, :key_not_found} | {:ok, String.t()}
  @doc """
  Gets a value from the in-memory database by `key`.
  """
  def retrieve_key(database, key) do
    case retrieve_key_from_database(database, key) do
      {:ok, value} -> {:ok, value}
      {:error, :key_not_found} -> {:error, :key_not_found}
    end
  end

  defp retrieve_key_from_database(database, key) do
    Agent.get(__MODULE__, fn state ->
      value = get_in(state, [database, key])

      if value do
        {:ok, value}
      else
        {:error, :key_not_found}
      end
    end)
  end

  @spec put_key(any, any, any) :: :ok
  @doc """
  Puts the `value` for the given `key` in the in-memory database.
  """
  def put_key(database, key, value) do
    if database_exists?(database) do
      put_key_in_existing_database(database, key, value)
    else
      put_key_in_new_database(database, key, value)
    end
  end

  defp database_exists?(database) do
    Agent.get(__MODULE__, fn state ->
      Map.has_key?(state, database)
    end)
  end

  defp put_key_in_existing_database(database, key, value) do
    Agent.update(__MODULE__, fn state ->
      put_in(state, [database, key], value)
    end)
  end

  defp put_key_in_new_database(database, key, value) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, database, %{key => value})
    end)
  end

  @spec delete_database(String.t()) :: :ok | {:error, :database_not_found}
  def delete_database(database) do
    if database_exists?(database) do
      delete_database_from_store(database)
    else
      {:error, :database_not_found}
    end
  end

  defp delete_database_from_store(database) do
    Agent.update(__MODULE__, fn state -> Map.delete(state, database) end)
  end

  @spec delete_key(any, any) :: :ok | {:error, :key_not_found}
  def delete_key(database, key) do
    case retrieve_key(database, key) do
      {:ok, _value} ->
        delete_key_from_database(database, key)

      {:error, :key_not_found} ->
        {:error, :key_not_found}
    end
  end

  defp delete_key_from_database(database, key) do
    Agent.update(__MODULE__, fn state ->
      pop_in(state, [database, key]) |> elem(1)
    end)
  end

  @spec hello :: :world
  def hello() do
    :world
  end
end
