# Elixir Enigma Machine Simulator
# August 2016

# Mike Boone
# https://github.com/boone
# https://twitter.com/boonedocks

# Trying to learn Elixir by modeling an Enigma machine, inspired by the Ruby
# code written by @albert_still in:
# http://red-badger.com/blog/2015/02/23/understanding-the-enigma-machine-with-30-lines-of-ruby-star-of-the-2014-film-the-imitation-game

# Encrypt/decrypt a message with:
#   Enigma.process_string("SECRETMESSAGE")

# To decrypt an encrypted message, supply the encrypted message and the
# matching plugboard, rotor, and reflector configurations:
#   Enigma.process_string("LDINKZRVIDGPO", 'YXSDPFLHVQKGOUMEJRCTNIZBAW',
#     'FKDRHSXGVYNBLZIWMEJQOACUTP', 'XTQFWNBCKYVSZODMJIHPGERAUL',
#     'MZEVUBYCLKHOSIWQNADGFTRPXJ', 'OQFGUCDPZKJVXWAHBTYRELNMSI')

defmodule Enigma do
  def rotor do
    # Return a randomized rotor: a random list of chars from A-Z.
    Enum.take_random(?A..?Z, 26)
  end

  def reflector do
    # Get a random A-Z character list and break it into pairs.
    # For each pair, the first letter will map to the second and vice versa.
    # Create a character list similar to the rotors which represents this
    # reflected pair relationship.
    random_pairs = Enum.chunk(Enum.take_random(?A..?Z, 26), 2)

    # Start with a blank list with 26 empty slots, which we need to fill with
    # the pairs.
    reflector = List.duplicate(nil, 26)

    # Fill in the blank list with the pairs.
    reflector_iterate(random_pairs, reflector)
  end

  def plugboard do
    # The plugboard is like a reflector, but only 10 letters are swapped.
    # The remaining letters map to themselves.
    random_pairs = Enum.chunk(Enum.take_random(?A..?Z, 26), 2)

    # Keep 10 pairs, throw away 6
    random_pairs = Enum.take(random_pairs, 10)

    # Start with an A-Z list.
    plugboard = Enum.to_list(?A..?Z)

    # Overwrite list with the pairs, leaving 6 letters unchanged.
    reflector_iterate(random_pairs, plugboard)
  end

  def process_string(str, plugboard \\ plugboard(), rotor1 \\ rotor(),
    rotor2 \\ rotor(), rotor3 \\ rotor(), reflector \\ reflector()) do

    # We accept any string as input, but we really want a charlist of only
    # A-Z characters, no spacing or punctuation.
    str = str
    |> String.upcase
    |> to_charlist
    |> Enum.reject(fn(x) -> not(x in ?A..?Z) end)

    # Output the configuration of the Enigma machine.
    IO.puts "Plugboard: #{plugboard}"
    IO.puts "Rotor 1:   #{rotor1}"
    IO.puts "Rotor 2:   #{rotor2}"
    IO.puts "Rotor 3:   #{rotor3}"
    IO.puts "Reflector: #{reflector}"

    # Process the message!
    result = iterate(str, plugboard, rotor1, rotor2, rotor3, reflector, 0, [])

    IO.puts "#{str} was translated to #{result}"

    to_string(result)
  end

  defp iterate([head | tail], plugboard, rotor1, rotor2, rotor3, reflector, count, newlist) do
    # Spin Rotor 1
    rotor1 = tick_rotor(rotor1)

    # Spin Rotor 2 if Rotor 1 has gone all the way around.
    rotor2 = case rem(count, 25) do
      0 -> tick_rotor(rotor2)
      _ -> rotor2
    end

    # Spin Rotor 3 if Rotor 2 has gone all the way around.
    rotor3 = case rem(count, 25 * 25) do
      0 -> tick_rotor(rotor3)
      _ -> rotor3
    end

    # Send the character through the plugboard.
    head = list_value(plugboard, head)

    # Send the character through each rotor.
    head = list_value(rotor1, head)
    head = list_value(rotor2, head)
    head = list_value(rotor3, head)

    # Send the character through the reflector.
    head = list_value(reflector, head)

    # Send the character back through the rotors in reverse.
    head = inverted_list_value(rotor3, head)
    head = inverted_list_value(rotor2, head)
    head = inverted_list_value(rotor1, head)

    # Send the character back through the plugboard in reverse.
    head = inverted_list_value(plugboard, head)

    # Append the character to our message.
    newlist = List.insert_at(newlist, -1, head)

    # Track the iteration count.
    count = count + 1

    # Recurse with the remaining message.
    iterate(tail, plugboard, rotor1, rotor2, rotor3, reflector, count, newlist)
  end

  defp iterate([], _, _, _, _, _, _, newlist) do
    # Recursion is complete, return the final character list.
    newlist
  end

  # Character translations are used in both the rotors and the reflector.
  # Here we store them as character lists, where A-Z map to the respective
  # position in the character list. Hence we need functions that will find the
  # translation for 'A' from the list, and vice versa.

  # take the char and find the corresponding translated char in the list
  defp list_value(list, char) do
    Enum.at(list, char - 65)
  end

  # take the translated char and find the corresponding original char
  defp inverted_list_value(list, char) do
    (Enum.find_index list, fn(x) -> x == char end) + 65
  end

  defp reflector_iterate([head | tail], reflector) do
    # head will be a character list with two elements.

    # Add the first/last relationship to the reflector.
    reflector = List.replace_at(reflector, List.first(head) - 65, List.last(head))

    # Add the last/first "reflected" relationship to the reflector.
    reflector = List.replace_at(reflector, List.last(head) - 65, List.first(head))

    # Recurse until complete.
    reflector_iterate(tail, reflector)
  end

  defp reflector_iterate([], reflector) do
    # Recursion is complete, return the final reflector.
    reflector
  end

  defp tick_rotor(rotor) do
    # Spin the rotor to the next position.
    # ABCDEFGHIJKLMNOPQRSTUVWXYZ shifts to BCDEFGHIJKLMNOPQRSTUVWXYZA
    List.insert_at(List.delete_at(rotor, 0), 25, List.first(rotor))
  end
end
