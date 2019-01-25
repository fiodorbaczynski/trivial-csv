defmodule Mix.Tasks.CsvCleanup do
  @moduledoc """
  This Mix Task removes the tmp directory used for CSV tests

  It should be added as a part of the test alias in mix.exs (after the actual test task)

  Example:

  test: ["ecto.create --quiet", "ecto.migrate", "test", "csv_cleanup"]
  """

  use Mix.Task

  require Logger

  @tmp_dir "./test/support/tmp"

  def run(_) do
    case remove_tmp_dir() do
      {:ok, _} -> Logger.info("CSV cleanup done.")
      _ -> Logger.warn("CSV cleanup failed!")
    end
  end

  defp remove_tmp_dir() do
    case File.dir?(@tmp_dir |> IO.inspect()) |> IO.inspect() do
      true -> File.rm_rf(@tmp_dir)
      false -> {:ok, nil}
    end
  end
end
