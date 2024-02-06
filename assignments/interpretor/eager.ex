defmodule Eager do

  # term() is a built in type and can't be redefined
  @type expression() :: {:atm, atom()}
    | {:var, atom()}
    | {:cons, expression(), expression()}

  @type pattern() :: {:atm, atom()}
  | {:var, atom()}
  | {:cons, expression(), expression()}
  | :ignore

  @type match() :: {:match, pattern(), expression()}

  @type sequence() :: [expression()] | [match() | sequence()]

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

  # Evaluating a case expression
  def eval_expr({:case, expr, cls}, env) do
    case eval_expr(expr, env) do
      :error -> :error
      {:ok, str} ->
        eval_cls(cls, str, env)
    end
  end

  def eval_expr({:lambda, params, free, seq}, env) do
    case Env.closure(free, env) do
      :error -> :error
      closure -> {:ok, {:closure, params, seq, closure}}
    end
  end

  def eval_expr({:fun, id}, _) do
    {par, seq} = apply(Prgm, id, [])
    {:ok, {:closure, par, seq, Env.new()}}
  end

  def eval_expr({:apply, expr, args}, env) do
    case eval_expr(expr, env) do
    :error ->
      :error
    {:ok, {:closure, params, seq, closure}} ->
      case eval_args(args, env) do
        :error ->
          :error
        {:ok, strs} ->
          case Env.args(params, strs, closure) do
            :error ->
              :error
            {:ok, updated} ->
              eval_seq(seq, updated)
          end
      end
    end
  end

  def eval_args(args, env) do
    eval_args(args, [], env)
  end

  def eval_args([], strs, _) do {:ok, Enum.reverse(strs)} end

  def eval_args([arg | args], strs, env) do
    case eval_expr(arg, env) do
      :error ->
        :error
      {_, str} ->
        eval_args(args, [str | strs], env)
    end
  end

  def eval_cls([], _, _) do :error end

  def eval_cls([{:clause, ptrn, seq} | clauses], str, env) do
    case eval_match(ptrn, str, eval_scope(ptrn, env)) do # Remove vars in the pattern from the env so that it can be matched
      :fail -> eval_cls(clauses, str, env)
      {:ok, env} -> eval_seq(seq, env)
    end
  end

  #------------------------------Pattern matching----------------------------------#

  # An _ can be matched to anything
  def eval_match(:ignore, _, env) do {:ok, env} end

  def eval_match({:atm, id}, str, env) do
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

  def eval_match({:cons, ptrn1, ptrn2}, {str1, str2}, env) do
    case eval_match(ptrn1, str1, env) do
      :fail -> :fail
      {_, updated} -> eval_match(ptrn2, str2, updated)
    end
  end

  def eval_match(_, _, _) do :fail end

  #----------------------------------Sequences-------------------------------------#

  def eval_seq([expr], env) do
    eval_expr(expr, env)
  end

  def eval_seq([{:match, ptrn, term} | tail], env) do
    case eval_expr(term, env) do
      :fail -> :error
      {_, str} ->
        env = eval_scope(ptrn, env)
        case eval_match(ptrn, str, env) do
          :fail -> :error
          {:ok, env} -> eval_seq(tail, env)
        end
    end
  end

  def eval_scope(ptrn, env) do
    Env.remove(extract_vars(ptrn), env)
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
