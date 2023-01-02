defmodule Aoe.Y22.Day15 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any

  @target_y 2_000_000

  @coord_max 4_000_000
  @freq_max 4_000_000

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_sensor_and_beacon/1)
  end

  def part_one(problem) do
    {start_x, end_x} = find_start_and_end_x(problem)

    distance_map = calc_distance_map(problem)

    max_manhattan_distance = find_max_manhattan_distance(distance_map)

    (start_x - max_manhattan_distance)..(end_x + max_manhattan_distance)
    |> convert_to_coords()
    |> check_sensors(distance_map)
    |> count_beacon_ruled_out()
  end

  def part_two(problem) do
    distance_map = calc_distance_map(problem)

    calc_intervals(distance_map)
    |> find_missing_interval()
    |> calc_tuning_freq()
  end

  # ---------------------------------------------------------------------------------

  # ------ PART TWO -------

  def find_missing_interval(intervals) do
    intervals
    |> Enum.reduce_while(nil, fn {y, intervals}, acc ->
      case Enum.reduce(intervals, [], &merge_intervals/2) do
        [{_, _}, {_, x}] -> {:halt, {x + 1, y}}
        _ -> {:cont, acc}
      end
    end)
  end

  def merge_intervals({x1, y1}, [{x2, y2} | rest]) when x1 - y2 <= 1 do
    [{x2, max(y1, y2)} | rest]
  end

  def merge_intervals({x1, y1}, [{_x2, _y2} | _rest] = acc) do
    [{x1, y1} | acc]
  end

  def merge_intervals(pt, []), do: [pt]

  def calc_intervals(distance_map) do
    0..@coord_max
    |> Enum.map(fn target_y ->
      distance_map
      |> Enum.reduce([], &accumulate_intervals(&1, &2, target_y))
      |> then(fn intervals -> {target_y, sort_intervals(intervals)} end)
    end)
  end

  def accumulate_intervals({sensor, {_beacon, m}}, acc, target_y) do
    case calc_x_interval(sensor, target_y, m) do
      nil -> acc
      int -> [int | acc]
    end
  end

  def sort_intervals(intervals) do
    intervals
    |> Enum.sort_by(fn {s, _e} -> s end)
  end

  def calc_x_interval({_x, y}, target_y, m) when target_y > y + m, do: nil
  def calc_x_interval({_x, y}, target_y, m) when target_y < y - m, do: nil

  def calc_x_interval({x, y}, target_y, m) do
    {
      max(x - m + abs(target_y - y), 0),
      min(x + m - abs(target_y - y), @coord_max)
    }
  end

  def calc_tuning_freq({x, y}) do
    x * @freq_max + y
  end

  # ------ PART ONE -------

  def find_max_manhattan_distance(distance) do
    distance
    |> Enum.max_by(fn {_, {_, distance}} -> distance end)
    |> elem(1)
    |> elem(1)
  end

  def calc_distance_map(problem) do
    problem
    |> Enum.map(fn {sensor, beacon} ->
      {sensor, {beacon, calc_manhattan_distance(sensor, beacon)}}
    end)
    |> Enum.into(%{})
  end

  def get_sensors(problem) do
    problem
    |> Enum.unzip()
    |> elem(0)
  end

  def find_start_and_end_x(problem) do
    problem
    |> get_sensors()
    |> Enum.min_max_by(fn {x, _y} -> x end)
    |> then(fn {{start_x, _}, {end_x, _}} -> {start_x, end_x} end)
  end

  def count_beacon_ruled_out(list) do
    Enum.count(list, fn status -> status == :beacon_ruled_out end)
  end

  def check_sensors(points, distance_map) do
    points
    |> Enum.map(fn pt -> check_sensors_for_point(pt, distance_map) end)
  end

  def check_sensors_for_point(point, distance_map) do
    distance_map
    |> Enum.reduce_while(:beacon_possible, &check_distance_with_point(&1, &2, point))
  end

  def check_distance_with_point({_sensor, {beacon, _beacon_distance}}, _acc, point)
      when beacon == point do
    {:halt, :beacon}
  end

  def check_distance_with_point({sensor, {_beacon, beacon_distance}}, acc, point) do
    if calc_manhattan_distance(sensor, point) <= beacon_distance do
      {:halt, :beacon_ruled_out}
    else
      {:cont, acc}
    end
  end

  def convert_to_coords(xs) do
    Enum.map(xs, fn x -> {x, @target_y} end)
  end

  def calc_manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def parse_sensor_and_beacon(str) do
    {:ok, [a, b, c, d], _, _, _, _} = Aoe.Y22.Day15.Parser.parse_sensor_and_beacon(str)

    {{a, b}, {c, d}}
  end
end

defmodule Aoe.Y22.Day15.ParserHelpers do
  import NimbleParsec

  def convert_to_negative(s) do
    s
    |> Enum.map(&to_string/1)
    |> Enum.join()
    |> String.to_integer()
  end

  def number do
    choice([
      integer(min: 1),
      string("-")
      |> integer(min: 1)
      |> reduce({:convert_to_negative, []})
    ])
  end

  def sensor do
    ignore(string("Sensor at x="))
    |> concat(number())
    |> ignore(string(", y="))
    |> concat(number())
    |> ignore(string(":"))
  end

  def beacon do
    ignore(string(" closest beacon is at x="))
    |> concat(number())
    |> ignore(string(", y="))
    |> concat(number())
  end
end

defmodule Aoe.Y22.Day15.Parser do
  import NimbleParsec
  import Aoe.Y22.Day15.ParserHelpers

  defparsec(:parse_sensor_and_beacon, sensor() |> concat(beacon()))
end
