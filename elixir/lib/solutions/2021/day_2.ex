defmodule Aoe.Y21.Day2 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any
  @type direction :: :forward | :up | :down
  @type coords :: {integer(), integer()}

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    # Input.read!(file)
    # Input.stream!(file)
    Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> Stream.map(fn s ->
      s
      |> String.split(" ", trim: true)
      |> parse_direction()
    end)
    |> Enum.to_list()
  end

  def part_one(problem) do
    problem
    |> Enum.reduce({0, 0}, fn
      {:forward, n}, {x, y} -> {x + n, y}
      {:down, n}, {x, y} -> {x, y + n}
      {:up, n}, {x, y} -> {x, y - n}
    end)
    |> then(fn {x, y} -> x * y end)
  end

  def part_two(problem) do
    problem
    |> Enum.reduce({0, 0, 0}, fn
      {:forward, n}, {x, y, aim} -> {x + n, y + aim * n, aim}
      {:down, n}, {x, y, aim} -> {x, y, aim + n}
      {:up, n}, {x, y, aim} -> {x, y, aim - n}
    end)
    |> then(fn {x, y, _aim} -> x * y end)
  end

  # ------------------

  def parse_direction(["forward", s]), do: {:forward, String.to_integer(s)}
  def parse_direction(["down", s]), do: {:down, String.to_integer(s)}
  def parse_direction(["up", s]), do: {:up, String.to_integer(s)}
end
