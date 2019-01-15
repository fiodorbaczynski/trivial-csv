defmodule TrivialCsv.Composer do
  def apply(columns, nil, _metadata) do
    column_keys = Map.keys(columns)

    case length(column_keys) do
      1 -> Map.get(columns, List.first(column_keys))
      _ -> columns
    end
  end

  def apply(columns, composition, metadata) do
    composition.(columns, metadata)
  end
end
