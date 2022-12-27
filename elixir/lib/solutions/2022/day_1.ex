defmodule Aoe.Y22.Day1 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: Enum.t(number())

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    # Input.read!(file)
    # Input.stream!(file)
    # Input.stream_file_lines(file, trim: true)
    file
    |> File.read!()
  end

  @spec parse_input!(input, part) :: Stream.t(number())
  def parse_input!(input, _part) do
    input
    |> String.split("\n\n")
    |> Stream.map(fn s ->
      s
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    end)
  end

  def part_one(problem) do
    problem
    |> Enum.with_index()
    |> Enum.max_by(fn {sum, _i} -> sum end)
  end

  def part_two(problem) do
    problem
    |> Stream.with_index()
    |> Enum.sort_by(fn {s, _i} -> s end, :desc)
    |> Enum.take(3)
    |> Enum.reduce(0, fn {s, _}, acc -> acc + s end)
  end
end
