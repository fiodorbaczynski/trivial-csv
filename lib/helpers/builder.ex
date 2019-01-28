defmodule TrivialCsv.Builder do
  alias TrivialCsv.Validator
  alias TrivialCsv.Parser
  alias TrivialCsv.Composer

  def build_row({:ok, row}, models, static_data) do
    case build_models(row, models, static_data) do
      {:error, _} = error -> error
      models -> {:ok, models}
    end
  end

  def build_row({:error, _} = error, _, _), do: error

  def build_row({:error, _, _} = error, _, _), do: error

  defp build_models(_, _, _, acc \\ %{})

  defp build_models(
         values,
         [%{name: name, validations: validations, fields: fields_meta, parsers: parsers} | rest],
         static_data,
         acc
       ) do
    processing_metadata = {:model, name}

    with model when is_map(model) <- build_fields(values, fields_meta, static_data),
         :ok <- Validator.apply(model, validations, processing_metadata, static_data),
         {:ok, model} <- Parser.apply(model, parsers, processing_metadata, static_data) do
      build_models(values, rest, static_data, Map.put(acc, name, model))
    else
      {:error, _} = error -> error
    end
  end

  defp build_models(_, [], _, acc), do: acc

  defp build_fields(_, _, _, acc \\ %{})

  defp build_fields(
         values,
         [
           %{
             name: name,
             validations: validations,
             parsers: parsers,
             composition: composition,
             columns: columns_meta
           }
           | rest
         ],
         static_data,
         acc
       ) do
    processing_metadata = {:field, name}

    with columns when is_map(columns) <- build_columns(values, columns_meta, static_data),
         field <- Composer.apply(columns, composition, processing_metadata),
         :ok <- Validator.apply(field, validations, processing_metadata, static_data),
         {:ok, field} <- Parser.apply(field, parsers, processing_metadata, static_data) do
      build_fields(values, rest, static_data, Map.put(acc, name, field))
    else
      {:error, _} = error -> error
    end
  end

  defp build_fields(_, [], _, acc), do: acc

  defp build_columns(_, _, _, _acc \\ %{})

  defp build_columns(
         values,
         [%{name: name, validations: validations, parsers: parsers} | rest],
         static_data,
         acc
       ) do
    processing_metadata = {:column, name}

    with value when not is_nil(value) <- Map.get(values, name, nil),
         :ok <- Validator.apply(value, validations, processing_metadata, static_data),
         {:ok, value} <- Parser.apply(value, parsers, processing_metadata, static_data) do
      build_columns(values, rest, static_data, Map.put(acc, name, value))
    else
      nil -> {:error, "Column #{name} does not exists"}
      {:error, _} = error -> error
    end
  end

  defp build_columns(_, [], _, acc), do: acc
end
