defmodule Aoe.Y19.Day3 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any
  @type path :: {direction, integer()}
  @type direction :: :right | :left | :up | :down
  @type coords :: {integer(), integer(), integer()}

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> Stream.map(
      &(&1
        |> String.split(",")
        |> Enum.map(fn str -> parse_path(str) end))
    )
    |> Enum.to_list()
  end

  def part_one([list1, list2]) do
    path_points_1 =
      get_path_points(list1)
      |> MapSet.new()

    path_points_2 =
      get_path_points(list2)
      |> MapSet.new()

    MapSet.intersection(path_points_1, path_points_2)
    |> MapSet.to_list()
    |> Enum.map(&manhattan_distance/1)
    |> Enum.sort(:asc)
    |> List.first()
  end

  def part_two([list1, list2]) do
    path_points_1 =
      get_path_points(list1)
      |> Enum.into(%{}, &transform_to_map/1)

    path_points_2 =
      get_path_points(list2)
      |> Enum.into(%{}, &transform_to_map/1)

    common =
      Enum.reduce(path_points_1, %{}, fn {k, steps}, acc ->
        if Map.has_key?(path_points_2, k) do
          Map.put(acc, k, steps + Map.get(path_points_2, k))
        else
          acc
        end
      end)

    common
    |> Map.to_list()
    |> Enum.min_by(fn {_, v} -> v end)
    |> Kernel.elem(1)
  end

  # ----------------------------------------------------

  @spec transform_to_map(coords()) :: {{integer(), integer()}, integer()}
  def transform_to_map({x, y, steps}), do: {{x, y}, steps}

  @spec manhattan_distance(coords()) :: integer()
  def manhattan_distance({x, y, _}), do: abs(x) + abs(y)

  @spec get_path_points(list(path())) :: list(coords())
  def get_path_points(list) do
    list
    |> Enum.reduce({{0, 0, 0}, []}, fn path, {current_point, previous_list} ->
      {next_point, new_list} = move_in_direction(current_point, path)
      {next_point, previous_list ++ new_list}
    end)
    |> Kernel.elem(1)
    |> Enum.drop(1)
  end

  @spec move_in_direction(coords(), path()) :: {coords, list(coords())}
  def move_in_direction({x, y, init_steps}, {:right, units}) do
    list =
      for unit <- 1..units do
        {x + unit, y, init_steps + unit}
      end

    {{x + units, y, init_steps + units}, list}
  end

  def move_in_direction({x, y, init_steps}, {:left, units}) do
    list =
      for unit <- 1..units do
        {x - unit, y, init_steps + unit}
      end

    {{x - units, y, init_steps + units}, list}
  end

  def move_in_direction({x, y, init_steps}, {:up, units}) do
    list =
      for unit <- 1..units do
        {x, y + unit, init_steps + unit}
      end

    {{x, y + units, init_steps + units}, list}
  end

  def move_in_direction({x, y, init_steps}, {:down, units}) do
    list =
      for unit <- 1..units do
        {x, y - unit, init_steps + unit}
      end

    {{x, y - units, init_steps + units}, list}
  end

  @spec parse_path(binary()) :: path()
  def parse_path("R" <> rest) do
    {:right, String.to_integer(rest)}
  end

  def parse_path("U" <> rest) do
    {:up, String.to_integer(rest)}
  end

  def parse_path("D" <> rest) do
    {:down, String.to_integer(rest)}
  end

  def parse_path("L" <> rest) do
    {:left, String.to_integer(rest)}
  end
end
