defmodule Ranges1 do

  def test() do
    {seeds, maps} = parse(File.read!("input.txt"))

    solve(seeds, maps)
  end

  #--------------------------------Parsing------------------------------------#

  def parse(input) do
    [seeds | maps] = String.split(input, "\n\n") # Separates the seeds from the maps and the maps from eachother

    # Parse seeds
    seeds = seeds
      |> String.split()
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer(&1))

    maps = maps
      |> Enum.map(&parse_map(&1))

    {seeds, maps}
  end

  def parse_map(maps) do
    maps
      |> String.split("\n")
      |> Enum.drop(1)
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(fn line ->
        Enum.map(line, &String.to_integer(&1))

      end)
  end

  #-------------------------------Solving-------------------------------------#

  def solve(seeds, maps) do
    seeds
      |> Enum.map(&seed_to_location(&1, maps))
      |> Enum.min()
  end

  def seed_to_location(location, []) do location end
  def seed_to_location(value, [map | maps]) do
    line = Enum.find(map, :nil, fn [_, src, range] ->
      src <= value and value < src + range
    end)

    location = case line do
      :nil ->
        value
      [dest, src, _] ->
        dest + (value - src)
    end

    seed_to_location(location, maps)
  end
end
