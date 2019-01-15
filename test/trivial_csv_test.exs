defmodule TrivialCsvTest do
  use ExUnit.Case
  doctest TrivialCsv

  test "greets the world" do
    assert TrivialCsv.hello() == :world
  end
end
