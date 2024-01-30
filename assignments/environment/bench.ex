defmodule Bench do

  def bench_list(init_size, test_size) do

    # Creates a list with init_size number of elements in range 1..range
    random_seq = Enum.map(1..init_size, fn(_) -> :rand.uniform(init_size) end)

    # Given the list of random numbers, these are added to an accumulator, which in
    # this case is our map (an empty list to begin with). Every random number in
    # the sequence is then added to the map where duplicates are "removed" since they
    # replace the already present values
    map = Enum.reduce(
      random_seq, # Enumerator
      EnvList.new(), # Accumulator
      fn(random_num, map_acc) -> EnvList.add(map_acc, random_num, :foo) end # Function
    )

  #------------------------------Beginning of benchmarks------------------------------#

    # List of random keys to add to the map
    nums_to_add = Enum.map(1..test_size, fn(_) -> :rand.uniform(init_size) end)

    # Time to add test_size number of key-value pairs
    {add_time, _} = :timer.tc(fn() ->
      Enum.each(nums_to_add, fn(num) ->
        EnvList.add(map, num, :foo)
      end)
    end)

    # Time to lookup test_size number of keys that exists in the tree
    {lookup_time, _} = :timer.tc(fn() ->
      Enum.each(nums_to_add, fn(num) ->
        EnvList.lookup(map, num)
      end)
    end)

    # Time to remove test_size number of keys that exist in the map
    {remove_time, _} = :timer.tc(fn() ->
      Enum.each(nums_to_add, fn(num) ->
        EnvList.remove(map, num)
      end)
    end)

    {init_size, add_time, lookup_time, remove_time}
  end


  def bench_tree(init_size, test_size) do

    # Creates a list with init_size number of elements in range 1..range
    random_seq = Enum.map(1..init_size, fn(_) -> :rand.uniform(init_size) end)

    # Given the list of random numbers, these are added to an accumulator, which in
    # this case is our map (an empty list to begin with). Every random number in
    # the sequence is then added to the map where duplicates are "removed" since they
    # replace the already present values
    map = Enum.reduce(
      random_seq, # Enumerator
      EnvTree.new(), # Accumulator
      fn(random_num, map_acc) -> EnvTree.add(map_acc, random_num, :foo) end # Function
    )

  #------------------------------Beginning of benchmarks------------------------------#

    # List of random keys to add to the map
    nums_to_add = Enum.map(1..test_size, fn(_) -> :rand.uniform(init_size) end)

    # Time to add test_size number of key-value pairs
    {add_time, _} = :timer.tc(fn() ->
      Enum.each(nums_to_add, fn(num) ->
        EnvTree.add(map, num, :foo)
      end)
    end)

    # Time to lookup test_size number of keys that exists in the tree
    {lookup_time, _} = :timer.tc(fn() ->
      Enum.each(nums_to_add, fn(num) ->
        EnvTree.lookup(map, num)
      end)
    end)

    # Time to remove test_size number of keys that exist in the map
    {remove_time, _} = :timer.tc(fn() ->
      Enum.each(nums_to_add, fn(num) ->
        EnvTree.remove(map, num)
      end)
    end)

    {init_size, add_time, lookup_time, remove_time}
  end


  def bench(test_size) do
    init_sizes = [16, 32, 64, 128, 256, 512, 1024, 2 * 1024, 4 * 1024, 8 * 1024]

    :io.format("# Benchmark with ~w operations, time per operation in us\n", [test_size])
    :io.format("~6.s~12.s~13.s~12.s\n", ["List:", "add", "lookup", "remove"])

    Enum.each(init_sizes, fn (init_size) ->
      {init_size, add_time, lookup_time, remove_time} = bench_list(init_size, test_size)
      :io.format("~6.w & ~10.2f & ~10.2f & ~10.2f \\\\\n", [init_size, add_time/test_size, lookup_time/test_size, remove_time/test_size])
    end)

    IO.puts("")
    :io.format("~6.s~12.s~13.s~12.s\n", ["Tree:", "add", "lookup", "remove"])
    Enum.each(init_sizes, fn (init_size) ->
      {init_size, add_time, lookup_time, remove_time} = bench_tree(init_size, test_size)
      :io.format("~6.w & ~10.2f & ~10.2f & ~10.2f \\\\\n", [init_size, add_time/test_size, lookup_time/test_size, remove_time/test_size])
    end)

  end

end
