defmodule Day03 do
  def power() do
    "input.txt"
    |> File.stream!()
    |> parse()
    |> counts()
    |> gamma()
    |> then(&{&1, epsilon(&1)})
    |> then(fn {gamma, epsilon} ->
      decimal(gamma) * decimal(epsilon)
    end)
  end

  def life() do
    parsed =
      "input.txt"
      |> File.stream!()
      |> parse()
      |> Enum.to_list()

    oxygen = mask(&oxygen_criteria/1, parsed)
    co2 = mask(&co2_criteria/1, parsed)

    decimal(oxygen) * decimal(co2)
  end

  def mask(criteria_fun, numbers) do
    Enum.reduce_while(0..11, numbers, fn ix, acc ->
      criteria =
        acc
        |> counts()
        |> criteria_fun.()

      acc
      |> Enum.map(fn number ->
        {number, Enum.zip_with(criteria, number, &==/2)}
      end)
      |> Enum.filter(fn {_number, mask} -> Enum.at(mask, ix) end)
      |> Enum.map(&elem(&1, 0))
      |> case do
        [number] -> {:halt, number}
        acc -> {:cont, acc}
      end
    end)
  end

  def oxygen_criteria(counts) do
    Enum.map(counts, fn
      x when x < 0 -> 0
      _ -> 1
    end)
  end

  def co2_criteria(counts) do
    counts
    |> oxygen_criteria()
    |> Enum.map(fn
      0 -> 1
      1 -> 0
    end)
  end

  def parse(lines) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s |> String.graphemes() |> Enum.map(&String.to_integer/1)
    end)
  end

  def counts(numbers) do
    Enum.reduce(numbers, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], fn num, acc ->
      Enum.zip_with(acc, num, &(&1 + offset(&2)))
    end)
  end

  def offset(0), do: -1
  def offset(1), do: 1

  def decimal(bin) do
    bin
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end

  def gamma(counts) do
    Enum.map(counts, fn
      x when x > 0 -> 1
      x when x < 0 -> 0
    end)
  end

  def epsilon(gamma) do
    Enum.map(gamma, fn
      0 -> 1
      1 -> 0
    end)
  end
end
