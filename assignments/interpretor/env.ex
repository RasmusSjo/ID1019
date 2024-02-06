defmodule Env do

    # Returns an empty map
    def new() do [] end


    # Returns a new map containing the new id-str pair in sorted order
    def add(id, str, []) do
      [{id, str}]
    end

    def add(id, str, [{id, _} | tail]) do
      [{id, str} | tail]
    end

    def add(id, str, [{head_id, head_str} | tail]) do
      if id < head_id do
        [{id, str}, {head_id, head_str} | tail]
      else
        [{head_id, head_str} | add(id, str, tail)]
      end
    end


    # Returns the id-str pair associated to the id or nil if id wasn't bound
    def lookup(id, [{id, head_str} | _]) do
      {id, head_str}
    end

    def lookup(_, []) do :nil end

    def lookup(id, [_ | tail]) do
      lookup(id, tail)
    end


    # Removes the id-str pair associated with the id(s)
    def remove([], env) do env end

    def remove([first_id | rest_ids], env) do
      updated = remove(first_id, env)
      remove(rest_ids, updated)
    end

    def remove(id, [{id, _} | tail]) do tail end

    def remove(_, []) do [] end

    def remove(id, [head | tail]) do
      [head | remove(id, tail)]
    end

    # Function for creating a new environment only containing the
    # variable identifiers provided
    def closure([], _) do [] end

    def closure(free, env) do
      closure(free, [], env)
    end

    def closure([], closure, _) do closure end

    def closure([id | tail], closure, env) do
      case lookup(id, env) do
        :nil ->
          :error
        {id, str} ->
          closure(tail, [{id, str} | closure], env)
      end
    end

    def args([], [], env) do {:ok, env} end

    def args([], _, _) do :error end

    def args(_, [], _) do :error end

    def args([param | params], [str | strs], env) do
      args(params, strs, add(param, str, env))
    end

end
