defmodule TrivialCsv do
  alias TrivialCsv.Matcher
  alias TrivialCsv.Builder

  defmacro __using__(opts \\ []) do
    schema = Keyword.get(opts, :schema, [])
    static_data = Keyword.get(opts, :static_data, [])
    {%{name: schema_name}, _} = Code.eval_quoted(schema)

    parse_fun_name = String.to_atom("do_parse_" <> schema_name)

    quote do
      import TrivialCsv

      def unquote(parse_fun_name)(file_path) do
        with {:ok, headers, rows} <- stream_file(file_path),
             %{models: models, name: name, matchers: matchers} <- unquote(schema),
             static_data <- parse_static_data(unquote(static_data)),
             {:ok, columns_mapping} <- Matcher.parse_schema(headers, matchers) do
          rows
          |> Stream.map(fn row ->
            row
            |> Matcher.apply(columns_mapping)
            |> Builder.build_row(models, static_data)
          end)
        else
          {:error, _} = error -> error
          %{} -> {:error, "Invalid schema"}
        end
      end
    end
  end

  def parse_static_data(getter_functions) do
    Enum.reduce(getter_functions, %{}, fn {key, fun}, acc -> Map.put(acc, key, fun.()) end)
  end

  def stream_file(file_path) do
    file_stream =
      file_path
      |> File.stream!()
      |> CSV.decode()

    headers = file_stream |> Stream.take(1) |> Enum.at(0)
    rows = Stream.drop(file_stream, 1)

    {:ok, headers, rows}
  rescue
    _ -> {:error, "File does not exist or is corrupted"}
  end
end
