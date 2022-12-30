defmodule Aoe.Y22.Day9 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()

  @type direction :: :right | :left | :up | :down
  @type problem :: {direction, integer()}
  @type position :: {integer(), integer()}

  # -------------------------------------

  @starting_position [{0, 0}]

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
  end

  @spec parse_input!(input, part) :: Stream.t(problem)
  def parse_input!(input, _part) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [dir, n] -> {parse_direction(dir), String.to_integer(n)} end)
  end

  # -------------------------------

  def part_one(problem) do
    head_positions =
      problem
      |> move_head()

    1
    |> move_followers_one_by_one(head_positions)
    |> Enum.uniq()
    |> Enum.count()
  end

  def part_two(problem) do
    head_positions =
      problem
      |> move_head()

    9
    |> move_followers_one_by_one(head_positions)
    |> Enum.uniq()
    |> Enum.count()
  end

  # ---------------------------------

  @spec move_followers_one_by_one(integer(), Enum.t(position())) :: Enum.t(position())
  def move_followers_one_by_one(num_followers, leader_positions) do
    1..num_followers
    |> Enum.reduce(
      leader_positions,
      fn _n, acc -> move_follower(acc) end
    )
  end

  @spec move_follower(Enum.t(position())) :: Enum.t(position())
  def move_follower(leader_positions) do
    leader_positions
    |> Enum.reverse()
    |> Enum.reduce(@starting_position, fn head_pos, [tail_pos | _] = acc ->
      [move_tail(head_pos, tail_pos) | acc]
    end)
  end

  @spec move_head(Enum.t(problem())) :: Enum.t(position())
  def move_head(problem) do
    Enum.reduce(problem, @starting_position, fn dir, [head | _] = acc ->
      Enum.concat(move_in_direction_times(head, dir), acc)
    end)
  end

  @spec move_tail(position(), position()) :: position()
  def move_tail({hx, hy}, {hx, hy}), do: {hx, hy}

  def move_tail({hx, same}, {tx, same}) when hx - tx > 1, do: {tx + 1, same}
  def move_tail({hx, same}, {tx, same}) when tx - hx > 1, do: {tx - 1, same}
  def move_tail({same, hy}, {same, ty}) when hy - ty > 1, do: {same, ty + 1}
  def move_tail({same, hy}, {same, ty}) when ty - hy > 1, do: {same, ty - 1}

  def move_tail({hx, hy}, {tx, ty}) when hx - tx > 1 and hy > ty, do: {tx + 1, ty + 1}
  def move_tail({hx, hy}, {tx, ty}) when hx - tx > 1 and hy < ty, do: {tx + 1, ty - 1}

  def move_tail({hx, hy}, {tx, ty}) when tx - hx > 1 and hy > ty, do: {tx - 1, ty + 1}
  def move_tail({hx, hy}, {tx, ty}) when tx - hx > 1 and ty > hy, do: {tx - 1, ty - 1}

  def move_tail({hx, hy}, {tx, ty}) when hy - ty > 1 and hx > tx, do: {tx + 1, ty + 1}
  def move_tail({hx, hy}, {tx, ty}) when hy - ty > 1 and hx < tx, do: {tx - 1, ty + 1}

  def move_tail({hx, hy}, {tx, ty}) when ty - hy > 1 and hx > tx, do: {tx + 1, ty - 1}
  def move_tail({hx, hy}, {tx, ty}) when ty - hy > 1 and tx > hx, do: {tx - 1, ty - 1}

  def move_tail(_head_pos, tail_pos), do: tail_pos

  @spec move_in_direction_times(position(), problem()) :: Enum.t(position())
  def move_in_direction_times({x, y}, {dir, times}) do
    1..times
    |> Enum.reduce(
      [{x, y}],
      fn _n, [head | _rest] = acc ->
        [move_in_direction(head, dir) | acc]
      end
    )
    |> Enum.take(times)
  end

  @spec move_in_direction(position(), direction()) :: position()
  def move_in_direction({x, y}, :right), do: {x + 1, y}
  def move_in_direction({x, y}, :left), do: {x - 1, y}
  def move_in_direction({x, y}, :up), do: {x, y + 1}
  def move_in_direction({x, y}, :down), do: {x, y - 1}

  @spec parse_direction(String.t()) :: direction()
  def parse_direction("R"), do: :right
  def parse_direction("U"), do: :up
  def parse_direction("D"), do: :down
  def parse_direction("L"), do: :left
end
