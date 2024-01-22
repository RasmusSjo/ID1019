defmodule Deriv do

  @type literal() :: {:num, number()} | {:var, atom()}

  @type expr() :: literal() |
    {:add, expr(), expr()} |
    {:mul, expr(), expr()} |
    {:exp, expr(), literal()} |
    {:ln, expr()} |
    {:sin, expr()} |
    {:cos, expr()}

  def test(expr_num) do

    expr = case expr_num do
      1 ->  {:add,
              {:mul, {:num, 2}, {:var, :x}},
              {:num, 4}}
      2 ->  {:add,
              {:mul,
                {:var, :pi},
                {:exp, {:var, :x}, {:num, -3}}},
              {:mul, {:num, 3}, {:var, :x}}}
      3 ->  {:exp,
              {:sin, {:mul, {:num, 2}, {:var, :x}}},
              {:num, -1}}
      4 ->  {:ln,
              {:mul,
                {:num, 5},
                {:exp, {:var, :x}, {:num, 2}}}}
      5 ->  {:mul,
              {:add, {:num, 2}, {:var, :x}},
              {:add, {:num, 2}, {:var, :x}}}
      6 ->  {:exp,
              {:exp, {:var, :x}, {:num, 2}},
              {:num, -1}}
      _ -> {:var, :x}
    end

    result = Deriv.deriv(expr, :x)

    IO.write("Expression: #{pprint(expr)}\n")
    IO.write("Derivative: #{pprint(result)}\n")
    IO.write("Simplified: #{pprint(simplify(result))}\n")
    simplify(result)
  end



  # Derivative rules:
  # For numbers
  def deriv({:num, _}, _) do {:num, 0} end

  # For variables
  def deriv({:var, var}, var) do {:num, 1} end

  # For constants, such as pi
  def deriv({:var, _}, _) do {:num, 0} end

  # For addition
  def deriv({:add, expr1, expr2}, var) do
    {:add,
      deriv(expr1, var),
      deriv(expr2, var)}
  end

  # For multiplication
  def deriv({:mul, expr1, expr2}, var) do
    {:add,
      {:mul, deriv(expr1, var), expr2},
      {:mul, expr1, deriv(expr2, var)}}
  end

  # For exponents, this rule also handles square root and division
  def deriv({:exp, expr, {:num, exponent}}, var) do
    {:mul,
      {:mul,
        {:num, exponent},
        {:exp, expr, {:num, exponent - 1}}},
      deriv(expr, var)}
  end

  # For logarithms
  def deriv({:ln, expr}, var) do
    {:mul,
      {:exp, expr, {:num, -1}},
      deriv(expr, var)}
  end

  # For sine
  def deriv({:sin, expr}, var) do
    {:mul,
      {:cos, expr},
      deriv(expr, var)}
  end

  # For cosine
  def deriv({:cos, expr}, var) do
    {:mul,
      {:mul, {:num, -1}, {:sin, expr}},
      deriv(expr, var)}
  end


  # Functions for simplifying expressions
  def simplify({:add, expr1, expr2}) do
    simplify_add(simplify(expr1), simplify(expr2))
  end

  def simplify({:mul, expr1, expr2}) do
    simplify_mul(simplify(expr1), simplify(expr2))
  end

  def simplify({:exp, expr, {:num, exponent}}) do
    simplify_exp(simplify(expr), {:num, exponent})
  end

  def simplify({:ln, expr}) do
    {:ln, simplify(expr)}
  end

  def simplify({:sin, expr}) do
    {:sin, simplify(expr)}
  end

  def simplify({:cos, expr}) do
    {:cos, simplify(expr)}
  end

  def simplify(expr) do expr end

  def simplify_add({:num, 0}, expr2) do expr2 end
  def simplify_add(expr1, {:num, 0}) do expr1 end
  def simplify_add({:num, num1}, {:num, num2}) do {:num, num1 + num2} end
  def simplify_add(expr1, expr2) do {:add, expr1, expr2} end

  def simplify_mul({:num, 0}, _) do {:num, 0} end
  def simplify_mul(_, {:num, 0}) do {:num, 0} end
  def simplify_mul(expr, {:num, 1}) do expr end
  def simplify_mul({:num, 1}, expr) do expr end
  def simplify_mul({:num, num1}, {:num, num2}) do {:num, num1 * num2} end
  def simplify_mul({:var, var}, {:num, num}) do {:mul, num, var} end
  def simplify_mul(expr1, expr2) do {:mul, expr1, expr2} end

  def simplify_exp(0, _) do 0 end
  def simplify_exp(_, {:num, 0}) do 1 end
  def simplify_exp(expr, {:num, 1}) do expr end
  def simplify_exp(expr1, expr2) do {:exp, expr1, expr2} end



  # Functions for pretty printing
  def pprint({:num, num}) do "#{num}" end

  def pprint({:var, var}) do "#{var}" end

  def pprint({:add, expr1, expr2}) do
    "(#{pprint(expr1)} + #{pprint(expr2)})"
  end

  def pprint({:mul, expr1, expr2}) do
    "#{pprint(expr1)} * #{pprint(expr2)}"
  end

  def pprint({:exp, expr, {:num, exponent}}) do
    "(#{pprint(expr)})^#{exponent}"
  end

  def pprint({:ln, expr}) do
    "ln(#{pprint(expr)})"
  end

  def pprint({:sin, expr}) do
    "sin(#{pprint(expr)})"
  end

  def pprint({:cos, expr}) do
    "cos(#{pprint(expr)})"
  end


end
