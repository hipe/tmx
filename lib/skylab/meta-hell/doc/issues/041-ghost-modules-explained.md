# the core node narrative :[#041]
#todo:during-merge we will rename this file as appropriate

## :#storypoint-005 introduction

MetaHell [mh] was the first low-level subsystem, which is to say it was the
first subsystem used consistently by other subsystems (which in turn get used
by applications). it remains perhaps the most widespread and most ultimately
depended-upon subsystem. while [ba] Basic is hot on its tail, [ba] will likely
always serve as a compliment to it rather than ever being a replacement for it.

the 'Meta' in MetaHell refers of course (?) to meta-programming. as is the
trend with nodes with facetiously negative-sounding names ("regret"),
MetaHell was brought into this world under a heavy shadow of suspicion, and
wa
 it started
out and remains largely a home for any re-usable facilites we build that do
perverted things with meta-programming that have proven to have utility to
more than one subsystem.

some of these were ill-founded experiments that served as a necessary
sandboxes for craziness (the class- and module-creating DSLs, probably the
first [mh] facility, still used in some tests somewhere but totally deprecated
and a bad idea). but by and large, MetaHell is an OK thing.


in roughly descending order of popularity, here are a few of its most
important facilities:

1. MAARS. the recursive auto-vivifying auto-loader is used absolutely
   everywhere. this is the "innovation" that we are most eager to find
   alternatives for, because of how great we think it is. if you love
   something, set it free etc. (MAARS has [#031] a narrative now too)

2. the Bundle facility. it's simply the best thing.

3. Boxxy is kind of a weird fit here, but didn't really fit anywhere else

4. the Item_Grammar is pretty great

5. formal box is the juggernaut that got mostly replaced by [ba] box but is
   still crucial in a few places. (this is slated to move to [ba])

6. fun fields (contoured, etc) were an important frontier space for the
   early exploration of things like iambic DSL's.



## :#storypoint-015

this counter-cultural habbit sprung out of the OCD compulsion not to allocate
memory for objects that we knew would need never be more than their primitive,
monadic forms. consider: at the time of this writing, the frozen empty array
constant is used in about 40 places. granted, allocating memory for 40 arrays
as opposed to one would have a negligible impact on resources when e.g we run
all of our tests, but our reasoning behind this has evolved:

1) for the same reason we use constants in place of literal values generally,
using constants for these values can give the code a louder voice. consider
the case of throwing the empty proc around. if we are frequently passing this
value to the same function from different places, it may be an indication that
this callack argument should perhaps be made optional, or eliminated all
together.

more than just making the code self-documenting, a pattern like this can
transform the code into a sentient being that expresses original thoughts back
up to us.

2) in the case of a potentially mutable value like an array or string, the
fact that these values are frozen acts as a small assertion that the
participating code is not mutating these values (if that is indeed what we
expect). again this makes to code more expressive (but this time at runtime),
perhaps telling us things we didn't know about our logic.



## :#storypoint-025: the ghost modules of autoloader explained :[#054]

basic autoloading is the first and only facility to be made available out of
the box to all nodes in the skylab universe. as such, its module is put one
level under the toplevel module ::Skylab [sl], as ::Skylab::Autoloader.

the extended (and sometimes experimental) autoloading facilities -- things
like autovivification and recursion -- are given a home under MetaHell [mh],
which at present feels like an approrpriate semantic fit. as such, all of
the implementation for these live under ::Skylab::MetaHell::Autoloader. note
there are now two (2) distinct constants (modules) with the local name
'Autoloader'.

why are those semantically similar things in two different places?
because the extended behavior "feels" like it belongs in a library subsystem,
we put it there. it "feels" bloaty having all of it crammed under a prominent,
high-level node. but we don't put all of it there, because, as is stated above,
basic autoloading is a facility depeneded on universe-wide, and subsystems
are by definition not universally visible.

but in practice it is useful to conceptualize the basic autoloading as being
"logically" housed under [mh] even though it is "physically" housed under
[sl].

