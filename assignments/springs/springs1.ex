defmodule Springs1 do

  def test() do
    rows = parse_rows(File.read!("input.txt"))
    eval_rows(rows)
  end

  def test(seq) do
    rows = parse_rows(seq)
    eval_rows(rows)
  end


  #--------------------------------Eval row functions-----------------------------------#

  def eval_rows([]) do 0 end
  def eval_rows([row | rows]) do
    eval_row(row, 0) + eval_rows(rows)
  end

  def eval_row({[], []}, _) do 1 end
  def eval_row({[], _}, _) do 0 end
  def eval_row({[?. | springs], []}, _) do eval_row({springs, []}, 0) end
  def eval_row({[?. | springs], [num | nums]}, count) do
    case count do
      0 -> eval_row({springs, [num | nums]}, 0)
      _ ->
        if count == num do
          eval_row({springs, nums}, 0)
        else
          0
        end
    end
  end

  def eval_row({[?# | _], []}, _) do 0 end
  def eval_row({[?# | springs], seq}, count) do
    eval_row({springs, seq}, count + 1)
  end

  def eval_row({[?? | springs], seq}, count) do
    eval_row({[?. | springs], seq}, count) + eval_row({[?# | springs], seq}, count)
  end

  #---------------------------------Utility functions-----------------------------------#

  def parse_rows(rows) do
    String.split(rows, "\n") # Splits the sequence of rows into a list where each element is a single row
      |> Enum.map(&parse_row/1)
  end

  def parse_row(row) do
    [status | sequence] = String.split(row, [" ", ","], trim: true)
    {String.to_charlist(status) ++ [?.], Enum.map(sequence, fn value -> String.to_integer(value) end)}
  end

end
