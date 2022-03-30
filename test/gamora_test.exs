defmodule GamoraTest do
  use ExUnit.Case
  doctest Gamora

  test "greets the world" do
    assert Gamora.hello() == :world
  end
end
