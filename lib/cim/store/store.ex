defmodule Cim.Store do
  use GenServer

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  @spec init(any) :: {:ok, any}
  def init(state) do
    {:ok, state}
  end

  @spec retrieve_key(String.t(), String.t()) :: {:error, :not_found} | {:ok, binary}
  def retrieve_key(database, key) do
    retrieve_key_from_database(database, key)
    |> send_response()
  end

  @spec put_key(String.t(), String.t(), String.t()) :: :ok
  def put_key(database, key, value) do
    if database_exists?(database) do
      put_key_in_existing_database(database, key, value)
    else
      put_key_in_new_database(database, key, value)
    end
  end

  @spec delete_key(String.t(), String.t()) :: {:error, :not_found} | {:ok, binary}
  def delete_key(database, key) do
    delete_key_from_database(database, key)
    |> send_response()
  end

  @spec delete_database(String.t()) :: {:error, :not_found} | {:ok, binary}
  def delete_database(database) do
    delete_database_from_store(database)
    |> send_response()
  end

  defp put_key_in_new_database(database, key, value) do
    GenServer.call(__MODULE__, {:put_key_new_database, database, key, value})
  end

  defp put_key_in_existing_database(database, key, value) do
    GenServer.call(__MODULE__, {:put_key_existing_database, database, key, value})
  end

  defp delete_key_from_database(database, key) do
    GenServer.call(__MODULE__, {:delete_key, database, key})
  end

  defp delete_database_from_store(database) do
    GenServer.call(__MODULE__, {:delete_database, database})
  end

  defp database_exists?(database) do
    GenServer.call(__MODULE__, {:database_exists, database})
  end

  defp retrieve_key_from_database(database, key) do
    GenServer.call(__MODULE__, {:retrieve_key, database, key})
  end

  defp send_response({:ok, value}) when is_binary(value) do
    {:ok, value}
  end

  defp send_response({:ok, %{} = value}) do
    {:ok, value}
  end

  defp send_response(_) do
    {:error, :not_found}
  end

  @impl true
  def handle_call({:put_key_existing_database, database, key, value}, _from, state) do
    {:reply, :ok, put_in(state, [database, key], value)}
  end

  @impl true
  def handle_call({:delete_database, database}, _from, state) do
    {deleted_database, new_state} = Map.pop(state, database)
    {:reply, {:ok, deleted_database}, new_state}
  end

  @impl true
  def handle_call({:database_exists, database}, _from, state) do
    {:reply, Map.has_key?(state, database), state}
  end

  @impl true
  def handle_call({:delete_key, database, key}, _from, state) do
    {deleted_key, new_state} = pop_in(state, [database, key])
    {:reply, {:ok, deleted_key}, new_state}
  end

  @impl true
  def handle_call({:retrieve_key, database, key}, _from, state) do
    {:reply, {:ok, get_in(state, [database, key])}, state}
  end

  @impl true
  def handle_call({:put_key_new_database, database, key, value}, _from, state) do
    {:reply, :ok, Map.put(state, database, %{key => value})}
  end
end
