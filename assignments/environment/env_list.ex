defmodule EnvList do

  # Returns an empty map
  def new() do [] end



  # Returns a new map containing the new key-value pair in sorted order
  def add([], key, value) do
    [{key, value}]
  end

  def add([{key, _} | tail], key, value) do
    [{key, value} | tail]
  end

  def add([{some_key, some_value} | tail], key, value) do
    if key < some_key do
      [{key, value}, {some_key, some_value} | tail]
    else
      [{some_key, some_value} | add(tail, key, value)]
    end
  end

  # Returns the key-value pair associated to the key or nil if key wasn't found
  def lookup([{key, some_value} | _], key) do
    {key, some_value}
  end

  def lookup([], _) do :nil end

  def lookup([_ | tail], key) do
    lookup(tail, key)
  end

  # Removes the key-value pair associated with the key
  def remove([{key, _} | tail], key) do tail end

  def remove([], _) do [] end

  def remove([head | tail], key) do
    [head | remove(tail, key)]
  end
end
