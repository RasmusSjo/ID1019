defmodule EnvTree do

  # Node is a built-in type and can't be redefined, hence the commented line
  # @type node() :: :nil | {:node, atom(), number(), node(), node()}

  # Adds a key-value pair to an empty tree, returns a new tree
  def add(:nil, key, value) do
    {:node, key, value, :nil, :nil}
  end

  # If the key already exists, replace the current value
  def add({:node, key, _, left, right}, key, value) do
    {:node, key, value, left, right}
  end

  # If the key-value pair should be added to the left subtree
  def add({:node, some_key, some_value, left, right}, key, value) when key < some_key do
    {:node, some_key, some_value, add(left, key, value), right}
  end

  # If the key-value pair should be added to the left subtree
  def add({:node, some_key, some_value, left, right}, key, value) do
    {:node, some_key, some_value, left, add(right, key, value)}
  end

  # An empty tree doesn't contain any key-value pairs
  def lookup(:nil, _) do :nil end

  # If the key-value pair is found
  def lookup({:node, key, value, _, _}, key) do {key, value} end

  # If the the searched key should be in the left subtree
  def lookup({:node, some_key, _, left, _}, key) when key < some_key do
    lookup(left, key)
  end

  # If the the searched key should be in the right subtree
  def lookup({:node, _, _, _, right}, key) do
    lookup(right, key)
  end


end
