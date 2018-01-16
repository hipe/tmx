# game server

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
