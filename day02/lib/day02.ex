defmodule Day02 do
  def position do
    "input.txt"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " ", trim: true))
    |> Stream.map(fn [dir, x] -> {dir, String.to_integer(x)} end)
    |> Stream.map(fn
      {"up", x} -> fn {h, d, a} -> {h, d, a - x} end
      {"down", x} -> fn {h, d, a} -> {h, d, a + x} end
      {"forward", x} -> fn {h, d, a} -> {h + x, d + a * x, a} end
    end)
    |> Enum.reduce({0, 0, 0}, & &1.(&2))
  end
end
