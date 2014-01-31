# the application narrative :[#005]

## :#this-node-looks-funny-because-it-is-multi-domain

we put this section up top because although its inspiration stems from the
fixtures server, it has implications for the whole project. we experiment
with our own autoloader for .. reasons. we squeeze everything out of this
top 'core.rb' node but this for those resasons.

specifically this node will be loaded for at least three concerns: 1) it
will be loaded by any scripts seeking to build a (CLI) client, e.g the tmx,
or just the standalone CLI client (and that will need to load lots subsystems
for its concerns); 2) the fixtures-building scripts will load this node to
get an autoloader; and 3) the insane server experiment (the focus of this
document) will load this to get autoloader.

for the server experiment this will be running under a rubinius and not an
MRI ruby. we are not worrying about getting the skylab diaspora working under
rubinius generally (*yet*), but as explained above, this core.rb is meant to
be usedful to several concerns, including some that run under rubninius. hence
this core.rb looks a lot different because it can't load its sibling nodes
outright, nodes that do not yet target rbx.
## :#introduction

this is one of the most ridiculous tangents we've indulged on in a very long
time. we went off to jupiter and turned around, and here we are stopped at
saturn and working our way back to earth, with the intention of going back to
jupiter again. we intend to draw this out to its logically extreme culmination,
but we have decided to do so iteratively for the usual reasons (it makes a nice
story, it builds a better foundation, and we learn it better this way).

for now, this is a quick & dirty proof of concept to get us famliiar with:
  • the idea of having a long running process at all (feature [#019])
  • possibly mucking with different rubies talking to each other on
    the same system, just for the lols (and for the threads, only where
    we need them) (yes this is ridiculous, and is feature [#020])
  • see if we can "rainbow kick" a server ("rainbow kick" is the name we made
    up for the ides of a client starting a server herself if one hasn't been
    started yet, via a fork & exec omg.) (feature [#021])
  • see if we can give the server a heartbeat it listens to and an automatic
    shutdown after some timeout (feature [#022]).
  • be forwarned: we plan on using 'sleep' to create artificial latency.
    this is the kind of wicked game we are playing with ourself.
