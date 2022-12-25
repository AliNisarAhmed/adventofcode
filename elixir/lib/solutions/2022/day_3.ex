defmodule Aoe.Y22.Day3 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    # Input.read!(file)
    # Input.stream!(file)
    Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
  end

  @spec part_one(problem: Enum.t(String.t())) :: number()
  def part_one(problem) do
    priority = gen_priority_map()

    problem
    |> Stream.map(&split_string_in_half/1)
    |> Stream.map(&find_common_char/1)
    |> Stream.concat()
    |> Stream.map(fn c -> Map.get(priority, c, 0) end)
    |> Enum.sum()
  end

  @spec part_two(problem: Enum.t(String.t())) :: number()
  def part_two(problem) do
    priority = gen_priority_map()

    problem
    |> Stream.chunk_every(3)
    |> Stream.map(&find_common_char/1)
    |> Stream.concat()
    |> Stream.map(fn c -> Map.get(priority, c, 0) end)
    |> Enum.sum()
  end

  # ----------------------------------

  defp split_string_in_half(s) do
    String.split_at(s, trunc(String.length(s) / 2))
  end

  defp find_common_char({first, second}) do
    s1 = string_to_set(first)
    s2 = string_to_set(second)

    MapSet.intersection(s1, s2)
    |> MapSet.to_list()
  end

  defp find_common_char([first, second, third]) do
    s1 = string_to_set(first)
    s2 = string_to_set(second)
    s3 = string_to_set(third)

    MapSet.intersection(s1, s2)
    |> MapSet.intersection(s3)
    |> MapSet.to_list()
  end

  defp string_to_set(s) do
    s
    |> String.to_charlist()
    |> MapSet.new()
  end

  defp gen_priority_map() do
    ?a..?z
    |> Enum.zip(1..26)
    |> Enum.concat(?A..?Z |> Enum.zip(27..52))
    |> Enum.into(%{})
  end
end
