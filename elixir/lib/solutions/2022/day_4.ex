defmodule Aoe.Y22.Day4 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: Enum.t({Enum.t(number()), Enum.t(number())})

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    # Input.read!(file)
    # Input.stream!(file)
    Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> Enum.map(fn s ->
      [first_pair, second_pair] = String.split(s, ",", trim: true)

      first_pair = split_pair_and_parse(first_pair)

      second_pair = split_pair_and_parse(second_pair)

      {first_pair, second_pair}
    end)
  end

  def part_one(problem) do
    problem
    |> Enum.count(&part_one_condition/1)
  end

  def part_two(problem) do
    problem
    |> Enum.count(&part_two_condition/1)
  end

  # --------------------------------------------

  defp part_one_condition({[n1, n2], [m1, m2]}) do
    (m1 <= n1 && m2 >= n2) or (n1 <= m1 && n2 >= m2)
  end

  defp part_two_condition({[x1, y1], [x2, y2]}) do
    (x2 >= x1 && x2 <= y1) or
      (y2 >= x1 && y2 <= y1) or
      (x1 >= x2 && x1 <= y2) or
      (y1 >= x2 && y1 <= y2)
  end

  defp split_pair_and_parse(pair) do
    pair
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
  end
end
