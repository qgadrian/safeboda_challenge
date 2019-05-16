defmodule SafebodaTest do
  use ExUnit.Case
  doctest Safeboda

  test "greets the world" do
    assert Safeboda.hello() == :world
  end
end
