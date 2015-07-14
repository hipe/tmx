# the application narrative :[#005]

(EDIT: this no longer belongs in [gv])

## :#this-node-looks-funny-because-it-is-multi-domain (SUNSETTED)

this application-top file looks a lot different than its cousin files
in other subsystems because of how much new and strange infrastructure
is being developed in this project:

• our server must use true concurrency *so*
• our server must run in (e.g) rbx *and*
• general skylab code is not (yet) rbx compatible *so*
• we re-write those parts of general skylab that we need here
 • which is of course a good first step towards the goal of [sl]-rbx compat.
• those parts include things like:
 • autoloading

because this top core will be used by a variety of sub-sub-systems with a
significant variety of different (and at times mutually incompatible)
environments, it will be focued on very general concerns (like autoloading).

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



## :#storypoint-50

there are filenames that won't pass our "map reduce" "test" to convert a
filename "slug" into a const. this is there both as a safeguard to prevent
the exception that occurs when we try to dereference a constant with an
invalid name, and also this exists to be leveraged intentionally for reasons:

• if the filename contains one or more leading underscores, for example, this
  can be done intentionally to make the file (or directory) be ignored by the
  autoloader. (any first character other than [a-z] (lowercase) will fail the
  white rx for incoming slug names.)

• if for example there was a file there called "foo.tar.gz", then the ".gz"
  would be detected as being an extensioin, and it would be detected that it
  is not an ".rb" extension, and this would not pass because it is not the
  extension we are looking for.

• if for example the file was named "my.weird.class.rb", the ".rb" part would
  pass, but the other dots in the name would make it fail because it would not
  pass the white ("pass-filter") regex.

• it is undefined whether filenames with capitol letters would pass, but the
  file we are looking for must not have capitol letters pursuant to our
  [#hl-156] name conventions on filenames.
