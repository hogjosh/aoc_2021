defmodule Day11 do
  def sim() do
    grid =
      "input.txt"
      |> File.stream!()
      |> parse()
      |> Enum.to_list()

    Stream.repeatedly(fn -> 1 end)
    |> Stream.with_index(1)
    |> Stream.map(&elem(&1, 1))
    |> Enum.reduce_while(grid, fn step, grid ->
      {grid, count} = sim_step(step, grid)

      cond do
        count == 100 -> {:halt, step}
        :otherwise -> {:cont, grid}
      end
    end)
  end

  def sim_step(_step, grid) do
    {grid, flashes} = sim_octs(octs(), {energize(grid), []})

    {reset(grid, flashes), Enum.count(flashes)}
  end

  def sim_octs(octs, {grid, flashes}) do
    Enum.reduce(octs, {grid, flashes}, &sim_oct/2)
  end

  def sim_oct(oct, {grid, flashes}) do
    cond do
      oct in flashes ->
        {grid, flashes}

      :otherwise ->
        case at(oct, grid) do
          energy when energy > 9 -> flash(oct, {grid, [oct | flashes]})
          _ -> {grid, flashes}
        end
    end
  end

  def flash(oct, {grid, flashes}) do
    adjacents = adjacents(oct, grid)
    grid = Enum.reduce(adjacents, grid, &energize/2)
    sim_octs(adjacents, {grid, flashes})
  end

  def adjacents({y, x}, grid) do
    [
      {y - 1, x},
      {y - 1, x + 1},
      {y, x + 1},
      {y + 1, x + 1},
      {y + 1, x},
      {y + 1, x - 1},
      {y - 1, x - 1},
      {y, x - 1}
    ]
    |> Enum.reduce([], fn oct, acc ->
      case at(oct, grid) do
        nil -> acc
        _energy -> [oct | acc]
      end
    end)
    |> Enum.reverse()
  end

  def energize(grid) do
    Enum.reduce(octs(), grid, &energize/2)
  end

  def energize({y, x}, grid) do
    update_at({y, x}, grid, &(&1 + 1))
  end

  def reset(grid, octs) do
    Enum.reduce(octs, grid, &update_at(&1, &2, fn _ -> 0 end))
  end

  def octs(), do: for(y <- 0..9, x <- 0..9, do: {y, x})

  def at({y, x}, grid) when y in 0..9 and x in 0..9 do
    grid
    |> Enum.at(y)
    |> Enum.at(x)
  end

  def at({_y, _x}, _grid), do: nil

  def update_at({y, x}, grid, fun) when y in 0..9 and x in 0..9 do
    List.update_at(grid, y, fn row ->
      List.update_at(row, x, fn energy ->
        fun.(energy)
      end)
    end)
  end

  def parse(lines) do
    Stream.map(lines, fn line ->
      line
      |> String.trim()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
