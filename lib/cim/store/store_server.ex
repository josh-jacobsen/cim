defmodule Cim.StoreServer do
  @moduledoc """
  Implementation of the database server
  """

  use GenServer

  @type value :: binary
  @type database_name :: binary
  @type key :: binary
  @type database :: map()

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl GenServer
  @spec init(any) :: {:ok, any}
  def init(state) do
    {:ok, state}
  end

  @spec retrieve_key(database_name(), key()) :: {:ok, value()} | {:ok, nil}
  def retrieve_key(database_name, key) do
    GenServer.call(__MODULE__, {:retrieve_key, database_name, key})
  end

  def retrieve_database(database_name) do
    GenServer.call(__MODULE__, {:retrieve_database, database_name})
  end

  @spec put_key_new_database(database_name(), key(), value()) :: :ok
  def put_key_new_database(database_name, key, value) do
    GenServer.call(__MODULE__, {:put_key_new_database, database_name, key, value})
  end

  @spec put_key_existing_database(database_name(), key(), value()) :: :ok
  def put_key_existing_database(database_name, key, value) do
    GenServer.call(__MODULE__, {:put_key_existing_database, database_name, key, value})
  end

  @spec delete_key(database_name(), key()) :: {:ok, value()} | {:ok, nil}
  def delete_key(database_name, key) do
    GenServer.call(__MODULE__, {:delete_key, database_name, key})
  end

  @spec delete_database(database_name()) :: {:ok, database} | {:ok, nil}
  def delete_database(database_name) do
    GenServer.call(__MODULE__, {:delete_database, database_name})
  end

  @spec database_exists?(database_name()) :: boolean()
  def database_exists?(database_name) do
    GenServer.call(__MODULE__, {:database_exists, database_name})
  end

  @impl GenServer
  def handle_call({:retrieve_key, database, key}, _from, state) do
    {:reply, {:ok, get_in(state, [database, key])}, state}
  end

  @impl GenServer
  def handle_call({:put_key_new_database, database, key, value}, _from, state) do
    {:reply, :ok, Map.put(state, database, %{key => value})}
  end

  @impl GenServer
  def handle_call({:put_key_existing_database, database, key, value}, _from, state) do
    {:reply, :ok, put_in(state, [database, key], value)}
  end

  @impl GenServer
  def handle_call({:delete_key, database, key}, _from, state) do
    {deleted_key, new_state} = pop_in(state, [database, key])
    {:reply, {:ok, deleted_key}, new_state}
  end

  @impl GenServer
  def handle_call({:delete_database, database}, _from, state) do
    {deleted_database, new_state} = Map.pop(state, database)
    {:reply, {:ok, deleted_database}, new_state}
  end

  @impl GenServer
  def handle_call({:database_exists, database}, _from, state) do
    {:reply, Map.has_key?(state, database), state}
  end

  @impl GenServer
  def handle_call({:retrieve_database, database}, _from, state) do
    {:reply, Map.get(state, database), state}
  end
end
