defmodule TrivialCsv.TestKit.Factory do
  defmacro __using__(_opts) do
    tmp_path = "#{File.cwd!()}/test/support/tmp"

    quote do
      import TrivialCsv.TestKit.Factory

      @csv_columns []
      @tmp_path unquote(tmp_path)

      def map_entities(columns, entities) do
        Enum.map(entities, fn entity ->
          Enum.map(columns, fn
            {_, entity_keys, reverse_mapping} ->
              apply(__MODULE__, reverse_mapping, [entity |> get_by_keys(entity_keys)])

            {_, entity_keys} ->
              get_by_keys(entity, entity_keys)
          end)
        end)
      end

      defmacro __using__(_opts, do: block) do
        quote do
          unquote(block).()
        end
      end
    end
  end

  defmacro test_file(name, do: block) do
    quote do
      @csv_columns []

      unquote(block)

      csv_columns = @csv_columns

      def generate_file(unquote(name), entities) do
        generate_csv(
          "#{@tmp_path}/#{generate_random_name()}.csv",
          map_columns(@csv_columns),
          map_entities(@csv_columns, entities)
        )
      end
    end
  end

  defmacro column(name, entity_key) do
    quote do
      @csv_columns [
        {unquote(name), unquote(entity_key)}
        | @csv_columns
      ]
    end
  end

  defmacro column(name, entity_key, reverse_mapping) do
    quote do
      @csv_columns [
        {unquote(name), unquote(entity_key), unquote(reverse_mapping)}
        | @csv_columns
      ]
    end
  end

  defmacro map(fun) do
    fun_name = String.to_atom(generate_random_name())

    quote do
      def unquote(fun_name)(entity) do
        unquote(fun).(entity)
      end

      unquote(fun_name)
    end
  end

  def generate_random_name do
    64
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, 32)
  end

  def get_by_keys(entity, entity_key) when is_atom(entity_key) do
    Map.get(entity, entity_key, nil)
  end

  def get_by_keys(entity, entity_keys) when is_list(entity_keys) do
    get_in(entity, entity_keys)
  end

  def map_columns(columns) do
    Enum.map(columns, fn
      {name, _, _} -> name
      {name, _} -> name
    end)
  end

  def generate_csv(file_path, column_names, rows) do
    file = File.open!(file_path, [:write, :utf8])

    [column_names | rows]
    |> CSV.encode()
    |> Enum.each(&IO.write(file, &1))

    file_path
  end
end
