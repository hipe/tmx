# game server :[#006]

## objective & scope

  1. acquire python proficiency (hipe)

  1. experiment with some architecture ideas for
     a modular microservice architecture

  1. at first offer (then explore exisiting) architecture
     that matches some or more of our requirements/interests (below)
     for chat bots

  1. support text-based games along our (again) requirements/interests




## requirements/interests

   - yer basic client/server architecture; targeting multiplayer online
     games (text-based at first) but that could have broader applicability,
     for example to run a chat stack (like slack)

   - it would be great if the underlying architecure were an empty shell
     with little functionality of its own so:

   - a plugin architecture (or if you prefer: a dependency injection
     framework) so that the interesting work happens in plugins.

   - what would be *really* cool is if the plugins (modules/adapters)
     could each be written in their own language (developer's choice)




## contributing - running tests

run one test file

    python3 game_server_test/test_10_basics.py


run the whole test suite

    python3 -m unittest discover game_server_test




## contributing - writing tests <a name="regression-order">

when lots of things break all at once (for example, during a massive
re-architecting), it's useful to be able to narrow the search space
quickly, to determine at what layer of abstraction you should focus on
first to narrow down what is causing the ostensible problem.

it burns up time trying to figure out why a very detailed, high-level
test is broken if it's something fundamental and lowlevel that's the issue.
this is why the author feels strongly about "regression order".

(#todo this is documented in [tmx] yikes)
