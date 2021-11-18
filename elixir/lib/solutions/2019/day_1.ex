defmodule Aoe.Y19.Day1 do
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
  end

  def part_one(list) do
    list
    |> Enum.to_list()
    |> Enum.map(&find_fuel_for_mass/1)
    |> Enum.sum()
  end

  def part_two(list) do
    list
    |> Enum.map(&find_fuel_for_mass/1)
    |> Enum.flat_map(&find_total_fuel/1)
    |> Enum.sum()
  end

  # ------------------------------------------

  def find_fuel_for_mass(n) do
    n
    |> Kernel./(3)
    |> floor()
    |> case do
      0 -> 0
      n -> n - 2
    end
  end

  def find_total_fuel(mass) do
    Stream.unfold(mass, fn
      n when n <= 0 -> nil
      n -> {n, find_fuel_for_mass(n)}
    end)
    |> Enum.to_list()
  end
end
