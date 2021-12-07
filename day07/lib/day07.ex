defmodule Day07 do
  def fuel() do
    {size, input} =
      "input.txt"
      |> File.stream!()
      |> parse()

    0..size
    |> Enum.map(&total_cost_to_move_to(input, &1))
    |> Enum.min()
  end

  def total_cost_to_move_to(input, to) do
    Enum.reduce(input, 0, &(&2 + cost_to_move_to(&1, to)))
  end

  def cost_to_move_to(pos, to) do
    Enum.sum(0..abs(pos - to))
  end

  def parse(lines) do
    {max, rev_list} =
      Stream.flat_map(lines, fn line ->
        line
        |> String.trim()
        |> String.split(",", trim: true)
      end)
      |> Stream.map(&String.to_integer/1)
      |> Enum.reduce({0, []}, fn num, {max, acc} ->
        cond do
          num > max -> {num, [num | acc]}
          :otherwise -> {max, [num | acc]}
        end
      end)

    {max, Enum.reverse(rev_list)}
  end
end
