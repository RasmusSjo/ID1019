defmodule Brot do

  def mandelbrot({a, b}, max_iterations) do
    z0 = Cmplx.new(a, b)

    i = 0

    test(i, z0, z0, max_iterations)
  end

  def test(iteration,_ ,_, max_iteration) when iteration == max_iteration do 0 end
  def test(iteration, z, z0, max_iterations) do
    z_i = Cmplx.add(Cmplx.sqr(z), z0)
    case Cmplx.abs(z_i) do
      n when n <= 2 ->
        test(iteration + 1, z_i, z0, max_iterations)
      _ ->
        iteration
    end
  end
end
