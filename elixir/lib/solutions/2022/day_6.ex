defmodule Aoe.Y22.Day6 do
  alias Aoe.Input, warn: false

  @type input_path :: binary
  @type file :: input_path | %Aoe.Input.FakeFile{}
  @type part :: :part_one | :part_two
  @type input :: binary | File.Stream.t()
  @type problem :: String.t()

  @spec read_file!(file, part) :: input
  def read_file!(file, _part) do
    Input.read!(file)
    # Input.stream!(file)
    # Input.stream_file_lines(file, trim: true)
  end

  @spec parse_input!(input, part) :: problem
  def parse_input!(input, _part) do
    input
    |> String.trim()
  end

  def part_one(problem) do
    chunk_size = 4

    problem
    |> String.graphemes()
    |> Enum.chunk_every(chunk_size, 1, :discard)
    |> Enum.take_while(fn l ->
      Enum.uniq(l) != l
    end)
    |> Enum.count()
    # add chunk_size back to get number of characters including the last dropped one
    |> then(fn v -> v + chunk_size end)
  end

  def part_two(problem) do
    chunk_size = 14

    problem
    |> String.graphemes()
    |> Enum.chunk_every(chunk_size, 1, :discard)
    |> Enum.take_while(fn l ->
      Enum.uniq(l) != l
    end)
    |> Enum.count()
    # add chunk_size back to get number of characters including the last dropped one
    |> then(fn v -> v + chunk_size end)
  end
end
