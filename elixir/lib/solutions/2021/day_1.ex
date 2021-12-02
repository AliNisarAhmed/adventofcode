defmodule Aoe.Y21.Day1 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> Input.stream_to_integers()
    |> Enum.to_list()
  end

  def part_one(problem) do
    Enum.zip_reduce(
      problem,
      Enum.drop(problem, 1),
      0,
      fn n1, n2, acc ->
        if n2 > n1 do
          acc + 1
        else
          acc
        end
      end
    )
  end

  def part_two(problem) do
    sumWindow(problem, Enum.drop(problem, 1), 0)
  end

  def sumWindow([x1, y1, z1 | rest1], [x2, y2, z2 | rest2], acc) do
    if x2 + y2 + z2 > x1 + y1 + z1 do
      sumWindow([y1, z1 | rest1], [y2, z2 | rest2], acc + 1)
    else
      sumWindow([y1, z1 | rest1], [y2, z2 | rest2], acc)
    end
  end

  def sumWindow(_, _, acc), do: acc
end
