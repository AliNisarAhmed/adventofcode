defmodule Aoe.Y22.Day8 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: Enum.t(Enum.t(integer()))

  @type dimensions :: {integer(), integer()}
  @type index :: {integer(), integer()}
  @type status :: :visible | :invisible

  # used in part 2
  @type tree_map :: %{
          index() => integer()
        }

  # used in part 1
  @type tree_map_vis :: %{
          index() => {integer(), status()}
        }

  # -------------------------------

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(fn list ->
      Enum.map(list, &String.to_integer/1)
    end)
  end

  def part_one(problem) do
    dimensions = get_grid_dimensions(problem)

    map = generate_vis_tree_map(problem)

    check_left_to_right_vis(map, dimensions)
    |> check_right_to_left_vis(dimensions)
    |> check_top_to_bottom_vis(dimensions)
    |> check_bottom_to_top_vis(dimensions)
    |> count_visible()
  end

  def part_two(problem) do
    dimensions = get_grid_dimensions(problem)

    tree_map = generate_tree_map(problem)

    dimensions
    |> get_internal_indices()
    |> Enum.map(fn idx ->
      idx
      |> get_neibs(dimensions)
      |> get_neibs_height(tree_map)
      |> calc_scenic_score(Map.get(tree_map, idx))
    end)
    |> Enum.max()
  end

  # --------------- Tree map ----------

  # -------------- PART TWO -----------

  @spec generate_tree_map(problem()) :: tree_map()
  def generate_tree_map(problem) do
    problem
    |> Enum.with_index()
    |> Enum.flat_map(fn {list, row} ->
      list
      |> Enum.with_index()
      |> Enum.map(fn {n, col} -> {{row, col}, n} end)
    end)
    |> Enum.into(%{})
  end

  # -------------- PART ONE -------------

  @spec generate_vis_tree_map(problem()) :: tree_map_vis()
  def generate_vis_tree_map(list_of_lists) do
    list_of_lists
    |> Enum.with_index()
    |> Enum.flat_map(fn {list, row} ->
      list
      |> Enum.with_index()
      |> Enum.map(fn {n, col} -> {{row, col}, {n, :invisible}} end)
    end)
    |> Enum.into(%{})
  end

  # --------------- PROCESS tree map ----------------

  # ---------------- PART TWO -----------------------

  def get_neibs_height(neibs_indices, tree_map) do
    neibs_indices
    |> Enum.map(fn neib_index_list ->
      neib_index_list
      |> Enum.map(fn neib_idx -> Map.get(tree_map, neib_idx) end)
    end)
  end

  def calc_scenic_score(list_of_neibs_height, tree_height) do
    list_of_neibs_height
    |> Enum.map(&calc_viewing_distance(tree_height, &1))
    |> Enum.reduce(&Kernel.*/2)
  end

  def calc_viewing_distance(_tree_height, []), do: 0

  def calc_viewing_distance(tree_height, neibs_height) do
    vision =
      neibs_height
      |> Enum.take_while(fn n -> n < tree_height end)

    if vision == neibs_height do
      vision
      |> Enum.count()
    else
      vision
      |> Enum.count()
      |> then(fn c -> c + 1 end)
    end
  end

  # ------------- PART ONE ----------------------

  def count_visible(tree_map) do
    Enum.count(tree_map, fn {_key, {_, status}} -> status == :visible end)
  end

  @spec check_bottom_to_top_vis(tree_map_vis(), dimensions()) :: tree_map_vis()
  def check_bottom_to_top_vis(map, dimensions) do
    bottom_to_top_indices(dimensions)
    |> check_visible(map)
  end

  def check_top_to_bottom_vis(map, dimensions) do
    top_to_bottom_indices(dimensions)
    |> check_visible(map)
  end

  def check_right_to_left_vis(map, dimensions) do
    right_to_left_indices(dimensions)
    |> check_visible(map)
  end

  def check_left_to_right_vis(map, dimensions) do
    left_to_right_indices(dimensions)
    |> check_visible(map)
  end

  @spec check_visible([index()], tree_map_vis()) :: tree_map_vis()
  def check_visible(indices, tree_map) do
    indices
    |> Enum.reduce(tree_map, &check_visible_row/2)
  end

  def check_visible_row(row, tree_map_initial) do
    row
    |> Enum.reduce({-1, tree_map_initial}, &apply_vis_rules/2)
    |> elem(1)
  end

  def apply_vis_rules({r, c}, {max, map}) do
    case Map.get(map, {r, c}) do
      {tree_height, :visible} ->
        {if(tree_height > max, do: tree_height, else: max), map}

      {tree_height, :invisible} ->
        if tree_height > max do
          {tree_height, Map.put(map, {r, c}, {tree_height, :visible})}
        else
          {max, map}
        end
    end
  end

  # ---------------------- INDEX related functions------------------------------------

  # ----------------------- PART TWO -----------------------------

  @spec get_internal_indices(dimensions()) :: [index()]
  def get_internal_indices({rows, cols}) do
    1..(rows - 2)
    |> Enum.flat_map(fn row ->
      for col <- 1..(cols - 2) do
        {row, col}
      end
    end)
  end

  @spec get_neibs(index(), dimensions()) :: Enum.t([index()])
  def get_neibs(idx, dimensions) do
    [
      left_neibs(idx),
      right_neibs(idx, dimensions),
      top_neibs(idx),
      bottom_neibs(idx, dimensions)
    ]
  end

  @spec right_neibs(index(), dimensions()) :: [index()]
  def right_neibs({row, col}, {_rows, cols}) do
    (col + 1)..(cols - 1)
    |> Enum.map(fn c -> {row, c} end)
  end

  @spec left_neibs(index()) :: [index()]
  def left_neibs({row, col}) do
    (col - 1)..0
    |> Enum.map(fn c -> {row, c} end)
  end

  @spec top_neibs(index()) :: [index()]
  def top_neibs({row, col}) do
    (row - 1)..0
    |> Enum.map(fn r -> {r, col} end)
  end

  @spec bottom_neibs(index(), dimensions()) :: [index()]
  def bottom_neibs({row, col}, {rows, _cols}) do
    (row + 1)..(rows - 1)
    |> Enum.map(fn r -> {r, col} end)
  end

  # ---------------------- PART ONE -----------------------

  @spec bottom_to_top_indices(dimensions()) :: Enum.t([index()])
  def bottom_to_top_indices({rows, cols}) do
    0..(cols - 1)
    |> Enum.map(fn col ->
      for row <- (rows - 1)..0 do
        {row, col}
      end
    end)
  end

  @spec top_to_bottom_indices(dimensions()) :: Enum.t(Enum.t(index()))
  def top_to_bottom_indices({rows, cols}) do
    0..(cols - 1)
    |> Enum.map(fn col ->
      for row <- 0..(rows - 1) do
        {row, col}
      end
    end)
  end

  @spec left_to_right_indices(dimensions()) :: Enum.t(Enum.t(index()))
  def left_to_right_indices({rows, cols}) do
    0..(rows - 1)
    |> Enum.map(fn row ->
      for col <- 0..(cols - 1) do
        {row, col}
      end
    end)
  end

  @spec right_to_left_indices(dimensions()) :: Enum.t(Enum.t(index()))
  def right_to_left_indices({rows, cols}) do
    0..(rows - 1)
    |> Enum.map(fn row ->
      for col <- (cols - 1)..0 do
        {row, col}
      end
    end)
  end

  # ------------------------------------------

  @spec get_grid_dimensions(problem()) :: dimensions()
  defp get_grid_dimensions(problem) do
    {length(problem), length(Enum.at(problem, 0))}
  end
end
