defmodule Aoe.Y22.Day5 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: {stack(), instruction()}
  @type stack :: %{number() => Enum.t(String.t())}
  @type instruction :: Enum.t(number())

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
    # Input.stream!(file)
    # Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    [stacks, instructions] = String.split(input, "\n\n")

    stacks = parse_stacks(stacks)
    instructions = parse_instructions(instructions)

    {stacks, instructions}
  end

  def part_one({stacks, instructions}) do
    instructions
    |> Enum.reduce(stacks, &apply_instruction_part_one/2)
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Enum.map_join(fn {_, v} -> Enum.at(v, 0) end)
  end

  def part_two({stacks, instructions}) do
    instructions
    |> Enum.reduce(stacks, &apply_instruction_part_two/2)
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Enum.map_join(fn {_, v} -> Enum.at(v, 0) end)
  end

  # ------------------------------------------------

  defp apply_instruction_part_two([count, from, to], state) do
    current = Map.get(state, from, [])
    {moved, current} = Enum.split(current, count)

    state = Map.replace(state, from, current)

    Map.update!(state, to, fn prev ->
      moved
      |> Enum.concat(prev)
    end)
  end

  defp apply_instruction_part_one([count, from, to], state) do
    current = Map.get(state, from, [])
    {moved, current} = Enum.split(current, count)

    state = Map.replace(state, from, current)

    Map.update!(state, to, fn prev ->
      moved
      |> Enum.reverse()
      |> Enum.concat(prev)
    end)
  end

  defp parse_instructions(ins) do
    ins
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp parse_stacks(stacks) do
    stacks
    |> String.split("\n")
    |> Enum.map(&parse_stack/1)
    |> Enum.take(8)
    |> transpose()
    |> Enum.map(&remove_empty_spaces/1)
    |> accumulate_to_index_map()
  end

  defp parse_instruction(s) do
    {:ok, list, _, _, _, _} = Parser.parse_instruction(s)

    list
  end

  defp parse_stack(s) do
    {:ok, list, _, _, _, _} = Parser.parse_stack(s)

    list
  end

  defp transpose(l) do
    l
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp remove_empty_spaces(list) do
    Enum.filter(list, fn s -> s != " " end)
  end

  defp accumulate_to_index_map(list) do
    1..9
    |> Enum.zip(list)
    |> Enum.into(%{})
  end
end

# ------------- Parsers -------------------

defmodule Parser do
  import NimbleParsec

  parse_instruction =
    ignore(string("move "))
    |> integer(max: 2)
    |> ignore(string(" from "))
    |> integer(max: 2)
    |> ignore(string(" to "))
    |> integer(max: 2)

  empty =
    string(" ")
    |> times(3)
    |> replace(" ")

  letter =
    ignore(string("["))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string("]"))

  letter_or_empty =
    choice([
      letter,
      empty
    ])
    |> optional(string(" ") |> ignore())

  parse_stack = repeat(letter_or_empty)

  defparsec(:parse_stack, parse_stack)
  defparsec(:parse_instruction, parse_instruction)
end
