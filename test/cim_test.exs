defmodule CimTest do
  use ExUnit.Case
  doctest Cim

  test "greets the world" do
    assert Cim.hello() == :world
  end
end
