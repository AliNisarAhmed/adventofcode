defmodule Aoe.Y19.Day4 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: any
  @type errors :: {:error, :no_pair} | {:error, :repeated_pair} | {:error, :not_in_oder}
  @type success :: {:ok, :start} | {:ok, :has_pair, map()}
  @type accumulator :: success | errors

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
    # Input.stream!(file)
    # Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.split("-")
    |> Enum.map(fn s ->
      s |> String.trim() |> String.to_integer()
    end)
    |> make_range()
  end

  def part_one(list) do
    list
    |> Enum.map(fn n -> check_conditions(Integer.digits(n), {:ok, :start}) end)
    |> Enum.filter(fn
      {:error, _} -> false
      _ -> true
    end)
    |> Enum.count()
  end

  def part_two(list) do
    list
    |> Enum.map(fn n -> check_conditions(Integer.digits(n), {:ok, :start}) end)
    |> Enum.filter(fn
      {:error, _} -> false
      _ -> true
    end)
    |> Enum.count()
  end

  # == PRIVATE ==

  defp make_range([first, last]) do
    Range.new(first, last)
    |> Enum.to_list()
  end

  defp update_count(map, m) do
    Map.update(map, m, 2, &(&1 + 1))
  end

  @spec check_conditions(list(integer()), accumulator()) :: accumulator()
  defp check_conditions([m, n | rest], {:ok, :has_pair, map}) when m == n do
    check_conditions([n | rest], {:ok, :has_pair, update_count(map, m)})
  end

  defp check_conditions([m, n | rest], {:ok, :start}) when m == n do
    check_conditions([n | rest], {:ok, :has_pair, update_count(%{}, m)})
  end

  defp check_conditions([m, n | _rest], _acc) when m > n do
    {:error, :not_in_oder}
  end

  defp check_conditions([m, n | rest], acc) when m < n do
    check_conditions([n | rest], acc)
  end

  defp check_conditions([_m | rest], acc) do
    check_conditions(rest, acc)
  end

  defp check_conditions([], {:ok, :start}), do: {:error, :no_pair}

  defp check_conditions([], {:ok, :has_pair, map}) do
    if has_single_pair?(map) do
      {:ok, :has_pair, map}
    else
      {:error, :repeated_pair}
    end
  end

  defp check_conditions([], acc), do: acc

  defp has_single_pair?(map) do
    map
    |> Enum.any?(fn {_k, v} -> v == 2 end)
  end
end
