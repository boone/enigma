defmodule Enigma do
  @moduledoc """
    Elixir Enigma Machine Simulator
    August 2016

    Mike Boone
    https://github.com/boone
    https://twitter.com/boonedocks

    Trying to learn Elixir by modeling an Enigma machine, inspired by the Ruby
    code written by @albert_still in:
    http://red-badger.com/blog/2015/02/23/understanding-the-enigma-machine-with-30-lines-of-ruby-star-of-the-2014-film-the-imitation-game

    Encrypt/decrypt a message with:
      Enigma.process_string("SECRETMESSAGE")

    To decrypt an encrypted message, supply the encrypted message and the
    matching plugboard, rotor, and reflector configurations:
      Enigma.process_string("LDINKZRVIDGPO", 'YXSDPFLHVQKGOUMEJRCTNIZBAW',
        'FKDRHSXGVYNBLZIWMEJQOACUTP', 'XTQFWNBCKYVSZODMJIHPGERAUL',
        'MZEVUBYCLKHOSIWQNADGFTRPXJ', 'OQFGUCDPZKJVXWAHBTYRELNMSI')
  """
  @ascii_offset 65

  @doc """
    Return a randomized rotor: a random list of chars from A-Z.
  """
  def random_rotor do
    Enum.take_random(?A..?Z, 26)
  end

  @doc """
    Get a random A-Z character list and break it into pairs.
    For each pair, the first letter will map to the second and vice versa.
    Create a character list similar to the rotors which represents this
    reflected pair relationship.
  """
  def random_reflector do
    random_pairs = Enum.chunk(Enum.take_random(?A..?Z, 26), 2)

    # Start with a blank list with 26 empty slots, which we need to fill with
    # the pairs.
    List.duplicate(nil, 26)
    # Fill in the blank list with the pairs.
    |> reflector_iterate(random_pairs)
  end

  @doc """
    The plugboard is like a reflector, but only 10 letters are swapped.
    The remaining letters map to themselves.
  """
  def random_plugboard do
    random_pairs =
      Enum.chunk(Enum.take_random(?A..?Z, 26), 2)
      # Keep 10 pairs, throw away 6
      |> Enum.take(10)

    # Start with an A-Z list.
    Enum.to_list(?A..?Z)
    # Overwrite list with the pairs, leaving 6 letters unchanged.
    |> reflector_iterate(random_pairs)
  end

  def process_string(
        input_str,
        plugboard \\ random_plugboard(),
        rotor1 \\ random_rotor(),
        rotor2 \\ random_rotor(),
        rotor3 \\ random_rotor(),
        reflector \\ random_reflector()
      ) do
    # We accept any string as input, but we really want a charlist of only
    # A-Z characters, no spacing or punctuation.
    input_str =
      input_str
      |> String.upcase()
      |> to_charlist
      |> Enum.reject(fn x -> not (x in ?A..?Z) end)

    # Output the configuration of the Enigma machine.
    IO.puts("Plugboard: #{plugboard}")
    IO.puts("Rotor 1:   #{rotor1}")
    IO.puts("Rotor 2:   #{rotor2}")
    IO.puts("Rotor 3:   #{rotor3}")
    IO.puts("Reflector: #{reflector}")

    # Process the message!
    result = iterate(input_str, plugboard, rotor1, rotor2, rotor3, reflector)

    IO.puts("#{input_str} was translated to #{result}")

    to_string(result)
  end

  defp iterate(
         message,
         plugboard,
         rotor1,
         rotor2,
         rotor3,
         reflector,
         count \\ 0,
         newlist \\ []
       )

  defp iterate([head | tail], plugboard, rotor1, rotor2, rotor3, reflector, count, newlist) do
    # Spin Rotor 1
    rotor1 = spin_rotor(rotor1)
    # Spin Rotor 2 if Rotor 1 has gone all the way around.
    rotor2 = rotor2 |> spin_rotor(count, 25)
    # Spin Rotor 3 if Rotor 2 has gone all the way around.
    rotor3 = rotor3 |> spin_rotor(count, 25 * 25)

    translated_char =
      head
      |> send_through(plugboard)
      |> send_through(rotor1)
      |> send_through(rotor2)
      |> send_through(rotor3)
      |> send_through(reflector)
      |> send_back_through(rotor3)
      |> send_back_through(rotor2)
      |> send_back_through(rotor1)
      |> send_back_through(plugboard)

    # Append the character to our message.
    newlist = newlist ++ [translated_char]

    # Recurse with the remaining message.
    iterate(tail, plugboard, rotor1, rotor2, rotor3, reflector, count + 1, newlist)
  end

  defp iterate([], _, _, _, _, _, _, full_list) do
    # Recursion is complete, return the final character list.
    full_list
  end

  # Character translations are used in both the rotors and the reflector.
  # Here we store them as character lists, where A-Z map to the respective
  # position in the character list. Hence we need functions that will find the
  # translation for 'A' from the list, and vice versa.

  @doc """
    take the char and find the corresponding translated char in the list
  """
  defp send_through(char, list) do
    Enum.at(list, char - @ascii_offset)
  end

  @doc """
    take the translated char and find the corresponding original char
  """
  defp send_back_through(char, list) do
    Enum.find_index(list, fn x -> x == char end) + @ascii_offset
  end

  defp reflector_iterate(reflector, [head | tail]) do
    # head will be a character list with two elements.
    reflector
    # Add the first/last relationship to the reflector.
    |> List.replace_at(List.first(head) - @ascii_offset, List.last(head))
    # Add the last/first "reflected" relationship to the reflector.
    |> List.replace_at(List.last(head) - @ascii_offset, List.first(head))
    # Recurse until complete.
    |> reflector_iterate(tail)
  end

  defp reflector_iterate(reflector, []) do
    # Recursion is complete, return the final reflector.
    reflector
  end

  @doc """
    Spin the rotor to the next position.
  """
  defp spin_rotor([head | tail]) do
    tail ++ [head]
  end

  defp spin_rotor(rotor, count, condition) when rem(count, condition) == 0 do
    spin_rotor(rotor)
  end

  defp spin_rotor(rotor, _, _) do
    rotor
  end
end
