# the "baseless collection" plugin lib :[#028]

## historical context

read about the historical context of this plugin library at [#001] - it's
"library 5". there was once good reason to let Quickie roll its own
plugin solution, but the desire to promote code re-use (and reduce
redundancy) has now trumped that.

this library remains both lightweight and CLI-leaning. whether it's
outright inferior or superior to "library 7" ([#004] "digratphic") is an
open and perhaps meaningless question - this appears simpler and less
powerful.




## about the name

we call it "baseless" because it does not require (nor allow) the plugin
nodes to subclass anything from here. rather, (in the spirit of
[#ac-001]) the plugins must implement certain hook-out methods.

it its way this makes making new plugins "easy" because rather than
reading up on the API you can just see what fails and add the necessary
methods as needed.

we call it "collection" because the only public node of this library is
the class that models the whole collection of plugins.
_
