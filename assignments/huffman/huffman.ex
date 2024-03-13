defmodule Huffman do

  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
  end

  def text() do
    'this is something that we should encode'
  end

  def test do
    sample = sample()
    tree = tree(sample)
    encode = encode_table(tree)
    decode = decode_table(tree)
    text = sample()
    seq = encode(text, encode)
    decode(seq, decode)
      |> to_string()
  end

  def test(path) do
    sample = read(path)
    tree = tree(sample)
    encode = encode_table(tree)
    decode = decode_table(tree)
    seq = encode(sample, encode)
    decode(seq, decode)
      |> to_string()
  end

  def read(file) do
    {:ok, file} = File.open(file, [:read, :utf8])
    binary = IO.read(file, :all)
    File.close(file)
    case :unicode.characters_to_list(binary, :utf8) do
      {:incomplete, list, _} ->
        list
      list ->
        list
    end
  end

  #--------------------------------------Benchmarks-------------------------------------#

  def bench() do
    char_input = read("input.txt")

    # First implementation

    {tree_time, tree} = :timer.tc(fn() ->
      tree(char_input)
    end)

    {encodet_time, encode} = :timer.tc(fn() ->
      encode_table(tree)
    end)

    {decodet_time, decode} = :timer.tc(fn() ->
      decode_table(tree)
    end)

    {encode_time, seq} = :timer.tc(fn() ->
      encode(char_input, encode)
    end)

    {decode_time, results1} = :timer.tc(fn() ->
      decode(seq, decode)
    end)

    # Second implementation

    {tree_time2, tree2} = :timer.tc(fn() ->
      tree(char_input)
    end)


    {encodet_time2, encode2} = :timer.tc(fn() ->
      encode_table2(tree2)
    end)

    {encode_time2, seq2} = :timer.tc(fn() ->
      encode2(char_input, encode2)
    end)

    {decode2_time, results2} = :timer.tc(fn() ->
      decode2(seq2, tree2)
    end)

    if results1 == results2 do
      IO.puts("Same results")
    else
      IO.puts("Different results")
    end

    {tree_time, "1", encodet_time, decodet_time, encode_time, decode_time, "2", tree_time2, encodet_time2, encode_time2, decode2_time}

  end

  #----------------------------------Creating the tree----------------------------------#

  def tree(sample) do
    freqs_queue = frequencies(sample)
    huffman(freqs_queue)
  end

  def frequencies(sample) do frequencies(sample, Map.new()) end
  def frequencies([], freqs) do
    Enum.sort_by(freqs, fn {_char, freq} -> freq end)
      |> Enum.map(fn {char, freq} -> {:leaf, char, freq} end)
  end
  def frequencies([char | rest], freqs) do
    frequencies(rest, Map.update(freqs, char, 1, fn freq -> freq + 1 end))
  end

  def huffman([{type, tree, _freq}]) do {type, tree} end # All nodes have been added
  def huffman([{t1, node1, freq1}, {t2, node2, freq2} | rest]) do
    Enum.sort_by([{:node, {{t1, node1}, {t2, node2}}, freq1 + freq2}] ++ rest,
      fn {_type, _node, freq} -> freq end)
      |> huffman()
  end

  # Function for inserting a node in sorted order
  def put([], node) do [node] end
  def put([{t2, node2, freq2} | rest], {t1, node1, freq1}) when freq1 < freq2 do
    [{t1, node1, freq1}, {t2, node2, freq2}] ++ rest
  end
  def put([{type, node2, freq2} | rest], updated) do
    [{type, node2, freq2}] ++ put(rest, updated)
  end

  #----------------------------------Encoding the tree----------------------------------#

  def encode_table(tree) do
    Enum.sort_by(encode_table(tree, []), fn {_key, value} -> length(value) end)
  end
  def encode_table({:leaf, char}, path) do
    [{char, Enum.reverse(path)}]
  end
  def encode_table({:node, {left, right}}, path) do
    encode_table(left, [0 | path]) ++ encode_table(right, [1 | path])
  end

  def encode_table2(tree) do
    Enum.sort_by(encode_table2(tree, []), fn {_key, value} -> length(value) end)
  end

  def encode_table2({:leaf, char}, path) do
    [{char, path}]
  end

  def encode_table2({:node, {left, right}}, path) do
    encode_table2(left, [0 | path]) ++ encode_table2(right, [1 | path])
  end



  #----------------------------------Decoding the tree----------------------------------#

  def decode_table(tree) do
    Enum.sort_by(decode_table(tree, []), fn {key, _value} -> length(key) end)
  end
  def decode_table({:node, {left, right}}, path) do
    decode_table(left, [0 | path]) ++ decode_table(right, [1 | path])
  end
  def decode_table({:leaf, char}, path) do
    [{Enum.reverse(path), char}]
  end

  #-----------------------------------Encoding a text-----------------------------------#

  def encode([], _table) do [] end
  def encode([char | rest], table) do
    # Assuming the text is a character list
    lookup(table, char) ++ encode(rest, table)
  end

  def encode2(seq, table) do encode2(seq, table, []) end
  def encode2([], _table, encoding) do Enum.reverse(encoding) end
  def encode2([char | rest], table, encoding) do encode2(rest, table, lookup(table, char) ++ encoding) end

  #-------------------------------Decoding a bit-sequence-------------------------------#

  def decode([bit | rest], table) do
    decode(rest, table, [bit], [])
  end
  def decode([], table, path, decoding) do
    Enum.reverse([lookup(table, path) | decoding])
  end
  def decode([bit | rest], table, path, decoding) do
    case lookup(table, path) do
      :nil ->
        decode(rest, table, path ++ [bit], decoding)
      char ->
        decode(rest, table, [bit], [char | decoding])
    end
  end

  # Decode2 using the initial tree instead of the lookup table
  def decode2(seq, tree) do
    decode2(seq, tree, tree, [])
  end
  def decode2([], _tree, {:leaf, char}, decoding) do Enum.reverse([char | decoding]) end
  def decode2(seq, tree, {:leaf, char}, decoding) do
    decode2(seq, tree, tree, [char | decoding])
  end
  def decode2([0 | rest], tree, {:node, {left, _right}}, decoding) do
    decode2(rest, tree, left, decoding)
  end
  def decode2([1 | rest], tree, {:node, {_left, right}}, decoding) do
    decode2(rest, tree, right, decoding)
  end

  def lookup([], _key) do :nil end
  def lookup([{key, value} | _rest], key) do value end
  def lookup([_head | rest], key) do lookup(rest, key) end

end
