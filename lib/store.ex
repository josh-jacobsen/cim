defmodule Cim.Store do
  use Agent

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  @doc """
  Starts the in-memory database.
  """
  def start_link(_opts) do
    IO.puts("agent started")

    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec retrieve_key(any, any) :: {:error, :not_found} | {:ok, any}
  @doc """
  Gets a value from the in-memory database by `key`.
  """
  def retrieve_key(database, key) do
    value =
      Agent.get(__MODULE__, fn state ->
        get_in(state, [database, key])
      end)

    if value do
      {:ok, value}
    else
      {:error, :not_found}
    end
  end

  @spec put_key(any, any, any) :: :ok
  @doc """
  Puts the `value` for the given `key` in the in-memory database.
  """
  def put_key(database, key, value) do
    Agent.update(__MODULE__, fn state ->
      existing_database = Map.get(state, database)

      if existing_database do
        Map.put(state, database, Map.put(existing_database, key, value))
      else
        # TODO: There must be a better way of adding nested Map (Kernel.put_in() does not work if key is not already defined)
        Map.put(state, database, %{key => value})
      end
    end)
  end

  @spec delete_database(any) :: :ok | {:error, :database_not_found}
  def delete_database(database) do
    value =
      Agent.get(__MODULE__, fn state ->
        if Map.has_key?(state, database) do
          {:ok, :database_found}
        else
          {:error, :database_not_found}
        end
      end)

    case value do
      {:ok, :database_found} ->
        Agent.update(__MODULE__, fn state -> Map.delete(state, database) end)

      {:error, :database_not_found} ->
        {:error, :database_not_found}
    end
  end

  @spec delete_key(any, any) :: :ok | {:error, :key_not_found}
  def delete_key(database, key) do
    case retrieve_key(database, key) do
      {:ok, _value} ->
        Agent.update(__MODULE__, fn state ->
          existing_database = Map.get(state, database)
          new_database = Map.delete(existing_database, key)
          Map.replace(state, existing_database, new_database)
        end)

      {:error, :not_found} ->
        {:error, :key_not_found}
    end
  end

  @spec hello :: :world
  def hello() do
    :world
  end
end
