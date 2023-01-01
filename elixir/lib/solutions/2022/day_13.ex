defmodule Aoe.Y22.Day13 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: [nested_ints()]

  @type nested_ints :: integer() | [integer()] | [nested_ints()]

  @divider_packet_1 [[2]]
  @divider_packet_2 [[6]]

  @comparison_map %{
    in_order: true,
    equal: true,
    out_of_order: false
  }

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn s ->
      s
      |> dbg
      |> String.split("\n", trim: true)
      |> then(fn [left, right] -> {parse_list(left), parse_list(right)} end)
    end)
  end

  def part_one(problem) do
    problem
    |> Enum.map(&compare_left_and_right/1)
    |> Enum.with_index(1)
    |> Enum.filter(fn {status, _idx} -> status == :in_order end)
    |> Enum.map(fn {_status, idx} -> idx end)
    |> Enum.sum()
  end

  def part_two(problem) do
    problem
    |> combine_all()
    |> add_divider_packets()
    |> sort_signals()
    |> find_decoder_key()
  end

  # ------------------------------------------------------

  # ---- PART TWO ----

  def find_decoder_key(sorted_list) do
    sorted_list
    |> Enum.with_index(1)
    |> Enum.filter(fn {list, _idx} -> list == @divider_packet_1 or list == @divider_packet_2 end)
    |> Enum.map(fn {_list, idx} -> idx end)
    |> Enum.product()
  end

  def sort_signals(list_of_signals) do
    Enum.sort_by(list_of_signals, & &1, &sorter/2)
  end

  def sorter(list1, list2) do
    compare_left_and_right({list1, list2})
    |> then(fn status -> Map.get(@comparison_map, status) end)
  end

  def combine_all(problem) do
    Enum.flat_map(problem, fn {left, right} -> [left, right] end)
  end

  def add_divider_packets(list) do
    [@divider_packet_1, @divider_packet_2 | list]
  end

  # ---- PART ONE ----

  def compare_left_and_right({left_list, right_list}) do
    0..100
    |> Enum.reduce_while({left_list, right_list}, &compare/2)
  end

  # ---- Main comparison login ----

  def compare(_idx, {[], [_head | _rest]}) do
    {:halt, :in_order}
  end

  def compare(_idx, {[_head | _rest], []}) do
    {:halt, :out_of_order}
  end

  def compare(_idx, {[], []}) do
    {:halt, :equal}
  end

  def compare(_idx, {[left_first | rest_left], [right_first | rest_right]})
      when is_list(left_first) and is_list(right_first) do
    case compare_left_and_right({left_first, right_first}) do
      :equal -> {:cont, {rest_left, rest_right}}
      status -> {:halt, status}
    end
  end

  def compare(_idx, {[left_first | _rest], [right_first | _head]})
      when is_integer(left_first) and is_integer(right_first) and left_first < right_first do
    {:halt, :in_order}
  end

  def compare(_idx, {[left_first | _rest], [right_first | _head]})
      when is_integer(left_first) and is_integer(right_first) and left_first > right_first do
    {:halt, :out_of_order}
  end

  def compare(_idx, {[left_first | rest_left], [right_first | rest_right]})
      when is_integer(left_first) and is_integer(right_first) and left_first == right_first do
    {:cont, {rest_left, rest_right}}
  end

  def compare(_idx, {[left_first | rest_left], [right_first | rest_right]})
      when is_integer(left_first) and is_list(right_first) do
    case compare_left_and_right({[left_first], right_first}) do
      :equal -> {:cont, {rest_left, rest_right}}
      status -> {:halt, status}
    end
  end

  def compare(_idx, {[left_first | rest_left], [right_first | rest_right]})
      when is_integer(right_first) and is_list(left_first) do
    case compare_left_and_right({left_first, [right_first]}) do
      :equal -> {:cont, {rest_left, rest_right}}
      status -> {:halt, status}
    end
  end

  # -------------------------------------------------------------------------------

  def parse_list(s) do
    {:ok, [result], _, _, _, _} = Aoe.Y22.Day13.Parser.list_of_ints(s)

    result
  end
end

defmodule Aoe.Y22.Day13.Parser do
  import NimbleParsec

  int =
    integer(min: 1)
    |> ignore(optional(string(",")))

  opening_bracket = ignore(string("["))
  closing_bracket = ignore(string("]"))

  list_of_ints =
    opening_bracket
    |> repeat(
      lookahead_not(string("]"))
      |> choice([
        times(int, min: 1),
        parsec(:list_of_ints),
        ignore(string(","))
      ])
    )
    |> concat(closing_bracket)
    |> wrap()

  defparsec(:list_of_ints, list_of_ints)
end
