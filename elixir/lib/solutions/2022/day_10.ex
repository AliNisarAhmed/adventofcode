defmodule Aoe.Y22.Day10 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: Enum.t(command())

  @type command :: :noop | {:addx, integer()}
  @type ttl :: integer()
  @type instr :: {ttl(), integer()}
  @type cycle_num :: integer()
  @type history :: Enum.t(integer())
  @type acc :: {history(), command | nil, Enum.t(command)}

  @type sprite_position_map :: %{
          integer() => integer()
        }
  @type screen_dimensions :: {integer(), integer()}

  # -----------------------------------------

  # ---- PART ONE ----
  @addx_ttl 1
  @noop_ttl 0
  @max_cycles 250
  @cycles [20, 60, 100, 140, 180, 220]
  @offset 1

  # ---- PART TWO ----

  @screen_height 6
  @screen_width 40

  # ------------------------------------------

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_command/1)
    |> Enum.to_list()
  end

  def part_one(problem) do
    problem
    |> extend_instruction_list()
    |> execute()
    |> calculate_signal_strength()
  end

  def part_two(problem) do
    sprite_position_map =
      problem
      |> extend_instruction_list()
      |> execute()
      |> compute_sprite_position_map()

    {@screen_width, @screen_height}
    |> compute_screen_positions()
    |> compute_image_pixels(sprite_position_map)
    |> draw_image()
  end

  # ----------------------------

  # ----- PART TWO -----

  def draw_image(image_pixels) do
    image_pixels
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  @spec compute_image_pixels([Enum.t(integer())], sprite_position_map()) :: [[String.t()]]
  def compute_image_pixels(positions, sprite_position_map) do
    positions
    |> Enum.map(fn {row, pixels} ->
      Enum.map(pixels, fn pixel ->
        cycle = row * @screen_width + (pixel + 1)
        sprite_position = Map.get(sprite_position_map, cycle)

        if pixel in [sprite_position - 1, sprite_position, sprite_position + 1] do
          "#"
        else
          "."
        end
      end)
    end)
  end

  @spec compute_screen_positions(screen_dimensions()) :: [[integer()]]
  def compute_screen_positions({screen_width, screen_height}) do
    0..(screen_height - 1)
    |> Enum.map(fn row -> {row, 0..(screen_width - 1)} end)
  end

  @spec compute_sprite_position_map(history()) :: sprite_position_map()
  def compute_sprite_position_map(history) do
    history
    |> Enum.reverse()
    |> Enum.with_index(@offset)
    |> Enum.map(fn {v, i} -> {i, v} end)
    |> Enum.into(%{})
  end

  # ----- PART ONE -----

  @spec calculate_signal_strength(history()) :: number()
  def calculate_signal_strength(history) do
    history
    |> Enum.reverse()
    |> Enum.with_index(@offset)
    |> Enum.filter(fn {_v, idx} -> idx in @cycles end)
    |> Enum.map(fn {v, i} -> v * i end)
    |> Enum.sum()
  end

  def extend_instruction_list(problem) do
    problem ++ List.duplicate(:noop, @max_cycles - length(problem))
  end

  @spec execute(problem()) :: history()
  def execute(problem) do
    0..@max_cycles
    |> Enum.reduce({[], nil, problem}, &execute_instruction/2)
    |> elem(0)
  end

  @spec execute_instruction(cycle_num(), acc()) :: acc()
  def execute_instruction(0, {[], nil, [first_command | rest]}) do
    {[1], add_ttl_to_command(first_command), rest}
  end

  def execute_instruction(_n, {[last_x | _rest] = history, {0, v}, [first_command | rest]}) do
    {[last_x + v | history], add_ttl_to_command(first_command), rest}
  end

  def execute_instruction(_n, {[last_x | _rest] = history, {n, v}, instr_list}) do
    {[last_x | history], {n - 1, v}, instr_list}
  end

  @spec add_ttl_to_command(command()) :: instr()
  def add_ttl_to_command({:addx, v}), do: {@addx_ttl, v}
  def add_ttl_to_command(:noop), do: {@noop_ttl, 0}

  def parse_command("addx " <> s), do: {:addx, String.to_integer(s)}
  def parse_command(_), do: :noop
end
