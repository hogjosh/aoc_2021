defmodule Day08 do
  def count() do
    "input.txt"
    |> File.stream!()
    |> parse()
    |> Enum.take(1)
    |> Enum.map(fn {input, output} ->
      input
      |> identify()
      |> decode(output)
    end)
    |> Enum.sum()
  end

  def identify(input) do
    %{
      2 => [one],
      3 => [seven],
      4 => [four],
      5 => two_three_five,
      6 => zero_six_nine,
      7 => [eight]
    } = Enum.group_by(input, &Enum.count/1)

    [nine, zero, six] = disambiguate(zero_six_nine, {one, four})
    [three, five, two] = disambiguate(two_three_five, {one, four})

    %{
      zero => 0,
      one => 1,
      two => 2,
      three => 3,
      four => 4,
      five => 5,
      six => 6,
      seven => 7,
      eight => 8,
      nine => 9
    }
  end

  # This is a bit tricky and not obvious.
  # 'one' and 'four' end up being lynchpins.
  def disambiguate([a, b, c], {one, four}) do
    Enum.sort_by([a, b, c], fn input ->
      Enum.count(input -- one) + Enum.count(input -- four)
    end)
  end

  def decode(result, output) do
    output
    |> Enum.map(&Map.fetch!(result, &1))
    |> Enum.join()
    |> String.to_integer()
  end

  def parse(lines) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "|", trim: true))
    |> Stream.map(fn line ->
      Enum.map(line, fn ss ->
        ss
        |> String.trim()
        |> String.split(" ", trim: true)
        |> Enum.map(&(String.graphemes(&1) |> Enum.sort()))
      end)
      |> List.to_tuple()
    end)
  end
end
