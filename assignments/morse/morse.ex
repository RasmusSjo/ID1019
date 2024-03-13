defmodule Morse do

  # The codes that you should decode:

  def base, do: '.- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ...'

  def rolled, do: '.... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .----'

  # The decoding tree.
  #
  # The tree has the structure  {:node, char, long, short} | :nil
  #

  def tree do
    {:node, :na,
      {:node, 116,
        {:node, 109,
          {:node, 111,
            {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
            {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
          {:node, 103,
            {:node, 113, nil, nil},
            {:node, 122,
              {:node, :na, {:node, 44, nil, nil}, nil},
              {:node, 55, nil, nil}}}},
        {:node, 110,
          {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
          {:node, 100,
            {:node, 120, nil, nil},
            {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
      {:node, 101,
        {:node, 97,
          {:node, 119,
            {:node, 106,
              {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}},
              nil},
            {:node, 112,
              {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}},
              nil}},
          {:node, 114,
            {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
            {:node, 108, nil, nil}}},
        {:node, 105,
          {:node, 117,
            {:node, 32,
              {:node, 50, nil, nil},
              {:node, :na, nil, {:node, 63, nil, nil}}},
            {:node, 102, nil, nil}},
          {:node, 115,
            {:node, 118, {:node, 51, nil, nil}, nil},
            {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
  end

  #-----------------------------------Signal decoding-----------------------------------#

  def decode(signal) do
    decode(signal, Morse.tree)
  end

  def decode(signal, tree) do
    decode(signal, tree, tree, [])
  end

  def decode([], {:node, :na, _long, _short}, _tree, decoding) do
    Enum.reverse(decoding)
  end

  def decode([], {:node, char, _long, _short}, _tree, decoding) do
    # char is prepended if
    Enum.reverse([char | decoding])
  end

  def decode([?- | chars], {:node, _char, long, _short}, tree, decoding) do
    decode(chars, long, tree, decoding)
  end

  def decode([?. | chars], {:node, _char, _long, short}, tree, decoding) do
    decode(chars, short, tree, decoding)
  end

  def decode([?\s | chars], {:node, :na, _long, _short}, tree, decoding) do
    decode(chars, tree, tree, decoding)
  end

  def decode([?\s | chars], {:node, char, _long, _short}, tree, decoding) do
    decode(chars, tree, tree, [char | decoding])
  end

  def decode([char | _chars], _node, _tree, _decoding) do
    {:error, "The character '#{List.to_string([char])}' is not a valid signal character"}
  end

  #----------------------------------Message encoding-----------------------------------#

  def encode(message) do
    map = encode_table(Morse.tree, [], Map.new())

    [_ | encoding] = Enum.reduce(message, [], fn char, acc ->
      {_, encoding} = Map.fetch(map, char)
      [' ', encoding | acc]
    end)

    encoding
      |> Enum.reverse()
      |> List.flatten()

  end

  def encode_table({:node, :na, long, short}, path, table) do
    updated = encode_table(long, [?- | path], table)
    encode_table(short, [?. | path], updated)
  end

  def encode_table(:nil, _path, table) do
    table
  end

  def encode_table({:node, char, long, short}, path, table) do
    table = Map.put(table, char, Enum.reverse(path))
    table = encode_table(long, [?- | path], table)
    encode_table(short, [?. | path], table)
  end

  end
