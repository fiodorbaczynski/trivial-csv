defmodule TrivialCsv.Schema do
  defmacro __using__(_opts) do
    quote do
      import TrivialCsv.Schema

      @matchers []
      @column_matchers []
      @columns []
      @composition nil
      @fields []
      @models []
      @schema nil

      @processing :schema
      @precessing_model nil
      @processing_field nil
      @processing_column nil

      @schema_validations []
      @model_validations []
      @field_validations []
      @column_validations []

      @schema_parsers []
      @model_parsers []
      @field_parsers []
      @column_parsers []
    end
  end

  defmacro match(needle, strategy, options) do
    quote do
      @column_matchers [
        {unquote(needle), unquote(strategy), unquote(options)}
        | @column_matchers
      ]
    end
  end

  defmacro column(name, do: block) do
    quote do
      @processing :column
      @processing_column unquote(name)
      @column_matchers []

      @column_validations []
      @column_parsers []

      unquote(block)

      @matchers [
        %{
          model_name: @processing_model,
          field_name: @processing_field,
          column_name: @processing_column,
          rules: @column_matchers
        }
        | @matchers
      ]

      @columns [
        %{
          name: unquote(name),
          validations: @column_validations,
          parsers: @column_parsers
        }
        | @columns
      ]
    end
  end

  defmacro field(name, do: block) do
    quote do
      @processing :field
      @processing_field unquote(name)
      @field_validations []
      @field_parsers []
      @columns []
      @composition nil

      unquote(block)

      @fields [
        %{
          name: unquote(name),
          columns: @columns,
          composition: @composition,
          validations: @field_validations,
          parsers: @field_parsers
        }
        | @fields
      ]
    end
  end

  defmacro model(name, do: block) do
    quote do
      @processing :model
      @processing_model unquote(name)
      @model_validations []
      @model_parsers []
      @fields []

      unquote(block)

      @models [
        %{
          name: unquote(name),
          validations: @model_validations,
          parsers: @model_parsers,
          fields: @fields
        }
        | @models
      ]
    end
  end

  defmacro schema(name, do: block) do
    function_name = String.to_atom(name <> "_schema")

    quote do
      @processing :schema
      @schema_validations []
      @schema_parsers []
      @matchers []
      @models []

      unquote(block)

      @schema %{
        models: @models,
        matchers: @matchers,
        name: unquote(name)
      }

      def unquote(function_name)(), do: @schema
    end
  end

  defmacro compose(function) do
    quote do
      @composition unquote(function)
    end
  end

  defmacro validate(function) do
    quote do
      case @processing do
        :schema ->
          @schema_validations [unquote(function) | @schema_validations]

        :model ->
          @model_validations [unquote(function) | @model_validations]

        :field ->
          @field_validations [unquote(function) | @field_validations]

        :column ->
          @column_validations [unquote(function) | @column_validations]
      end
    end
  end

  defmacro parse(function) do
    quote do
      case @processing do
        :schema ->
          @schema_parsers [unquote(function) | @schema_parsers]

        :model ->
          @model_parsers [unquote(function) | @model_parsers]

        :field ->
          @field_parsers [unquote(function) | @field_parsers]

        :column ->
          @column_parsers [unquote(function) | @column_parsers]
      end
    end
  end
end
