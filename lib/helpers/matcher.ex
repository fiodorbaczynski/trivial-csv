defmodule TrivialCsv.Matcher do
  def parse_schema({:ok, headers}, matchers) do
    {:ok, do_parse_schema(headers, matchers)}
  end

  def parse_schema({:error, _} = error, _), do: error

  def apply({:ok, row}, mapping) do
    {:ok, do_apply(row, mapping)}
  end

  def apply({:error, _} = error, _), do: error

  defp do_apply(_, _, _acc \\ %{})

  defp do_apply(row, [{column_name, column_index} | rest], acc) do
    column_value =
      case column_index do
        nil -> nil
        _ -> Enum.at(row, column_index)
      end

    do_apply(row, rest, Map.put(acc, column_name, column_value))
  end

  defp do_apply(_, [], acc), do: acc

  defp do_parse_schema(_, _, _acc \\ [])

  defp do_parse_schema(headers, [%{column_name: name, rules: rules} | rest], acc) do
    do_parse_schema(headers, rest, [{name, apply_rules(headers, rules)} | acc])
  end

  defp do_parse_schema(_, [], acc), do: acc

  defp apply_rules(headers, [{needle, comparator, options} | rest]) do
    case Enum.find_index(headers, fn header ->
           {header, needle}
           |> apply_options(options)
           |> apply_comparison(comparator)
         end) do
      nil -> apply_rules(headers, rest)
      index -> index
    end
  end

  defp apply_rules(_, []), do: nil

  def apply_comparison({e, f}, comparator) do
    case comparator do
      :is -> e == f
      :contains -> f =~ e
      :is_contained -> e =~ f
    end
  end

  defp apply_options(v, [option | rest]) do
    case option do
      :case_insensitive ->
        apply_options(case_insensitive(v), rest)

      _ ->
        apply_options(v, rest)
    end
  end

  defp apply_options(v, []), do: v

  defp case_insensitive({e, f}) do
    {String.downcase(e), String.downcase(f)}
  end
end
