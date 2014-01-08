# the mock FS narrative :[#013]

## :#storypoint-5 introduction

years and years ago we knew that chris wanstrath et. al. had a gem like this.
at the time our thinking was, "why would you want to mock the FS?, it's easy
enough to setup and tear down your own filesystem trees on your actual
filesystem, and it's not that much overhead, is it?" "isn't this the kind
of mocking that people hate, the kind that adds too much insulation between
you and the SUT"?

but our thinking may have changed: the current tangent we are on started from
one known point: we must mock git responses. although setting up and tearing
down git repos is certainly an option, (indeed we do so with the bash scripts
that create our fixtures) it apporaches our comfortable limit on coupling to
"outside systems" when testing (generally accepted as problematic for unit-
tyle tests), at least at some testing level.

(also, chris was right: using the real life filesystem gets impractical for
unit testing when you get into things like working with absolute paths.)

this is why in our heads we got obsessed with wanting to have both "live" but
scripted automated tests, and mocked tests. then we could make recordings of
live responses and "play them back", which is the absolute best of both worlds
(#to-do insert tangent here about two-way verification).


## tangent 1: mocking the agent classes

as will be described in [#008] the narrative about [system?] agents, we rely
on these small "method classes" we call "agents" especially for system calls.
this seems like a convenient hookpoint to insert a mock into the mix. for this
first phase of our first in-earnest attempt at mocking anything, we wanted to
do it raw & from the ground up. (no external libraries, and don't write any
libraries of our own yet.) and what we started out with (not pictured) was
indeed raw.

so what we ended up with was agent classes where every system call (e.g circa
three of them) was run through the system call method that was ad-hoc
hand-overidden for that (mock) class (in turn a subclass of the real-life
agent class). the body of this ad-hoc method usually consisted of running some
part of the request through a switch expression and hand-writing the
appropriate result and side-effects.

this was fun for getting the feel of mocking and essential for mocking the
git responses, but for one thing it did not scale. the swith statements got
unweidly, and we ended up with one big file of soup.

for another thing it was super sludgy because we had twice as many classes
to maintain. especially near all the agent classes, the const names of our
mocks had to line up precisely with our reals (because of the ostensibly
clever way we had all of the components resolving their sub-agent classes
with something like e.g `self.class::Foo__` instead of just `Foo__`).


## the idea of lower-level mocking is synthesized from giant shoulders

the sequence of steps we took to get to this "better design" took about half
a day, and was almost pre-determined: first we though "how can we re-work
hacky hand-written switch expressions into something more modular and
scalable?" "how can i reach these scale?"

well in the case of system calls, we would need an unambiguous, deterministic,
normalized representation for them. easy, right? either as the arrays we send
to the `spawn` command, or their strings, having been carefully shell-escaped.

we briefly considered having the system commands isomorph into long method
names so we could easily hand-write aribtrary responses in ruby, but this
quickly fell off the table as being too gangly, hard to read and leaky:

    define_method :"git show --numstat --pretty:format:%ai head -- ./foo" do
      # just because you can't doesn't mean you should
    end

so then we thought: "OK, files." we kind of wanted to get the substrate out
of ruby entirely both because of how jarring it can be having languages inside
languages and because we might be painting ourselves into a corner for reasons
we will describe later relating to #two-way-verification.

we breifly considered JSON and YAML, but we always feel dumb hand-writing
JSON, and YAML might introduce more headaches than is worth having to couple
to parsing API's and having to worry about encoding.

so, TA-DA: we hack out a simple, tab-delimited "manifest" file as a key-value
store, with arbitrary op-codes for the values. this scales well because we
can put different manifests inside of different directories on the filesystem
as needed (yes the same could be said for any other of the above methods).

it doesn't introduce headaches of too much coupling; and it greatly reduces
the "soup-factor" by turning "imperative" mocking logic into "declarative"
(and very readable) manifest files.

and since we are making it ourselves we can strive to keep it as simple as
possible.



## but then we thought, "why stop at system calls?"

in the first place, note that we are no longer mocking "git responses" in
particular, but "system calls" in general. this is a pretty huge "multiplier
effect." this got us thinking about things like "web mock", and crazy forays
we had gone into years ago with recording API responses from external services
(oh tumblr, you were so young).

and it was then that we thought, "given how easy it seems that it will be
to mock system calls, and given that we are already hand-writing calls to
things like ::File#stat (oh by the way we were doing that), and furthermore
given that we have stashed away a plan for "live automated tests" anyway,
how hard would it really be to mock the filesystem for our purposes?

as we looked at it, we realized that a significant manjority of our filesystem
interaction happened through ::Pathname. things like `exist?`, `expand_path`,
even `open` were our typical conduit to the filesystem. so it is from this
point that the experiment begins.



## why not just use wanstrath's library instead?

why do anything yourself ever? given skylab's slant on numerous DIY
testing experiments, we deemed it an appropriate use-case for a home-rolled
solution. also, the scope of our plans for mocking is both narrower *for*
filesystems, and broader *than* filesystems as compared to whatever else is
out there. also, wanstrath et. al have been busy running one of the greatest
websites on the planet and so probably don't maintain piddly little ruby
libraries much.



## why not just subclass Pathname instead?

we have a love-hate relationship with ::Pathname. it is the only library that
we pull-in no matter what universe wide because of how critically we rely on
it. however it has behavior we find problematic (it doesn't play nicely as a
parent class), and often when we read the source we cringe (but granted, a lot
of this may be for reasons that don't interest us, like compatibilty non
POSIX-compliant filesystems).

as long as it feels "simple" we are mocking out those parts of pathname that
we need, and leveraging it somehow for the parts we feel silly re-writing
ourselves.



## :#storypoint-80

we might change the name, but for now, note: don't be confused by our meaning
of "touch". this does NOT mock the behavior of the unix utility `touch`; we
are merely using the same verb and the same semantics. ("touch" is our new
favorite idiomatic name for this category of methods (we used to say "puff"
for this !?) and saying "touch" borrows its namesake from the unix utility of
the same name. so it is neither fortunate nor coincidental that there is room
for some confusion here, but we swallow the pain for the greater good of
consistent name conventions.)



## :#storypoint-90

as ::Pathname does we allow any aribtrary string to constitute our
"deep structure" inner value, which is after all just a frozen string.
however when looking things up in the tree we will want a more normalized
representation to acount for a few behaviors we are after. there is more
at #storypoint-105.



## :#storypoint-105

[po] currently does a simple `String#split` with no second argument in order
to turn a string-based path into its deep-representation, a sequence of hash
values or whatever. what this gets you is that "foo" and "foo/" and "foo///"
all resolve to the same node, which is really just a happy accident that this
works the same as most filesystems. (note the same does not hold for "foo/bar"
vs. "foo//bar".)  the "simple fix" for this would possibly to "correct" [po]
so that it resolves such paths into paths that contain one or more trailing
empty strings. but we don't feel like hacking [po] right now: we are currently
8 sub-tagents deep on the seventh of an 8-step tangent.

instead, what we do (because it is how we specified this mock FS hack to work)
is simply detect multiple trailing slashes in the pathname. but note there
are almost certainly edge cases where we can make this fail, depending on
how our cacheing works..

note that the alternative is equally ugly: according to [po] the "branchiness"
of a node is purely a function of whether or not it has nonzero children
(which is fine and pure and good). so to make our "directory" look like a
"directory" in the eyes of tree, we would have to for those paths in the
manifest that have one or more trailing slashes do something like add a node
with a slug of '.', which suddenly doesn't sound so bad actually..



## :#storypoint-130

we are going for black-box reverse engineering on this one: whatever ::Pn does
on this one, we don't care, we refuse to look (actually it's probably the
underlying filesystem). what our regex says is: one or mor slashes that follow
one slash, OR one or more slashes at the end of the string. these are the kinds
of slashes we remove before we lookup the path in our "filesystem".



## :#storypoint-155

this doesn't add much and might subtract some from its silhouette, but it
is a subtle dig at it.
