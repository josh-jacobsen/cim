defmodule Cim.Luerl do
  alias Cim.Store
  @cim "cim"
  @read "read"
  @write "write"
  @delete "delete"

  def execute(database, script) do
    {:ok, chunk, next_state} =
      init(database)
      |> load_script(script)

    case eval(next_state, chunk) do
      {:ok, value} ->
        {:ok, value}

      {:error, :value_not_found} ->
        {:error, :value_not_found}

      {:error, {:lua_error, {reason, _}}} ->
        {:error, {:lua_error, reason}}
    end
  end

  defp init(database) do
    read = read(database)
    write = write(database)
    delete = delete(database)

    initialize_luerl()
    |> set_table()
    |> set_table(@read, read)
    |> set_table(@write, write)
    |> set_table(@delete, delete)
  end

  defp initialize_luerl() do
    :luerl.init()
  end

  defp set_table(state) do
    :luerl.set_table([@cim], %{}, state)
  end

  defp set_table(state, function_name, function) do
    :luerl.set_table([@cim, function_name], function, state)
  end

  defp read(database) do
    fn [key | _], state ->
      value = Map.get(database, key)
      {[value], state}
    end
  end

  defp write(database) do
    fn [key, value | _], state ->
      {[put_in(database, [key], value)], state}
    end
  end

  defp delete(database) do
    fn [key | _], state ->
      {_deleted_key, new_database} = pop_in(database, [key])
      {[new_database], state}
    end
  end

  defp load_script(state, script) do
    :luerl.load(script, state)
  end

  defp eval(state, chunk) do
    case :luerl.eval(chunk, state) do
      {:error, {:lua_error, reason, _state}, _stack_trace} ->
        {:error, {:lua_error, reason}}

      {:ok, [value | _]} ->
        if value do
          {:ok, value}
        else
          {:error, :value_not_found}
        end
    end
  end
end