these, then, are the corollaries of the above:

  • *all* unit tests for autoloading, including basic autoloading and its
    child behavior nodes (like inflection), live under [mh], inline with
    all the other subsystem test suites.

  • ::Skylab::MetaHell::Autoloader becomes a "ghost" of ::Skylab::Autoloader:
    they are not merely two references for the same module (we tried this);
    each module needs to know its own location distinct from the other, and
    has different concerns. Rather, we include the one into
    the other so that its constants are accessible that way (this mitigates
    our need to use fully qualified names or "import" the constant explicitly,
    at risk of hiding what's really going on.) but the uptake is, note that
    the real ::Skylab::MetaHell::Autoloader has no real content of its own:
    it exists to pull in constants defined above it, and house modules below
    it.

  • one gotcha is that there end up being three (3) modules with the local
    name 'Autoloader': one, immediately under [sl]; two under [mh]; and three
    is the taxonomic ("folder-like") module under the TestSupport module for
    mh[]. use fully qualified names as necessary, or when verbose clarity is
    useful.



## :#storypoint-110 the way bundle name resolution works

### bundle "storage" names as const names

every typical bundle (as implemented by this library) has at least two names.
these names are derivaties of each other. to understand how the typical bundle
names work it helps to understand that typical bundles are stored as
constants in a module (and incidentally they are usually implemented either as
a proc or like a module that is shaped sort of like a proc).

we were guided to this choice by parsimony (although it took some getting
there.) this same principle leads us to use the module name (more specificaly
the const namee) to constitute the name of the bundle.

constants in ruby must follow the name-pattern of (something like)
/^[A-Z][A-Za-z0-9_]+$/. as stated above, the bundle gets its name from the
const name, so this pattern also dictates how we may name our bundles.

### bundle "employment" names are const names un-title-cased

however when a client wishes to employ a bundle, it does not typically use
this (const) name. it is designed like so both for aesthetics and for the
sake of implementation hiding: the client module musn't have knowledge of the
particulars of the way the bundles are implemented; that's the whole point of
using them.

currently the logic is this: typically your bundle's "storage" name (that is,
the const name) is two or more characters long and the second character is not
a capital letter (or weirdly the name is one character long, but don't do
this). in such a case, the "employment" name (that is, the name by which the
bundle is referenced to be employed) is simply the storage name with the
first character (necessarily in uppercase) downcased.

we typically use underscores instead of camel-casing to demarcate mutli-termed
names because no sophisticated regexp logic is employed to translate the
name:

so if the const name is 'Magical_methods', the "employment" name is
'magical_methods'. if it's 'WiERD_NAME', it becomes 'wiERD_NAME'. with this
scheme you simply cannot have an employment name that is title-cased:
'Sly_Fox' becomes 'sly_Fox'.

### a special exception for TLA's

however, if your bundle is stored under a const name that is 2 characters or
longer and the second character is a capital letter [A-Z], then we assume that
the first term of the name is something like a TLA (a three letter acronym):
so, if the const name is 'NSCA_spy', we assume that all those letters are to
remain capitalized when it in the "employment" name. in such cases, to derive
the employement name we use the storage name as-is.

### conclusion & implementation

this deceivingly simple name translation scheme somehow garnished a page-long
description. but the uptake is, employment names look sort of like constant
names, and whether or not they are exactly the same as the constant name is
determined by the case of the second character of the constant name.

we used to provide this #hook-in, but it was removed due to a total absence of
distribution in the current branch:

    k = if x.respond_to? :bundles_key then x.bundles_key

because the name translation rules are deterministic and we do no fuzzy
matching, we eagerly pre-calculate the employment names for each of the
bundles and cache an index of them this way. we do this with the expectation
that there is a greater number of bundle employments than there are bundles,
and as such it would feel wasteful to re-calculate name translations for the
same bundle name multiple times.

so what you are seeing at the code-point is this indexing being calculated.
