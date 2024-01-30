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
    def remove([first_id | rest_ids], env) do
      env = remove(first_id, env)
      remove(rest_ids, env)
    end

    def remove(id, [{id, _} | tail]) do tail end

    def remove(_, []) do [] end

    def remove(id, [head | tail]) do
      [head | remove(id, tail)]
    end

end
