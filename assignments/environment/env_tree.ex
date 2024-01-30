defmodule EnvTree do

  # Node is a built-in type and can't be redefined, hence the commented line
  # @type node() :: :nil | {:node, atom(), number(), node(), node()}

  # Create a new map
  def new() do :nil end


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

  # If the key-value pair should be added to the right subtree
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


  # Can't remove from an empty tree
  def remove(:nil, _) do :nil end

  # If the right branch is empty, the left one can be "moved" up
  def remove({:node, key, _, left, :nil}, key) do left end

  # If the left branch is empty, the right one can be "moved" up
  def remove({:node, key, _, :nil, right}, key) do right end

  # If neither the left or right is empty, the rightmost value in the left branch will be moved up
  def remove({:node, key, _, left, right}, key) do
    {new_left, right_key, right_value} = rightmost(left)
    {:node, right_key, right_value, new_left, right}
  end

  # Given key is smaller than key in node so remove in left subtree
  def remove({:node, some_key, some_value, left, right}, key) when key < some_key do
    {:node, some_key, some_value, remove(left, key), right}
  end

  # Given key is larger than key in node so remove in right subtree
  def remove({:node, some_key, some_value, left, right}, key) do
    {:node, some_key, some_value, left, remove(right, key)}
  end

  # Retrieve the key-value pair and move the left branch up when rightmost node is found
  def rightmost({:node, key, value, left, :nil}) do {left, key, value} end

  # Continue searching for the rightmost node and reconstruct the current node
  def rightmost({:node, key, value, left, right}) do
    {new_right, right_key, right_value} = rightmost(right)
    {{:node, key, value, left, new_right}, right_key, right_value}
  end

end
