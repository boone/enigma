defmodule EnigmaTest do
  use ExUnit.Case, async: true

  describe "random init" do
    test "rotor" do
      assert Regex.match?(~r/\A[A-Z]{26}\z/, to_string(Enigma.random_rotor()))
    end

    test "reflector" do
      assert Regex.match?(~r/\A[A-Z]{26}\z/, to_string(Enigma.random_reflector()))
    end

    test "plugboard" do
      assert Regex.match?(~r/\A[A-Z]{26}\z/, to_string(Enigma.random_plugboard()))
    end
  end

  describe "cypher/decypher" do
    test "process_string" do
      # use known rotors, reflector, and plugboard, and ensure the message is
      # properly encrypted/ecrypted
      rotor1 = 'YXSDPFLHVQKGOUMEJRCTNIZBAW'
      rotor2 = 'FKDRHSXGVYNBLZIWMEJQOACUTP'
      rotor3 = 'XTQFWNBCKYVSZODMJIHPGERAUL'
      reflector = 'MZEVUBYCLKHOSIWQNADGFTRPXJ'
      plugboard = 'OQFGUCDPZKJVXWAHBTYRELNMSI'

      cleartext_string = "SECRETMESSAGE"

      encrypted_string =
        Enigma.process_string(cleartext_string, rotor1, rotor2, rotor3, reflector, plugboard)

      assert encrypted_string == "LDINKZRVIDGPO"

      decrypted_string =
        Enigma.process_string(encrypted_string, rotor1, rotor2, rotor3, reflector, plugboard)

      assert decrypted_string == cleartext_string
    end

    test "it should not encrypt the same char twice with the same letter" do
      # use known rotors, reflector, and plugboard, and ensure the message is
      # properly encrypted/ecrypted
      rotor1 = 'YXSDPFLHVQKGOUMEJRCTNIZBAW'
      rotor2 = 'FKDRHSXGVYNBLZIWMEJQOACUTP'
      rotor3 = 'XTQFWNBCKYVSZODMJIHPGERAUL'
      reflector = 'MZEVUBYCLKHOSIWQNADGFTRPXJ'
      plugboard = 'OQFGUCDPZKJVXWAHBTYRELNMSI'

      cleartext_string = "AAA"

      encrypted_string =
        Enigma.process_string(cleartext_string, rotor1, rotor2, rotor3, reflector, plugboard)

      assert encrypted_string == "XVF"

      decrypted_string =
        Enigma.process_string(encrypted_string, rotor1, rotor2, rotor3, reflector, plugboard)

      assert decrypted_string == cleartext_string
    end
  end
end
