defmodule Color do

  def convert(depth, max_depth) do
    {x, y} = offset(depth, max_depth)

    case x do
      0 ->
        {:rgb, y, 0, 0}
      1 ->
        {:rgb, 255, y, 0}
      2 ->
        {:rgb, 255 - y, 255, 0}
      3 ->
        {:rgb, 0, 255, y}
      4 ->
        {:rgb, 0, 255 - y, 255}
      _ ->
        {:error, x}
    end
  end

  def offset(depth, max_depth) do
    a = depth/max_depth * 4
    x = trunc(a)
    {x, trunc(255 * (a - x))}
  end

end
