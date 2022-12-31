# For Part 2
# From: https://elixirforum.com/t/advent-of-code-2022-day-11/52423/20
# Using Number theory trick of representing gigantic numbers that we only care about remainder of with
# a bunch of pairwise coprime numbers, a residue number system: https://en.wikipedia.org/wiki/Residue_number_system

defmodule Aoe.Y22.Day11 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: monkey_map()

  @type monkey_map :: %{
          monkey_id() => monkey_details()
        }
  @type monkey_id :: integer()
  @type monkey_details :: %{
          operation: operation(),
          starting_items: starting_items(),
          test: test(),
          transfer_count: integer()
        }
  @type operand :: integer() | String.t()
  @type operation :: [operand()]
  @type starting_items :: [integer()]
  @type test :: [integer()]

  # ----------------------------------

  @num_rounds_part1 20
  @num_rounds_part2 10_000

  # part one
  @factor_partone 3

  # part two
  @factor_parttwo 1

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("\n\n")
    |> Enum.flat_map(&parse_note/1)
    |> Enum.into(%{})
  end

  def part_one(problem) do
    problem
    |> play_n_rounds(@num_rounds_part1, @factor_partone)
    |> calc_monkey_business()
  end

  def part_two(problem) do
    problem
    |> play_n_rounds(@num_rounds_part2, @factor_parttwo)
    |> calc_monkey_business()
  end

  # ---------------------------------------------------

  def calculate_monkey_factor(monkey_map) do
    monkey_map
    |> Enum.map(fn {_id, %{test: [divisor, _, _]}} -> divisor end)
    |> Enum.product()
  end

  def calc_monkey_business(monkey_map) do
    monkey_map
    |> Enum.map(fn {_id, %{transfer_count: transfer_count}} -> transfer_count end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(&Kernel.*/2)
  end

  @spec play_n_rounds(monkey_map(), integer(), integer()) :: monkey_map()
  def play_n_rounds(monkey_map, n, factor) do
    monkey_factor = calculate_monkey_factor(monkey_map)

    1..n
    |> Enum.reduce(monkey_map, fn _n, acc -> play_round(acc, monkey_factor, factor) end)
  end

  @spec play_round(monkey_map(), integer(), integer()) :: monkey_map()
  def play_round(monkey_map, monkey_factor, factor) do
    monkey_map
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.reduce(monkey_map, &play_monkey_turn(&1, &2, monkey_factor, factor))
  end

  @spec play_monkey_turn(
          {integer(), monkey_details()},
          monkey_map(),
          integer(),
          integer()
        ) :: monkey_map()
  def play_monkey_turn(
        {monkey_id, %{operation: operation, test: test}},
        monkey_map,
        monkey_factor,
        factor
      ) do
    monkey_map
    |> get_starting_items(monkey_id)
    |> Enum.reduce(monkey_map, fn item, acc ->
      worry_level = calc_worry_level(item, operation, monkey_factor, factor)

      worry_level
      |> test_worry_level(test)
      |> transfer_worry_level(acc, worry_level)
      |> update_transfer_count(monkey_id)
    end)
  end

  @spec get_starting_items(monkey_map(), integer()) :: [integer()]
  def get_starting_items(monkey_map, monkey_id) do
    monkey_map
    |> Map.get(monkey_id)
    |> Map.get(:starting_items)
  end

  @spec update_transfer_count(monkey_map(), integer()) :: monkey_map()
  def update_transfer_count(monkey_map, monkey_id) do
    monkey_map
    |> Map.update!(monkey_id, fn details ->
      details
      |> Map.update!(:transfer_count, &(&1 + 1))
      |> Map.update!(:starting_items, fn [_head | rest] -> rest end)
    end)
  end

  @spec transfer_worry_level(integer(), monkey_map(), integer()) :: monkey_map()
  def transfer_worry_level(monkey_id, monkey_map, n) do
    monkey_map
    |> Map.update!(monkey_id, fn details ->
      details
      |> Map.update!(:starting_items, fn prev -> prev ++ [n] end)
    end)
  end

  @spec test_worry_level(integer(), test()) :: integer()
  def test_worry_level(worry_level, [test, true_condition, false_condition]) do
    if rem(worry_level, test) == 0 do
      true_condition
    else
      false_condition
    end
  end

  @spec calc_worry_level(integer(), operation(), integer(), integer()) :: integer()
  def calc_worry_level(n, [operand1, op, operand2], monkey_factor, factor) do
    operand1 = get_operand_value(n, operand1)
    operand2 = get_operand_value(n, operand2)

    perform_operation(operand1, op, operand2)
    # for part one - remove this line
    |> rem(monkey_factor)
    |> Kernel.div(factor)
  end

  def get_operand_value(n, "old"), do: n
  def get_operand_value(_n, m), do: m

  def perform_operation(operand1, ?+, operand2), do: operand1 + operand2
  def perform_operation(operand1, ?-, operand2), do: operand1 - operand2
  def perform_operation(operand1, ?*, operand2), do: operand1 * operand2
  def perform_operation(operand1, _op, operand2), do: operand1 / operand2

  # ----------------------------------------------------

  def parse_note(str) do
    {:ok, notes, _, _, _, _} = Aoe.Y22.Day11.Parser.parse_notes(str)

    create_monkey_map(notes)
  end

  def create_monkey_map(notes) do
    notes
    |> Enum.map(&create_monkey/1)
  end

  def create_monkey(
        {:note,
         [{:monkey_id, [id]}, {:starting_items, items}, {:operation, operation}, {:test, test}]}
      ) do
    {id,
     %{
       starting_items: items,
       operation: operation,
       test: test,
       transfer_count: 0
     }}
  end
end

# --------- Parser ---------------

defmodule Aoe.Y22.Day11.ParserHelpers do
  import NimbleParsec

  def whitespace_char do
    choice([
      ascii_char('\s'),
      ascii_char('\n'),
      ascii_char('\t')
    ])
    |> ignore()
  end

  def whitespace(c) do
    repeat(c, whitespace_char())
  end

  def false_condition do
    ignore(string("If false: throw to monkey "))
    |> integer(min: 1)
  end

  def true_condition do
    ignore(string("If true: throw to monkey "))
    |> integer(min: 1)
  end

  def test do
    ignore(string("Test: divisible by "))
    |> integer(min: 1)
    |> whitespace()
    |> concat(true_condition())
    |> whitespace()
    |> concat(false_condition())
    |> tag(:test)
  end

  def monkey do
    ignore(string("Monkey "))
    |> integer(min: 1)
    |> ignore(ascii_char([?:]))
    |> tag(:monkey_id)
  end

  def starting_items do
    ignore(string("Starting items: "))
    |> repeat(
      integer(min: 1)
      |> ignore(optional(string(", ")))
    )
    |> tag(:starting_items)
  end

  def operator do
    ascii_char([?+, ?-, ?/, ?*])
  end

  def operand do
    choice([
      string("old"),
      string("new"),
      integer(min: 1)
    ])
  end

  def operation do
    ignore(string("Operation: new = "))
    |> concat(operand())
    |> whitespace()
    |> concat(operator())
    |> whitespace()
    |> concat(operand())
    |> tag(:operation)
  end
end

defmodule Aoe.Y22.Day11.Parser do
  import Aoe.Y22.Day11.ParserHelpers
  import NimbleParsec

  note =
    monkey()
    |> whitespace()
    |> concat(starting_items())
    |> whitespace()
    |> concat(operation())
    |> whitespace()
    |> concat(test())
    |> whitespace()
    |> tag(:note)

  defparsec(:parse_notes, repeat(note))
end
