defmodule Ranges2 do

  def test() do
    {seeds, maps} = parse(File.read!("input.txt"))

    {time, {min, _}} = :timer.tc(fn() ->
      solve(seeds, maps)
        |> Enum.min
    end)
    {time, min}
  end

  #--------------------------------Parsing------------------------------------#

  def parse(input) do
    [seeds | maps] = String.split(input, "\n\n") # Separates the seeds from the maps and the maps from eachother

    # Parse seeds
    seeds = seeds
      |> String.split()
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer(&1))
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, range] -> {start, start + range - 1} end)

    # Parse maps
    maps = maps
      |> Enum.map(fn map ->
        String.split(map, "\n")
        |> Enum.drop(1)
        |> Enum.map(&String.split(&1, " "))
        |> Enum.map(fn line ->
          Enum.map(line, &String.to_integer(&1))
        end)
        |> Enum.map(fn [dest, src, range] ->
          {:transformation, dest, src, range}
        end)
      end)

    {seeds, maps}
  end

  #-------------------------------Solving-------------------------------------#

  def solve(seeds, []) do seeds end
  def solve(seeds, [map | maps]) do
    seeds
      |> Enum.map(&transform_seeds([&1], map, []))
      |> List.flatten()
      |> solve(maps)
  end

  def transform_seeds([], _, mapped) do List.flatten(mapped) end
  def transform_seeds([seed | seeds], map, mapped) do

    case Enum.find(map, [], fn {:transformation, _, src, range} ->
      intersection(seed, {src, src + range - 1}) != {}
    end) do
      [] -> # Seed doesn't intersect with any transformations and can be considered mapped
        transform_seeds(seeds, map, [seed | mapped])
      {:transformation, dest, src, range} ->
        int  = intersection(seed, {src, src + range - 1})
        unmapped = case difference(seed, int) do
          {} -> # The entire seed is encapsulated by the intersection, i.e. no diff
            seeds
          diff ->
            List.flatten([diff | seeds])
        end
        transform_seeds(unmapped, map, [add(int, dest - src)| mapped])
    end
  end

  #-------------------------------Utilities-----------------------------------#

  def empty() do {} end

  def union({s, e1}, {s, e2}) do {s, Enum.max([e1, e2])} end
  def union({s1, e}, {s2, e}) do {Enum.min([s1, s2]), e} end
  def union({s1, e1}, {s2, e2}) when e1 < s2 or e2 < s1 do [{s1, e1}, {s2, e2}] end
  def union({s1, e1}, {s2, e2}) when e1 < s2 or e2 < s1 do [{s1, e1}, {s2, e2}] end
  def union(r1, r2) do
    [difference(r1, r2), intersection(r1, r2), difference(r2, r1)]
  end

  def intersection({s1, e1}, {s2, e2}) when e1 < s2 or e2 < s1  do empty() end
  def intersection({s, e1}, {s, e2}) do {s, Enum.min([e1, e2])} end
  def intersection({s1, e}, {s2, e}) do {Enum.max([s1, s2]), e} end
  def intersection({s1, e1}, {s2, e2}) when s1 < s2 do
    {s2, Enum.min([e1,e2])}
  end
  def intersection({s1, e1}, {_, e2}) do
    {s1, Enum.min([e1, e2])}
  end

  def difference({s1, e1}, {s2, e2}) when s2 <= s1 and e1 <= e2 do empty() end
  def difference({s1, e1}, {s2, e2}) when s2 <= s1 do {Enum.max([s1, e2 + 1]), e1} end
  def difference({s1, e1}, {s2, e2}) when e1 <= e2 do {s1, Enum.min([e1, s2 - 1])} end
  def difference({s1, e1}, {s2, e2}) do [{s1, s2 - 1}, {e2 + 1, e1}] end

  def add({s, e}, n) do {s + n, e + n} end







end
