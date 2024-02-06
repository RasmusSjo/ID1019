defmodule Eval do

  @type literal() :: {:num, number()} | {:var, atom()} | {:q, number(), number()}

  @type expr() :: literal() |
    {:add, expr(), expr()} |
    {:sub, expr(), expr()} |
    {:mul, expr(), expr()} |
    {:div, expr(), expr()}


  def test(test_num) do

    env = %{x: 7, y: 4, z: -2}

    expr = case test_num do
      1 ->  {:add,
              {:mul, {:num, 2}, {:var, :x}},
              {:num, 4}} # 2x + 4 = 14 --- 2 * 5 + 4
      2 ->  {:add,
              {:mul,
                {:var, :z},
                {:sub, {:var, :y}, {:num, 3}}},
              {:mul, {:num, 3}, {:var, :x}}} # z(y - 3) + 3x = 13 --- -2 * (4 - 3) + 3 * 5
      3 ->  {:q, 1, 2}
      4 ->  {:add,
              {:num, 5},
              {:q, 1, 2}} # 5 + 1/2 = 11/2 {:q, 11, 2}
      5 ->  {:mul,
              {:num, 2},
              {:q, 3, 4}}
      6 ->  {:div,
              {:num, 5},
              {:q, 5, 2}}
      7 ->  {:mul,
              {:add,
                {:div, {:num, 13}, {:q, 5, 9}},
                {:q, 7, 3}},
              {:sub,
                {:q, 2, 5},
                {:q, 3, 10}}} # (x/(5/9) + 7/3) * (2/5 - 3/10) = 2.573333
      8 ->  {:sub,
              {:q, 2, 5},
              {:q, 3, 10}}
      9 ->  {:add,
              {:div, {:num, 13}, {:q, 5, 9}},
              {:q, 7, 3}}
      10 -> {:mul,
              {:add,
                {:div, {:var, :x}, {:q, 5, 9}},
                {:q, 7, 3}},
              {:sub,
                {:q, 2, 5},
                {:num, 3}}}
      11 -> {:sub, {:num, 2}, {:num, 3}}
      12 -> {:sub,
              {:q, 2, 5},
              {:num, 3}}
      _ -> :error
    end

    # Test
    IO.write("Expression #{pprint(expr)} is evaluated to #{pprint(eval(expr, env))}\n")
    :ok
  end

  # An integer is evaluated to itself
  def eval({:num, num}, _) do {:num, num} end

  # A rational number is evaluated itself
  def eval({:q, num1, num2}, _) do {:q, num1, num2} end

  # A variable is evaluated to it value
  def eval({:var, var}, env) do
    {_, value} = Map.fetch(env, var) # Implementation assumes that the var-value pair exists in the environment
    {:num, value}
  end


  # Evaluating addition
  def eval({:add, {:num, num1}, {:num, num2}}, _) do {:num, num1 + num2} end

  def eval({:add, {:num, num}, {:q, num1, num2}}, _) do simplify({:q, num1 + num2 * num, num2}) end

  def eval({:add, {:q, num1, num2}, {:num, num}}, _) do simplify({:q, num1 + num2 * num, num2}) end

  def eval({:add, {:q, num1, num2}, {:q, num3, num4}}, _) do simplify({:q, num1 * num4 + num3 * num2, num2 * num4}) end

  def eval({:add, expr1, expr2}, env) do
    eval({:add, eval(expr1, env), eval(expr2, env)}, env)
  end


  # Evaluating subtraction
  def eval({:sub, {:num, num1}, {:num, num2}}, _) do {:num, num1 - num2} end

  def eval({:sub, {:num, num}, {:q, num1, num2}}, _) do simplify({:q, num * num2 - num1, num2}) end

  def eval({:sub, {:q, num1, num2}, {:num, num}}, _) do simplify({:q, num1 - num * num2, num2}) end

  def eval({:sub, {:q, num1, num2}, {:q, num3, num4}}, _) do simplify({:q, num1 * num4 - num3 * num2, num2 * num4}) end

  def eval({:sub, expr1, expr2}, env) do
    eval({:sub, eval(expr1, env), eval(expr2, env)}, env)
  end


  # Evaluating multiplication
  def eval({:mul, {:num, num1}, {:num, num2}}, _) do {:num, num1 * num2} end

  def eval({:mul, {:num, num}, {:q, num1, num2}}, _) do simplify({:q, num * num1, num2}) end

  def eval({:mul, {:q, num1, num2}, {:num, num}}, _) do simplify({:q, num * num1, num2}) end

  def eval({:mul, {:q, num1, num2}, {:q, num3, num4}}, _) do simplify({:q, num1 * num3, num2 * num4}) end

  def eval({:mul, expr1, expr2}, env) do
    eval({:mul, eval(expr1, env), eval(expr2, env)}, env)
  end


  # Evaluating division
  def eval({:div, {:num, num1}, {:num, num2}}, _) do simplify({:q, num1, num2}) end

  def eval({:div, {:num, num}, {:q, num1, num2}}, _) do simplify({:q, num * num2, num1}) end

  def eval({:div, {:q, num1, num2}, {:num, num}}, _) do simplify({:q, num1, num2 * num}) end

  def eval({:div, {:q, num1, num2}, {:q, num3, num4}}, _) do simplify({:q, num1 * num4, num2 * num3}) end

  def eval({:div, expr1, expr2}, env) do
    eval({:div, eval(expr1, env), eval(expr2, env)}, env)
  end


  # Simplifying a rational number
  def simplify({:q, num1, num2}) do
    if Integer.mod(num1, num2) == 0 do
      {:num, Integer.floor_div(num1, num2)}
    else
      gcd = Integer.gcd(num1, num2)
      {:q, Integer.floor_div(num1, gcd), Integer.floor_div(num2, gcd)}
    end
  end


  # Functions for pretty printing
  def pprint({:num, num}) do "#{num}" end

  def pprint({:q, numerator, denominator}) do "#{numerator}/#{denominator}" end

  def pprint({:var, var}) do "#{var}" end

  def pprint({:add, expr1, expr2}) do
    "(#{pprint(expr1)} + #{pprint(expr2)})"
  end

  def pprint({:sub, expr1, expr2}) do
    "(#{pprint(expr1)} - #{pprint(expr2)})"
  end

  def pprint({:mul, expr1, expr2}) do
    "#{pprint(expr1)} * #{pprint(expr2)}"
  end

  def pprint({:div, expr1, expr2}) do
    "#{pprint(expr1)}/#{pprint(expr2)}"
  end

end
