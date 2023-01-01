defmodule Aoe.Y22.Day12 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: [[String.t()]]

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def part_one(problem) do
    dimensions = get_grid_dimensions(problem)

    grid_map =
      problem
      |> generate_grid_map()

    graph =
      grid_map
      |> add_vertices()
      |> add_edges(grid_map, dimensions)

    starting_point = Enum.find(grid_map, fn {_, v} -> v == "S" end)
    ending_point = Enum.find(grid_map, fn {_, v} -> v == "E" end)

    Graph.dijkstra(graph, starting_point, ending_point)
    |> then(fn path -> length(path) - 1 end)
  end

  def part_two(problem) do
    dimensions = get_grid_dimensions(problem)

    grid_map =
      problem
      |> generate_grid_map()

    graph =
      grid_map
      |> add_vertices()
      |> add_edges(grid_map, dimensions)

    starting_points = Enum.filter(grid_map, fn {_, v} -> v == "a" end)
    ending_point = Enum.find(grid_map, fn {_, v} -> v == "E" end)

    starting_points
    |> Enum.map(fn sp -> Graph.dijkstra(graph, sp, ending_point) end)
    |> Enum.filter(fn path -> path != nil end)
    |> Enum.map(fn path -> length(path) - 1 end)
    |> Enum.min()
  end

  # ------------------------------

  def add_edges(init_graph, grid_map, dimensions) do
    grid_map
    |> Enum.reduce(init_graph, fn {coords, _s} = current_cell, graph ->
      coords
      |> get_neibs(dimensions)
      |> Enum.map(fn n -> {n, Map.get(grid_map, n)} end)
      |> Enum.filter(fn n -> valid_edge_condition?(current_cell, n) end)
      |> Enum.reduce(graph, fn neib, acc -> Graph.add_edge(acc, current_cell, neib) end)
    end)
  end

  def valid_edge_condition?({_, "S"}, {_, _}), do: true
  def valid_edge_condition?({_, "y"}, {_, "E"}), do: true
  def valid_edge_condition?({_, "z"}, {_, "E"}), do: true
  def valid_edge_condition?({_, _}, {_, "E"}), do: false

  def valid_edge_condition?(start_point, end_point) do
    codepoint_end = codepoint(elem(end_point, 1))
    codepoint_start = codepoint(elem(start_point, 1))
    codepoint_end - codepoint_start <= 1
  end

  def codepoint(s) do
    s
    |> String.to_charlist()
    |> hd()
  end

  def get_neibs({row, col}, dimensions) do
    [{row - 1, col}, {row + 1, col}, {row, col + 1}, {row, col - 1}]
    |> Enum.filter(&is_valid_neib?(&1, dimensions))
  end

  def is_valid_neib?({row, col}, {rows, cols}) do
    row >= 0 and col >= 0 and
      row < rows and col < cols
  end

  def add_vertices(grid_map) do
    grid_map
    |> Enum.reduce(Graph.new(), fn {{row, col}, s}, graph ->
      Graph.add_vertex(graph, {{row, col}, s})
    end)
  end

  def get_grid_dimensions(problem) do
    {length(problem), length(Enum.at(problem, 0))}
  end

  def generate_grid_map(list_of_lists) do
    list_of_lists
    |> Enum.with_index()
    |> Enum.flat_map(fn {list, row} ->
      list
      |> Enum.with_index()
      |> Enum.map(fn {s, col} -> {{row, col}, s} end)
    end)
    |> Enum.into(%{})
  end
end
