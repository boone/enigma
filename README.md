# Elixir Enigma Machine Simulator

Trying to learn Elixir by modeling an Enigma machine, inspired by the Ruby code written by Albert Still in [Understanding the Enigma machine with 30 lines of Ruby](http://red-badger.com/blog/2015/02/23/understanding-the-enigma-machine-with-30-lines-of-ruby-star-of-the-2014-film-the-imitation-game).

Mine is a lot more than 30 lines, but it's heavily commented and Elxir seems to have less magic ways of handling lists and maps than Ruby does with arrays and hashes.

If you're an Elixir pro, feel free to suggest improvements!

Encrypt/decrypt a message with:

```elixir
Enigma.process_string("SECRETMESSAGE")
```

To decrypt an encrypted message, supply the encrypted message and the
matching plugboard, rotor, and reflector configurations:

```elixir
Enigma.process_string("LDINKZRVIDGPO", 'YXSDPFLHVQKGOUMEJRCTNIZBAW',
  'FKDRHSXGVYNBLZIWMEJQOACUTP', 'XTQFWNBCKYVSZODMJIHPGERAUL',
  'MZEVUBYCLKHOSIWQNADGFTRPXJ', 'OQFGUCDPZKJVXWAHBTYRELNMSI')
```

## TODO

* Create some analogs of the real rotors used and try to decrypt some known messages.

* Play around with the variants like the four-rotor Enigma.

## Contact

[boonedocks.net](http://boonedocks.net)

[@boonedocks](https://twitter.com/boonedocks) on Twitter
