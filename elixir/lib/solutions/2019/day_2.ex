defmodule Aoe.Y19.Day2 do
  alias Aoe.Input, warn: false

  @target 19_690_720

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: map()

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(fn {v, i} -> {i, v |> String.trim() |> String.to_integer()} end)
    |> Map.new()
  end

  def part_one(map) do
    map
    |> Map.put(1, 12)
    |> Map.put(2, 2)
    |> unfold(0, &execute_opcode/2)
    |> Map.get(0)
  end

  def part_two(map) do
    list =
      for n <- 0..99, v <- 0..99 do
        {n, v}
      end

    Enum.reduce_while(list, 0, fn {noun, verb}, acc ->
      if test_pair(noun, verb, map) == @target do
        {:halt, 100 * noun + verb}
      else
        {:cont, acc}
      end
    end)
  end

  # ------------------------------------------------------------

  def test_pair(noun, verb, map) do
    map
    |> Map.put(1, noun)
    |> Map.put(2, verb)
    |> unfold(0, &execute_opcode/2)
    |> Map.get(0)
  end

  def execute_opcode(acc, n) do
    instr = Map.get(acc, n)

    case instr do
      1 ->
        perform_calculation(n, acc, :add)

      2 ->
        perform_calculation(n, acc, :multiply)

      _ ->
        {nil, acc}
    end
  end

  def perform_calculation(n, acc, op) do
    pos1 = Map.get(acc, n + 1)
    pos2 = Map.get(acc, n + 2)
    result_pos = Map.get(acc, n + 3)
    term1 = Map.get(acc, pos1)
    term2 = Map.get(acc, pos2)

    case op do
      :add ->
        {n + 4, Map.put(acc, result_pos, term1 + term2)}

      :multiply ->
        {n + 4, Map.put(acc, result_pos, term1 * term2)}
    end
  end

  def unfold(acc, nil, _), do: acc

  def unfold(acc, n, func) do
    {current_value, new_acc} = func.(acc, n)
    unfold(new_acc, current_value, func)
  end
end
