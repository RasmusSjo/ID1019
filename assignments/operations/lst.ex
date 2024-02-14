defmodule Lst do

  # Returns the length of the list
  def len([]) do 0 end
  def len([_ | tail]) do 1 + len(tail) end

  # Returns a list of all even numbers
  def even([]) do [] end
  def even([head | tail]) do
    case rem(head, 2) do
        0 -> [head | even(tail)]
        _ ->even(tail)
    end
  end

  # Returns a list where each element of the given list has been incremented by a value
  def increase([], _) do [] end
  def increase([head | tail], num) do
    [head + num | increase(tail, num)]
  end

  # Returns the sum of all values of the given list
  def sum([]) do 0 end
  def sum([head | tail]) do
    head + sum(tail)
  end

  # Returns a list where each element of the given list has been decremented by a value
  def decrease([], _) do [] end
  def decrease([head | tail], num) do
    [head - num | decrease(tail, num)]
  end

  # Returns a list where each element of the given list has been multiplied by a value
  def multiply([], _) do [] end
  def multiply([head | tail], num) do
    [head * num | multiply(tail, num)]
  end

  # Returns a list of all odd number
  def odd([]) do [] end
  def odd([head | tail]) do
    if rem(head, 2) == 1 do
      [head | odd(tail)]
    else
      odd(tail)
    end
  end

  # Returns a list with the result of taking the reminder of dividing the original by some integer
  def remainder([], _) do [] end
  def remainder([head | tail], num) do
    [rem(head, num) | remainder(tail, num)]
  end

  # Returns the product of all values of the given list (product of an empty list is 1)
  def prod([]) do 1 end
  def prod([head | tail]) do
    head * prod(tail)
  end

  # Returns a list of all numbers that are evenly divisible by some number
  def divide([], _) do [] end
  def divide([head | tail], num) do
    if rem(head, num) == 0 do
      [head | divide(tail, num)]
    else
      divide(tail, num)
    end
  end

  #----------------------------------Higher order functions--------------------------------------#

  # Map function
  def transform([], _) do [] end
  def transform([head | tail], func) do
    [func.(head) | transform(tail, func)]
  end

  # Normal recursive reducer function
  def reduce([], initial_value, _) do initial_value end
  def reduce([head | tail], initial_val, func) do
    func.(reduce(tail, initial_val, func), head)
  end

  # Tail-recursive reduce function
  def reduce_tail([], initial_val, _) do initial_val end
  def reduce_tail([head | tail], val, func) do
    reduce_tail(tail, func.(val, head), func)
  end

  # Normal recursive filter function
  def filter([], _) do [] end
  def filter([head | tail], func) do
    case func.(head) do
      true -> [head | filter(tail, func)]
      false -> filter(tail, func)
    end
  end

  # Tail recursive filter function, order is preserved
  def filter_pre([], _, acc) do acc end
  def filter_pre([head | tail], func, acc) do
    case func.(head) do
      true -> filter_pre(tail, func, acc ++ [head])
      false -> filter_pre(tail, func, acc)
    end
  end

  # Tail recursive filter function, order isn't preserved
  def filter_tail([], _, acc) do acc end
  def filter_tail([head | tail], func, acc) do
    case func.(head) do
      true -> filter_tail(tail, func, [head | acc])
      false -> filter_tail(tail, func, acc)
    end
  end

  #----------------------------------HOF Implementations--------------------------------------#

  def length_hof(list) do
    reduce_tail(list, 0, fn(len, _) -> len + 1 end)
  end

  def even_hof(list) do
    filter(list, fn(x) -> rem(x, 2) == 0 end)
  end


  def inc_hof(list, num) do
    transform(list, fn(x) -> x + num end)
  end


  def sum_hof(list) do
    reduce(list, 0, fn(total, x) -> total + x end)
  end


  def dec_hof(list, num) do
    transform(list, fn(x) -> x - num end)
  end


  def mul_hof(list, num) do
    transform(list, fn(x) -> x * num end)
  end


  def odd_hof(list) do
    filter(list, fn(x) -> rem(x, 2) == 1 end)
  end


  def rem_hof(list, num) do
    transform(list, fn(x) -> rem(x, num) end)
  end


  def prod_hof(list) do
    reduce(list, 1, fn(prod, x) -> prod * x end)
  end


  def div_hof(list, num) do
    filter_pre(list, fn(x) -> rem(x, num) == 0 end, [])
  end

  def sum_square(list, x) do
    filter(list, fn(num) -> num < x end) |>
    transform(fn(x) -> x * x end) |>
    sum_hof()
  end


end
