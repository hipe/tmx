# the system call fixtures server :[#018]

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
