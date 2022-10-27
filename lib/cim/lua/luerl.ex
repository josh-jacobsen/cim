defmodule Cim.Luerl do
  @moduledoc """
  Custom module that wraps the luerl library
  """

  @spec execute(String.t(), map()) :: {:ok, String.t(), map()} | {:error, any()}
  def execute(code, values) do
    init()
    |> set_trace_data(values)
    |> set_table([:cim], %{})
    |> set_table([:cim, :read], &read/2)
    |> set_table([:cim, :write], &write/2)
    |> set_table([:cim, :delete], &delete/2)
    |> exec(code)
    |> case do
      {:ok, [result], state} ->
        {:ok, to_string(result), get_trace_data(state)}

      {:error, reason} ->
        {:error, {:lua_error, reason}}
    end
  end

  defp read([field], state) do
    {[Map.get(get_trace_data(state), field)], state}
  end

  defp write([field, value], state) do
    value = to_string(value)

    new_values =
      get_trace_data(state)
      |> Map.put(to_string(field), value)

    {[value], set_trace_data(state, new_values)}
  end

  defp delete([field], state) do
    new_values =
      get_trace_data(state)
      |> Map.delete(field)

    {[true], set_trace_data(state, new_values)}
  end

  defp init do
    :luerl.init()
  end

  defp set_table(state, key_path, value) when is_list(key_path) do
    :luerl.set_table(key_path, value, state)
  end

  defp exec(state, code) do
    {result, state} = :luerl.do(code, state)
    {:ok, result, state}
  rescue
    e -> {:error, e}
  end

  defp get_trace_data(state) do
    :luerl.get_trace_data(state)
  end

  defp set_trace_data(state, data) do
    :luerl.set_trace_data(data, state)
  end
end
