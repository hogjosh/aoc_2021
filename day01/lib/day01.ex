defmodule Day01 do
  def count() do
    "input.txt"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.transform({nil, nil, nil}, fn
      current, {nil, nil, nil} -> {[], {current, nil, nil}}
      current, {one, nil, nil} -> {[], {one, current, nil}}
      current, {one, two, nil} -> {[{one, two, current}], {one, two, current}}
      current, {_one, two, three} -> {[{two, three, current}], {two, three, current}}
    end)
    |> Stream.map(fn {a, b, c} -> a + b + c end)
    |> Stream.transform({nil, nil}, fn
      current, {nil, nil} -> {[{nil, current}], {nil, current}}
      current, {_, prev} -> {[{prev, current}], {prev, current}}
    end)
    |> Stream.filter(fn {prev, current} -> current > prev end)
    |> Enum.count()
  end
end
