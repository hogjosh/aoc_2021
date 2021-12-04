defmodule Day04 do
  def score() do
    game =
      "input.txt"
      |> File.stream!()
      |> parse_game()

    {board, number} = winner(game.numbers, game.boards)

    sum(board) * String.to_integer(number)
  end

  def sum(board) do
    board
    |> Stream.flat_map(& &1)
    |> Stream.reject(&(&1 == :x))
    |> Stream.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def winner(numbers, boards) do
    Enum.reduce_while(numbers, boards, fn number, boards ->
      result =
        Enum.reduce_while(boards, [], fn board, acc ->
          board = mark(board, number)

          cond do
            win?(board) -> {:halt, {board, number}}
            :otherwise -> {:cont, [board | acc]}
          end
        end)

      case result do
        {board, number} -> {:halt, {board, number}}
        boards -> {:cont, boards}
      end
    end)
  end

  def mark(board, number) do
    Enum.map(board, fn row ->
      Enum.map(row, fn num ->
        cond do
          num == number -> :x
          :otherwise -> num
        end
      end)
    end)
  end

  def win?(board) do
    board_win?(board) ||
      board_win?(rotate(board))
  end

  def board_win?(board) do
    Enum.reduce_while(board, false, fn row, false ->
      cond do
        row_win?(row) -> {:halt, true}
        :otherwise -> {:cont, false}
      end
    end)
  end

  def rows_win?(board) do
    Enum.reduce_while(board, false, fn row, false ->
      cond do
        row_win?(row) -> {:halt, true}
        :otherwise -> {:cont, false}
      end
    end)
  end

  def row_win?(row) do
    Enum.all?(row, &(&1 == :x))
  end

  def rotate(board) do
    size = Enum.count(board)

    Enum.reduce(0..(size - 1), [], fn ix, acc ->
      col =
        Enum.map(board, fn rows ->
          Enum.at(rows, ix)
        end)

      [col | acc]
    end)
    |> Enum.reverse()
  end

  def parse_game(lines, size \\ 5) do
    init = %{
      numbers: [],
      boards: []
    }

    lines
    |> Stream.map(&parse_line/1)
    |> Stream.reject(&(&1 == []))
    |> Enum.reduce({:numbers, init}, fn
      [line], {:numbers, acc} ->
        {:boards, Map.put(acc, :numbers, String.split(line, ",", trim: true))}

      line, {:boards, acc} ->
        {:boards, Map.update!(acc, :boards, &[line | &1])}
    end)
    |> elem(1)
    |> Map.update!(:numbers, &List.flatten/1)
    |> Map.update!(:boards, fn boards ->
      boards
      |> Enum.reverse()
      |> Enum.chunk_every(size)
    end)
  end

  def parse_line(line) do
    line
    |> String.trim()
    |> String.split(" ", trim: true)
  end
end
