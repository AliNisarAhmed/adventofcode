defmodule Aoe.Y19.Day5 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any
  @type operation ::
          :multiply
          | :add
          | :save_to_location
          | :output
          | :halt
          | :jump_if_true
          | :jump_if_false
          | :less_than
          | :equals
  @type mode :: :position | :immediate
  @type instruction :: {mode, mode, mode, operation}

  @input_instruction 5

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
    # Input.stream!(file)
    # Input.stream_file_lines(file, trim: true)
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
    |> unfold(0, &execute_opcode/2)
  end

  def part_two(map) do
    map 
    |> unfold(0, &execute_opcode/2)
  end

  # =====================================

  defp execute_opcode(acc, n) do
    instr =
      acc
      |> Map.get(n)
      |> parse_instr()

    perform_calculation(n, acc, instr)
  end

  @spec get_term(map(), integer(), mode()) :: integer()
  def get_term(acc, idx, mode) do
    case mode do
      :position -> Map.get(acc, Map.get(acc, idx))
      :immediate -> Map.get(acc, idx)
    end
  end

  def perform_calculation(n, acc, {_m3, m2, m1, :add}) do
    result_pos = Map.get(acc, n + 3)
    term1 = get_term(acc, n + 1, m1)
    term2 = get_term(acc, n + 2, m2)

    {n + 4, Map.put(acc, result_pos, term1 + term2)}
  end

  def perform_calculation(n, acc, {_m3, m2, m1, :multiply}) do
    result_pos = Map.get(acc, n + 3)
    term1 = get_term(acc, n + 1, m1)
    term2 = get_term(acc, n + 2, m2)
    {n + 4, Map.put(acc, result_pos, term1 * term2)}
  end

  def perform_calculation(n, acc, {_m3, _m2, _m1, :save_to_location}) do
    pos = Map.get(acc, n + 1)
    {n + 2, Map.put(acc, pos, @input_instruction)}
  end

  def perform_calculation(n, acc, {_m3, m2, m1, :jump_if_true}) do
    term1 = get_term(acc, n + 1, m1)
    term2 = get_term(acc, n + 2, m2)

    if term1 != 0 do
      {term2, Map.put(acc, n, term2)}
    else
      {n + 3, acc}
    end
  end

  def perform_calculation(n, acc, {_m3, m2, m1, :jump_if_false}) do
    term1 = get_term(acc, n + 1, m1)
    term2 = get_term(acc, n + 2, m2)

    if term1 == 0 do
      {term2, Map.put(acc, n, term2)}
    else
      {n + 3, acc}
    end
  end

  def perform_calculation(n, acc, {_m3, m2, m1, :less_than}) do
    term1 = get_term(acc, n + 1, m1)
    term2 = get_term(acc, n + 2, m2)
    pos = Map.get(acc, n + 3)

    if term1 < term2 do
      {n + 4, Map.put(acc, pos, 1)}
    else
      {n + 4, Map.put(acc, pos, 0)}
    end
  end

  def perform_calculation(n, acc, {_m3, m2, m1, :equals}) do
    term1 = get_term(acc, n + 1, m1)
    term2 = get_term(acc, n + 2, m2)
    pos = Map.get(acc, n + 3)

    if term1 == term2 do
      {n + 4, Map.put(acc, pos, 1)}
    else
      {n + 4, Map.put(acc, pos, 0)}
    end
  end

  def perform_calculation(n, acc, {_m3, _m2, m1, :output}) do
    res = get_term(acc, n + 1, m1)
    halt? = is_halt?(acc, n + 2)

    if halt? do
      {nil, res}
    else
      {n + 2, acc}
    end
  end

  def is_halt?(acc, idx) do
    {_, _, _, opcode} = Map.get(acc, idx) |> parse_instr()
    opcode == :halt
  end

  @spec parse_instr(integer()) :: instruction()
  def parse_instr(n) do
    n
    |> Integer.to_string()
    |> String.pad_leading(5, "0")
    |> String.split("", trim: true)
    |> get_params_and_code()
  end

  @spec get_params_and_code(nonempty_list(binary())) :: instruction()
  def get_params_and_code([p1, p2, p3, p4, p5]) do
    mode1 = parse_mode(p1)
    mode2 = parse_mode(p2)
    mode3 = parse_mode(p3)
    opcode = parse_opcode(p4, p5)

    {mode1, mode2, mode3, opcode}
  end

  @spec parse_mode(binary()) :: mode()
  def parse_mode("0"), do: :position
  def parse_mode("1"), do: :immediate

  @spec parse_opcode(binary(), binary()) :: operation()
  def parse_opcode("0", "1"), do: :add
  def parse_opcode("0", "2"), do: :multiply
  def parse_opcode("0", "3"), do: :save_to_location
  def parse_opcode("0", "4"), do: :output
  def parse_opcode("0", "5"), do: :jump_if_true
  def parse_opcode("0", "6"), do: :jump_if_false
  def parse_opcode("0", "7"), do: :less_than
  def parse_opcode("0", "8"), do: :equals
  def parse_opcode("9", "9"), do: :halt

  def unfold(acc, nil, _), do: acc

  def unfold(acc, n, func) do
    {current_value, new_acc} = func.(acc, n)
    unfold(new_acc, current_value, func)
  end
end
