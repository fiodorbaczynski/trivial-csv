defmodule TrivialCsv.Validator do
  def apply(value, validators, metadata, static_data) do
    do_apply(value, validators, metadata, static_data)
  end

  defp do_apply(value, [validator | rest], metadata, static_data) do
    case validator.(value, metadata, static_data) do
      :ok -> do_apply(value, rest, metadata, static_data)
      error -> error
    end
  end

  defp do_apply(_, [], _, _) do
    :ok
  end
end
