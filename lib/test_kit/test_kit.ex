defmodule TrivialCsv.TestKit do
  defmacro __using__(opts) do
    tmp_path = "#{File.cwd!()}/test/support/tmp"
    schema = Keyword.get(opts, :schema, [])

    make_tmp_dir(tmp_path)

    quote do
      import TrivialCsv.TestKit

      @tmp_path unquote(tmp_path)
      @schema unquote(schema)
    end
  end

  def make_tmp_dir(tmp_path) do
    unless File.dir?(tmp_path) do
      File.mkdir!(tmp_path)
    end
  end
end
