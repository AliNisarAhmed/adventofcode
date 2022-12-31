# https://elixirforum.com/t/build-a-tree-from-a-flat-structure-recursively/46765/9

defmodule Aoe.Y22.Day7 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file_path :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: Enum.t(output())

  @type output :: {:cd, String.t()} | {:file, String.t(), number()} | {:dir, String.t()}
  @type dir :: %{
          id: String.t(),
          files: Enum.t(file),
          parent: String.t()
        }
  @type file :: %{
          id: String.t(),
          file_size: number()
        }

  @type acc :: %{
          current_dir: String.t(),
          graph: :digraph.graph()
        }

  @spec read_file!(file_path, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
    # Input.stream!(file)
    # Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_command/1)
  end

  def part_one(problem) do
    graph =
      problem
      |> create_file_tree()

    calculate_total_size(graph, "/")

    sum_dir_less_than_100k(graph)
  end

  def part_two(problem) do
    graph =
      problem
      |> create_file_tree()

    total_size = calculate_total_size(graph, "/")

    find_dir_to_delete(graph, total_size)
  end

  # ----------------------------

  @spec create_file_tree(problem()) :: :digraph.graph()
  defp create_file_tree(outputs) do
    outputs
    |> Enum.reduce(%{current_dir: nil, graph: :digraph.new()}, &reducer/2)
    |> Map.get(:graph, nil)
  end

  # ---------- Main Reducer --------------------

  @spec reducer(output(), acc()) :: acc()
  defp reducer({:cd, ".."}, %{current_dir: current_dir, graph: graph} = acc) do
    {_, vertex} = :digraph.vertex(graph, current_dir)

    Map.put(acc, :current_dir, vertex.parent)
  end

  defp reducer({:cd, dir_name}, %{current_dir: current_dir, graph: graph} = acc) do
    add_vertex(dir_name, current_dir, graph)

    Map.put(acc, :current_dir, join_path(current_dir, dir_name))
  end

  defp reducer({:dir, dir_name}, %{current_dir: current_dir, graph: graph} = acc) do
    add_edge(dir_name, current_dir, graph)

    acc
  end

  defp reducer({:file, file_name, file_size}, %{current_dir: current_dir, graph: graph} = acc) do
    add_file(file_name, file_size, current_dir, graph)

    acc
  end

  defp reducer(_, acc), do: acc

  # ----------------------------------------------------------------------

  @spec add_file(String.t(), number(), String.t(), :digraph.graph()) :: :digraph.vertex()
  defp add_file(file_name, file_size, current_dir, graph) do
    {_, vertex} = :digraph.vertex(graph, current_dir)

    new_vertex =
      Map.update!(vertex, :files, fn files -> [create_file(file_name, file_size) | files] end)

    :digraph.add_vertex(graph, current_dir, new_vertex)
  end

  @spec add_vertex(String.t(), String.t(), :digraph.graph()) :: :digraph.vertex()
  defp add_vertex(dir_name, parent, graph) do
    :digraph.add_vertex(graph, join_path(parent, dir_name), create_dir(dir_name, parent))
  end

  @spec add_edge(String.t(), String.t(), :digraph.graph()) :: :digraph.edge()
  defp add_edge(dir_name, parent, graph) do
    add_vertex(dir_name, parent, graph)
    :digraph.add_edge(graph, parent, join_path(parent, dir_name))
  end

  defp join_path(nil, dir), do: dir
  defp join_path(parent, dir), do: parent <> "/" <> dir

  # -------------------------------------------------------------------------

  @spec sum_file_sizes(files :: Enum.t(file())) :: number()
  defp sum_file_sizes(files) do
    files
    |> Enum.map(&Map.get(&1, :file_size))
    |> Enum.sum()
  end

  @spec calculate_total_size(:digraph.graph(), String.t()) :: number()
  defp calculate_total_size(graph, dir) do
    sum_of_children =
      graph
      |> :digraph.out_neighbours(dir)
      |> Enum.map(&calculate_total_size(graph, &1))
      |> Enum.sum()

    {_, vertex} = :digraph.vertex(graph, dir)

    size = sum_of_children + sum_file_sizes(vertex.files)

    :digraph.add_vertex(graph, dir, Map.put(vertex, :size, size))

    size
  end

  # ------------- Part 1 -------------------------------

  @spec sum_dir_less_than_100k(:digraph.graph()) :: number()
  defp sum_dir_less_than_100k(graph) do
    graph
    |> :digraph_utils.postorder()
    |> Enum.map(fn dir ->
      {_, vertex} = :digraph.vertex(graph, dir)
      vertex.size
    end)
    |> Enum.filter(fn s -> s < 100_000 end)
    |> Enum.sum()
  end

  # ------------- Part 2 ------------------------------

  @spec find_dir_to_delete(:digraph.graph(), number()) :: number()
  defp find_dir_to_delete(graph, total_size) do
    graph
    |> :digraph_utils.postorder()
    |> Enum.map(fn dir ->
      {_, vertex} = :digraph.vertex(graph, dir)
      vertex.size
    end)
    |> Enum.sort()
    |> Enum.find(fn size -> 70_000_000 - (total_size - size) >= 30_000_000 end)
  end

  # ---------- CONSTRUCTORS ---------------

  @spec create_file(String.t(), number()) :: file()
  defp create_file(file_name, file_size) do
    %{
      id: file_name,
      file_size: file_size
    }
  end

  @spec create_dir(String.t(), parent :: String.t() | nil) :: dir()
  defp create_dir(dir_name, parent) do
    %{
      id: join_path(parent, dir_name),
      files: [],
      parent: parent
    }
  end

  @spec parse_command(str :: String.t()) :: output()
  def parse_command(str) do
    case Aoe.Y22.Day7.Parser.command_parser(str) do
      {:ok, [cd: [dir_name]], _, _, _, _} ->
        {:cd, dir_name}

      {:ok, [file: [size, name]], _, _, _, _} ->
        {:file, name, size}

      {:ok, [dir: [dir_name]], _, _, _, _} ->
        {:dir, dir_name}

      _ ->
        nil
    end
  end
end

# ---------------- Parser -------------------

defmodule Aoe.Y22.Day7.Parser do
  import NimbleParsec

  @uppercase ?A..?Z
  @lowercase ?a..?z
  @any_chars [@uppercase, @lowercase]

  cd =
    ignore(string("$ cd "))
    |> choice([string("/"), ascii_string(@any_chars, min: 1), string("..")])
    |> tag(:cd)
    |> label("cd followed by directory name or root or previous directory")

  ls = ignore(string("$ ls"))

  dir =
    ignore(string("dir "))
    |> ascii_string(@any_chars, min: 1)
    |> tag(:dir)
    |> label("directory name")

  file =
    integer(min: 1)
    |> ignore(string(" "))
    |> ascii_string([?.] ++ @any_chars, min: 1)
    |> tag(:file)
    |> label("file size followed by file name")

  command = choice([cd, ls, dir, file])

  defparsec(:command_parser, repeat(command))
end
