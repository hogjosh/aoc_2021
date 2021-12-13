defmodule Day12 do
  def count() do
    edges =
      "input.txt"
      |> File.stream!()
      |> parse()
      |> Stream.flat_map(&expand/1)
      |> Stream.reject(&(elem(&1, 1) == :start))
      |> Stream.reject(&(elem(&1, 0) == :end))
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    :start
    |> visit(edges, [])
    |> Enum.count()
  end

  def visit(:end, _edges, path), do: [[:end | path]]

  def visit(cave, edges, path) do
    cond do
      can_visit?(cave, path) ->
        edges
        |> Map.fetch!(cave)
        |> Enum.flat_map(&visit(&1, edges, [cave | path]))

      :otherwise ->
        []
    end
  end

  def can_visit?({:small, _} = cave, path) do
    if cave not in path do
      true
    else
      path
      |> Stream.filter(&match?({:small, _}, &1))
      |> Enum.frequencies()
      |> Enum.all?(fn {_, count} -> count < 2 end)
    end
  end

  def can_visit?(_cave, _path), do: true

  def expand({:start, _} = edge), do: [edge]
  def expand({_, :end} = edge), do: [edge]
  def expand({l, r}), do: [{l, r}, {r, l}]

  def identify("start"), do: :start
  def identify("end"), do: :end

  def identify(c) do
    case String.upcase(c) do
      ^c -> {:big, c}
      _ -> {:small, c}
    end
  end

  def parse(lines) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line ->
      line
      |> String.split("-", trim: true)
      |> Enum.map(&identify/1)
      |> List.to_tuple()
    end)
  end
end
