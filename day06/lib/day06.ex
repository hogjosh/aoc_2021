defmodule Day06 do
  def fishes() do
    "input.txt"
    |> File.stream!()
    |> parse()
    |> simulate_days(256)
    |> Enum.reduce(0, fn {_fish, count}, acc -> acc + count end)
  end

  def simulate_days(fishes, days) do
    Enum.reduce(1..days, Enum.frequencies(fishes), fn _day, acc ->
      simulate_day(acc)
    end)
  end

  def simulate_day(freqs) do
    Enum.reduce(freqs, %{}, fn
      {0, count}, acc ->
        acc
        |> Map.update(6, count, &(&1 + count))
        |> Map.update(8, count, &(&1 + count))

      {fish, count}, acc ->
        Map.update(acc, fish - 1, count, &(&1 + count))
    end)
  end

  def parse(lines) do
    lines
    |> Stream.flat_map(fn line ->
      line
      |> String.trim()
      |> String.split(",", trim: true)
    end)
    |> Stream.map(&String.to_integer/1)
  end
end
