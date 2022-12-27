defmodule Aoe.Y22.Day2 do
  alias Aoe.Input, warn: false

  # Rules
  # Rock     > Scissors
  # Scissors > Paper
  # Paper    > Rock

  # Part 1
  # ABC -> Rock Paper Scissors
  # XYZ -> Rock Paper Scissors

  @winning_pairs [["A", "Y"], ["B", "Z"], ["C", "X"]]
  @losing_pairs [["B", "X"], ["C", "Y"], ["A", "Z"]]

  @move_points %{
    "X" => 1,
    "Y" => 2,
    "Z" => 3
  }

  # Part 2
  # X -> Lose
  # Y -> Draw
  # Z -> Win

  @play_rock [
    ["A", "Y"],
    ["B", "X"],
    ["C", "Z"]
  ]

  @play_paper [
    ["B", "Y"],
    ["C", "X"],
    ["A", "Z"]
  ]

  @play_scissors [
    ["C", "Y"],
    ["A", "X"],
    ["B", "Z"]
  ]

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: Enum.t(Enum.t(String.t()))

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    # Input.read!(file)
    # Input.stream!(file)
    Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> Enum.map(&String.split(&1, " "))
  end

  def part_one(problem) do
    problem
    |> Enum.map(&calculate_points/1)
    |> Enum.sum()
  end

  def part_two(problem) do
    problem
    |> Enum.map(&calculate_human_move/1)
    |> Enum.map(&calculate_points/1)
    |> Enum.sum()
  end

  # -----------------------------

  defp calculate_points([_c, h] = pair) do
    calculate_victory_points(pair) + calculate_move_points(h)
  end

  defp calculate_move_points(s) do
    Map.get(@move_points, s, 0)
  end

  defp calculate_victory_points(pair) when pair in @winning_pairs, do: 6
  defp calculate_victory_points(pair) when pair in @losing_pairs, do: 0
  defp calculate_victory_points(_), do: 3

  # ---------------------------------

  defp calculate_human_move([c, _h] = pair) when pair in @play_rock, do: [c, "X"]
  defp calculate_human_move([c, _h] = pair) when pair in @play_paper, do: [c, "Y"]
  defp calculate_human_move([c, _h] = pair) when pair in @play_scissors, do: [c, "Z"]
end
