defmodule Day09 do
  def product() do
    [line | _] =
      grid =
      "input.txt"
      |> File.stream!()
      |> parse()
      |> Enum.to_list()

    max_y = Enum.count(grid) - 1
    max_x = Enum.count(line) - 1

    low_points =
      grid
      |> adjacency()
      |> low_points()
      |> Enum.to_list()

    low_points
    |> Enum.map(fn {{{y, x}, _h}, _adjs} ->
      {y, x}
    end)
    |> Enum.map(fn low_point ->
      basin(low_point, {grid, max_y, max_x})
    end)
    |> Enum.map(&Enum.count/1)
    |> Enum.sort(&>/2)
    |> Enum.take(3)
    |> Enum.reduce(&*/2)
  end

  def basin({y, x}, grid, visited \\ []) do
    cond do
      {y, x} in visited ->
        []

      :otherwise ->
        case peek({y, x}, grid) do
          nil ->
            []

          9 ->
            []

          _ ->
            [
              &basin({y + 1, x}, grid, &1),
              &basin({y - 1, x}, grid, &1),
              &basin({y, x - 1}, grid, &1),
              &basin({y, x + 1}, grid, &1)
            ]
            |> Enum.reduce([{y, x} | visited], fn visit_fn, acc ->
              (acc ++ visit_fn.(acc)) |> Enum.uniq()
            end)
        end
    end
  end

  def low_points(adjacency) do
    adjacency
    |> Stream.flat_map(& &1)
    |> Stream.filter(fn {{{_y, _x}, pt_height}, adjs} ->
      Enum.all?(adjs, fn {{_y, _x}, adj_height} ->
        pt_height < adj_height
      end)
    end)
  end

  def adjacency([list | _] = lists) do
    max_y = Enum.count(lists) - 1
    max_x = Enum.count(list) - 1

    adj = fn line, y, x ->
      adjacent(lists, line, {y, max_y}, {x, max_x})
    end

    lists
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {height, x} ->
        {{{y, x}, height}, adj.(line, y, x)}
      end)
    end)
  end

  def adjacent(lists, line, {y, max_y}, {x, max_x}) do
    [
      up(lists, {y, max_y}, {x, max_x}),
      down(lists, {y, max_y}, {x, max_x}),
      left(line, {y, max_y}, {x, max_x}),
      right(line, {y, max_y}, {x, max_x})
    ]
    |> Enum.flat_map(& &1)
  end

  def peek({y, x}, {grid, max_y, max_x}) when y >= 0 and x >= 0 and y <= max_y and x <= max_x do
    grid
    |> Enum.at(y)
    |> Enum.at(x)
  end

  def peek(_, _), do: nil

  def up(_lists, {0, _max_y}, {_x, _max_x}), do: []

  def up(lists, {y, _max_y}, {x, _max_x}) do
    [{{y - 1, x}, Enum.at(lists, y - 1) |> Enum.at(x)}]
  end

  def down(_lists, {max_y, max_y}, {_x, _max_x}), do: []

  def down(lists, {y, _max_y}, {x, _max_x}) do
    [{{y + 1, x}, Enum.at(lists, y + 1) |> Enum.at(x)}]
  end

  def left(_line, {_y, _max_y}, {0, _max_x}), do: []

  def left(line, {y, _max_y}, {x, _max_x}) do
    [{{y, x - 1}, Enum.at(line, x - 1)}]
  end

  def right(_line, {_y, _max_y}, {max_x, max_x}), do: []

  def right(line, {y, _max_y}, {x, _max_x}) do
    [{{y, x + 1}, Enum.at(line, x + 1)}]
  end

  def parse(lines) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Stream.map(&Enum.map(&1, fn s -> String.to_integer(s) end))
  end
end
