defmodule Aoe.Y22.Day14 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any

  @sand_fall_cycles 30_000
  @floor_level 2

  @starting_point Complex.new(500, 0)

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def part_one(problem) do
    grid_map =
      problem
      |> generate_grid()

    highest_y = find_highest_y(grid_map)

    grid_map
    |> sand_fall(:infinity, highest_y)
    |> count_sand_particles()
  end

  def part_two(problem) do
    grid_map =
      problem
      |> generate_grid()

    ground_level = find_highest_y(grid_map) + 1

    grid_map
    |> sand_fall(ground_level, ground_level + 1)
    |> count_sand_particles()
  end

  # ----------------------------------------------

  # ------ PART TWO ------

  def find_highest_y(map) do
    map
    |> Enum.map(fn {k, _v} -> Complex.imag(k) end)
    |> Enum.max()
    |> round()
  end

  # ------ PART ONE ------

  def count_sand_particles(map) do
    Enum.count(map, fn {_k, v} -> v == :sand end)
  end

  def sand_fall(
        init_map,
        y_limit,
        particle_fall_cycles
      ) do
    1..@sand_fall_cycles
    |> Enum.reduce(init_map, fn _n, map ->
      particle_fall(map, @starting_point, y_limit, particle_fall_cycles)
    end)
  end

  def particle_fall(
        init_map,
        starting_point,
        y_limit,
        particle_fall_cycles
      ) do
    1..particle_fall_cycles
    |> Enum.reduce_while({starting_point, init_map}, fn _n, {sp, map} ->
      case available_space(sp, map, y_limit) do
        :blocked -> {:halt, {sp, Map.put(map, sp, :sand)}}
        {:available, point} -> {:cont, {point, map}}
      end
    end)
    |> elem(1)
  end

  def available_space(point, map, y_limit) do
    if round(Complex.imag(point)) >= y_limit do
      :blocked
    else
      down_available?(point, map)
    end
  end

  def down_available?(point, map) do
    down = move_down(point)

    if not is_point_occupied?(down, map) do
      {:available, down}
    else
      down_left_available?(point, map)
    end
  end

  def down_left_available?(point, map) do
    down_left = move_down_left(point)

    if not is_point_occupied?(down_left, map) do
      {:available, down_left}
    else
      down_right_available?(point, map)
    end
  end

  def down_right_available?(point, map) do
    down_right = move_down_right(point)

    if not is_point_occupied?(down_right, map) do
      {:available, down_right}
    else
      :blocked
    end
  end

  def is_point_occupied?(point, map) do
    Map.has_key?(map, point)
  end

  def move_down(complex) do
    Complex.add(complex, Complex.new(0, 1))
  end

  def move_down_left(complex) do
    Complex.add(complex, Complex.new(-1, 1))
  end

  def move_down_right(complex) do
    Complex.add(complex, Complex.new(1, 1))
  end

  def generate_grid(list_of_lines) do
    list_of_lines
    |> Enum.reduce(%{}, &populate_path/2)
  end

  def populate_path(path, init_map) do
    path
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(init_map, &populate_line/2)
  end

  def populate_line([left_pair, right_pair], map) do
    generate_line(left_pair, right_pair)
    |> Enum.reduce(map, fn point, acc -> Map.put(acc, point, :rock) end)
  end

  def generate_line({x, y1}, {x, y2}) do
    y1..y2
    |> Enum.map(fn y -> Complex.new(x, y) end)
  end

  def generate_line({x1, y}, {x2, y}) do
    x1..x2
    |> Enum.map(fn x -> Complex.new(x, y) end)
  end

  def parse_line(str) do
    String.split(str, " -> ", trim: true)
    |> Enum.map(&parse_pair/1)
  end

  def parse_pair(str) do
    String.split(str, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
