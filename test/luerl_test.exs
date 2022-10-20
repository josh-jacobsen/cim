defmodule Cim.LuerlTest do
  use ExUnit.Case

  alias Cim.Luerl

  test "Reads key from database" do
    {:ok, result, _state} = Luerl.execute("return cim.read(\"key\")", %{"key" => "my_key"})
    assert result == "my_key"
  end

  test "Writes key to database" do
    {:ok, result, state} =
      Luerl.execute("return cim.write(\"key223\", \"my_value23\")", %{"key" => "my_key"})

    assert result == "my_value23"
    assert state == %{"key" => "my_key", "key223" => "my_value23"}
  end

  test "Deletes key from database" do
    {:ok, result, state} =
      Luerl.execute("return cim.delete(\"key223\")", %{
        "key" => "my_key",
        "key223" => "my_value23"
      })

    assert result == "true"
    assert state == %{"key" => "my_key"}
  end

  test "Returns nil if key to read does not exist" do
    {:ok, result, _state} =
      Luerl.execute("return cim.read(\"key_does_not_exist\")", %{"key" => "my_key"})

    assert result == ""
  end

  test "Writing same key to database overwrites existing value" do
    {:ok, result, state} =
      Luerl.execute("return cim.write(\"key\", \"new_value\")", %{"key" => "old_value"})

    assert result == "new_value"
    assert state == %{"key" => "new_value"}
  end

  test "Raises error for invalid lua code" do
    result =
      Luerl.execute("return cim.undefined_method(\"key\", \"new_value\")", %{
        "key" => "old_value"
      })

    assert {:error, _} = result
  end
end
