defmodule Day05 do
  def overlaps() do
    "input.txt"
    |> File.stream!()
    |> Stream.map(&parse_line/1)
    |> Stream.flat_map(&expand_entry/1)
    |> Enum.frequencies()
    |> Enum.count(fn {_point, count} -> count > 1 end)
  end

  def parse_line(line) do
    [left, right] =
      line
      |> String.trim()
      |> String.split("->", trim: true)
      |> Enum.map(&parse_coordinate/1)

    {left, right}
  end

  def parse_coordinate(coord) do
    [x, y] =
      coord
      |> String.trim()
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    {x, y}
  end

  def expand_entry({{x1, y1}, {x2, y2}}) do
    cond do
      y1 == y2 -> Enum.map(x1..x2, &{&1, y1})
      x1 == x2 -> Enum.map(y1..y2, &{x1, &1})
      :otherwise -> Enum.zip(x1..x2, y1..y2)
    end
  end
end
