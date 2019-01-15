defmodule TrivialCsv.Parser do
  def apply(value, parsers, metadata, static_data) do
    do_apply(value, parsers, metadata, static_data)
  end

  defp do_apply(value, [parser | rest], metadata, static_data) do
    case parser.(value, metadata, static_data) do
      {:ok, v} -> do_apply(v, rest, metadata, static_data)
      error -> error
    end
  end

  defp do_apply(value, [], _, _) do
    {:ok, value}
  end
end
