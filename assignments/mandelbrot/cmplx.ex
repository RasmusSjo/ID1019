defmodule Cmplx do

  # Returns a new complex numbers z = a + bi
  def new(a, b) do {a, b} end

  # Returns the sum of two complex numbers z = a + bi
  def add({a1, b1}, {a2, b2}) do {a1 + a2, b1 + b2} end

  # Returns the square of a complex number z = a + bi
  # (a + bi)^2 = a^2 - b^2 + 2abi
  def sqr({a, b}) do {a * a - b * b, 2 * a * b} end

  # Returns the absoult value of a complex number z = a + bi
  def abs({a, b}) do :math.sqrt(a * a + b * b) end

end
