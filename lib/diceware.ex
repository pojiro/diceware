defmodule Diceware do
  @moduledoc """
  Documentation for `Diceware`.
  """

  @eff_large_wordmap File.read!(Path.join("priv", "eff_large_wordlist.txt"))
                     |> String.split("\n", trim: true)
                     |> Enum.reduce(%{}, fn line, acc ->
                       [k, v] = String.split(line, "\t")
                       Map.put(acc, k, v)
                     end)

  def read_dev_random(bytes) when is_integer(bytes) do
    {binary, 0} = System.cmd("head", ~w"-c #{bytes} /dev/random")
    binary
  end

  def to_number(binary, bytes) when is_binary(binary) and is_integer(bytes) do
    <<number::integer-size(bytes)-unit(8)>> = binary
    number
  end

  def to_dice(number) do
    rem(number, 6) + 1
  end

  def key(bytes \\ 4) do
    for _ <- 1..5 do
      read_dev_random(bytes)
      |> to_number(bytes)
      |> to_dice()
    end
    |> Enum.reduce("", &"#{&2}#{&1}")
  end

  def passphrase() do
    Map.get(@eff_large_wordmap, key())
  end

  def passphrases(count \\ 1) when is_integer(count) do
    for _ <- 1..count, do: passphrase()
  end
end
