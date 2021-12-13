defmodule Day13 do
  def count() do
    {folds, dots} =
      "input.txt"
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.reject(&(&1 == ""))
      |> parse()
      |> Enum.split_with(&fold_instruction?/1)

    grid =
      dots
      |> maxes()
      |> build_grid()
      |> mark_all(dots)

    folds
    |> Enum.reduce(grid, fn fold, acc ->
      fold(fold, acc)
    end)
    |> Stream.map(fn line ->
      Enum.map(line, fn
        "." -> " "
        x -> x
      end)
    end)
    |> Stream.map(&Enum.reverse/1)
    |> Stream.map(&Enum.join/1)
    |> Enum.to_list()
  end

  # horizontal fold
  def fold({:fold, {:y, y}}, grid) do
    {top, [_ | bottom]} = Enum.split(grid, y)
    mirror = Enum.reverse(bottom)

    overlay(top, mirror)
  end

  # vertical fold
  def fold({:fold, {:x, x}}, grid) do
    {rev_left, rev_right} =
      Enum.reduce(grid, {[], []}, fn xs, {acc_left, acc_right} ->
        {lefts, [_ | rights]} = Enum.split(xs, x)
        {[Enum.reverse(lefts) | acc_left], [rights | acc_right]}
      end)

    {left, right} = {Enum.reverse(rev_left), Enum.reverse(rev_right)}

    overlay(right, left)
  end

  def overlay(top, bottom) do
    Enum.zip_with(top, bottom, fn ts, ms ->
      Enum.zip_with(ts, ms, fn
        ".", "." -> "."
        _, _ -> "#"
      end)
    end)
  end

  def mark_all(grid, dots) do
    Enum.reduce(dots, grid, fn {y, x}, acc ->
      mark({y, x}, acc)
    end)
  end

  def mark({y, x}, grid) do
    List.update_at(grid, y, fn xs ->
      List.update_at(xs, x, fn _v -> "#" end)
    end)
  end

  def maxes(dots) do
    Enum.reduce(dots, {0, 0}, fn {y, x}, {max_y, max_x} ->
      {max(max_y, y), max(max_x, x)}
    end)
  end

  def build_grid({max_y, max_x}) do
    Enum.reduce(0..max_y, [], fn _y, acc_y ->
      xs =
        Enum.reduce(0..max_x, [], fn _x, acc_x ->
          ["." | acc_x]
        end)
        |> Enum.reverse()

      [xs | acc_y]
    end)
    |> Enum.reverse()
  end

  def count_dots(grid) do
    Enum.reduce(grid, 0, fn ys, acc ->
      acc + Enum.count(ys, &(&1 == "#"))
    end)
  end

  def extract_dots(grid) do
    grid
    |> Enum.with_index()
    |> Enum.reduce([], fn {values, y}, acc_y ->
      dots =
        values
        |> Enum.with_index()
        |> Enum.reduce([], fn
          {"#", x}, acc_x -> [{y, x} | acc_x]
          _, acc_x -> acc_x
        end)
        |> Enum.reverse()

      acc_y ++ dots
    end)
  end

  def fold_instruction?({:fold, _}), do: true
  def fold_instruction?(_), do: false

  def parse(lines) do
    Stream.map(lines, &parse_line/1)
  end

  def parse_line("fold along" <> coord) do
    [axis, value] =
      coord
      |> String.trim()
      |> String.split("=", trim: true)

    {:fold, {String.to_atom(axis), String.to_integer(value)}}
  end

  def parse_line(line) do
    [x, y] =
      line
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    {y, x}
  end
end
