defmodule Day10 do
  def score() do
    "input.txt"
    |> File.stream!()
    |> parse()
    |> Stream.map(&process_line/1)
    |> Stream.reject(fn {_line, chunks} ->
      Enum.any?(chunks, fn {label, _} -> label == :corrupt end)
    end)
    |> Stream.map(&missing_closers/1)
    |> Stream.map(&score_missing_closers/1)
    |> Enum.to_list()
    |> total_score()
  end

  @open ["(", "[", "{", "<"]
  @close [")", "]", "}", ">"]
  @close_to_open Enum.zip(@close, @open) |> Enum.into(%{})
  @open_to_close Enum.zip(@open, @close) |> Enum.into(%{})
  @points [1, 2, 3, 4]
  @score Enum.zip(@close, @points) |> Enum.into(%{})

  def process_line(line) do
    {line,
     line
     |> Stream.with_index()
     |> Stream.transform([], fn {s, ix}, acc ->
       cond do
         s in @open ->
           {[], [{s, ix} | acc]}

         s in @close ->
           case pop(acc) do
             {{open, ox}, acc} ->
               cond do
                 Map.fetch!(@close_to_open, s) == open -> {[{:chunk, {{open, ox}, {s, ix}}}], acc}
                 :otherwise -> {[{:corrupt, {{open, ix}, s}}], acc}
               end
           end
       end
     end)
     |> Enum.to_list()}
  end

  def missing_closers({line, chunks}) do
    Enum.reduce(chunks, line, fn {:chunk, {{_open, ox}, {_close, cx}}}, acc ->
      acc
      |> List.update_at(ox, fn _ -> nil end)
      |> List.update_at(cx, fn _ -> nil end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.reverse()
    |> Enum.map(&Map.fetch!(@open_to_close, &1))
  end

  def score_missing_closers(closers) do
    closers
    |> Enum.map(&Map.fetch!(@score, &1))
    |> Enum.reduce(0, fn points, acc ->
      acc * 5 + points
    end)
  end

  def total_score(scores) do
    ix = div(Enum.count(scores), 2)

    scores
    |> Enum.sort()
    |> Enum.at(ix)
  end

  def pop([]), do: {:empty, []}
  def pop([h | t]), do: {h, t}

  def parse(lines) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "", trim: true))
  end
end
