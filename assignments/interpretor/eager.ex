defmodule Eager do

  # term() is a built in type and can't be redefined
  # @type term() :: {:atm, atom()} | {:var, atom()} | {:cons, term(), term()}

  # @type pattern() :: term() | :ignore

  #----------------------------Evaluating expressions------------------------------#

  # Evaluating an atom
  def eval_expr({:atm, id}, _) do {:ok, id} end


  # Evaluating a variable
  def eval_expr({:var, id}, env) do
    case Env.lookup(id, env) do
      nil -> :error # Variable isn't bound
      {_, str} -> {:ok, str}
    end
  end


  # Evaluating a cons term
  def eval_expr({:cons, term1, term2}, env) do
    case eval_expr(term1, env) do
      :error -> :error
      {:ok, str1} ->
        case eval_expr(term2, env) do
          :error -> :error
          {:ok, str2} -> {:ok, {str1, str2}}
        end
    end
  end

  #------------------------------Pattern matching----------------------------------#

  # An _ can be matched to anything
  def eval_match(:ignore, _, env) do {:ok, env} end

  def eval_match({:atm, id}, str, env) do # Might need to change structure of the data structure "atm"
    case str do
      ^id -> {:ok, env} # An atom can only be matched to itself
      _ -> :fail
    end
  end

  def eval_match({:var, id}, str, env) do
    case Env.lookup(id, env) do
      nil ->
        {:ok, Env.add(id, str, env)} # We don't care about the structure of str here since a variable can be matched to anything
      {_, ^str} -> # lookup returns {id, value}, we compare the value to the contents of str using pin operator ^
        {:ok, env}
      {_, _} ->
      :fail
    end
  end

  def eval_match({:cons, head, tail}, {head_str, tail_str}, env) do
    case eval_match(head, head_str, env) do
      :fail -> :fail
      {_, ext_env} -> eval_match(tail, tail_str, ext_env)
    end
  end


  def eval_match(_, _, _) do :fail end

  #----------------------------------Sequences-------------------------------------#


  def eval_scope(pattern, env) do
    Env.remove(extract_vars(pattern), env)
  end

  def eval_seq([expr], env) do
    eval_expr(expr, env)
  end

  def eval_seq([{:match, pattern, term} | tail], env) do
    case eval_expr(term, env) do
      :fail -> :error
      {_, str} ->
        env = eval_scope(pattern, env)
        case eval_match(pattern, str, env) do
          :fail -> :error
          {:ok, env} -> eval_seq(tail, env)
        end
    end
  end

  # Function for extracting all variables in an expression
  def extract_vars(expr) do
    extract_vars(expr, [])
  end

  def extract_vars(:ignore, vars) do vars end
  def extract_vars({:atm, _}, vars) do vars end
  def extract_vars({:var, var}, vars) do [var | vars] end
  def extract_vars({:cons, expr1, expr2}, vars) do
    vars = extract_vars(expr1, vars)
    extract_vars(expr2, vars)
  end


end
