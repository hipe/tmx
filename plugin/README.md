# the plugin sidesystem :[#001]


## objective & scope

a toolkit for dependency injection. *not* a one-size-fits-all approach.
rather, a collection of models and "magnetics" than can be pieced together
to assit in architectures resembling a "plugin framework".

see [#008] "the plugin manifesto" for something resembling our "philosophy".




## history

the immediate reason that [pl] was created was to be a more focused,
dedicated sidesystem for the somewhat ancient bundle- and plugin-related
"leftover scraps" from [m-h] as it was dissolved: we wanted to get rid of
that lib proper, but some of its facilities were still needed by some legacy
applications.

but when we moved [#024] the "fancy lookup" proc to here, [pl] became an
essential member of The Pantheon of skylab support libraries. as such,
the subject has become *the* home for all plugin-like solutions.




## a justification for the utility of dependency injection frameworks..

is outside the scope of this document `^_^ #yolo ¯\_(ツ)_/¯`




## a one-line summary of each item

( hopelessly confused, needs rewrite, waiting for #open [#gi-014] #tmp-tombstone-A )
( we should be able to use the above utility to trace renames, but it breaks at some )



## brief tombstones & related

  - library 8 of N: [#012] née "filesystem based", now "[etc]". abstracted
    from [sy] did solely to facilitate the cleanup of its architecture.

  - library 7 of N: (WILL SUNSET)


## library 7 of N: digraph-powered simplification of predecessor

this is a synopsis of what is at [#004]:

  • no more shell/kernel pattern. there is just one plugin dispatcher
    class, one plugin base class, and tons of little ancillary classes.

  • plain-old-programming with small classes as much as possible over
    overwrought interfaces.

  • the most advanced, expressive yet implementation of a digraph-driven
    plugin architecture.



  - library 6 of N: (WILL SUNSET)


## library 6 of N: [gv] rolls an intra-reusable solution

(EDIT: this was so excellent and simple, that headless's contemporary solution
was bumped over to face and this was bumped up to headless.)

although every collection of code has its own reasons for doing things in its
own weird way, this particular solution calls itself "the best" for the
following reasons:

  • it is as simple as possible while being as complex as necssary:
  • name-mappings and name translations are kept to a minimum.
    for example, all event channels must have the same name as their
     corresponding callback methods, so here they all follow the name pattern
     /^on_.+/, as do all event channels.
  • rather than the complex API of 'meta-services' that [hl] employs, here
    the plugin host simply implements one lone "plugin conduit" subclass
    that will be used for two-way communication from host to plugin.
  • plugins need not subclass anything in particular; they derive services
    from the host via the shell passed to them in their construction, and
    they subscribe to events via following the method-naming patterns
    (that is, subscribing to events and declaring public methods with
    particulr names are one and the same.)
  • we offer a *much* simplifield solution to the "crowded namespace"
    problem of different plugins wanting to define different options: each
    plugin automatically gets its name appended to each option it defines
    (it defines its options via a "recorder" proxy without knowing it).



  - library 5 of N: [#023] "baseless" will suset or repurpose

## library 5 of N: [ts] Quickie rolls a reasonable custom solution.

(UPDATE: this moved to here and is now [#023]. EDIT: this makes half of
the below historial sentiment. we add fresh commentary in a dedicated
document at that node but the below is still half-relevant.)

for quickie to have its own custom solution makes like easier because
we can use the quickie in the same distribution as the plugin lib
(or whichever) we are developing without breaking quickie.

although it's not as minimal and powerful as our latest effort, this stab
at plugins is easily comprehendable; and by this point it's clear that 90%
of what we are doing "now" was established by this point.


  - library 4 of N: [fa] `Services_` sunsetted because it fell ill

  - library 3 of N: [hl] Plugin library became whatever [#ts-025] "slowie"
    does. used 4x times once, cross-poliated others, sunsetted.

  - library 2 of N: [tr] ended up being mostly a plugin architecture
    (really just for output adapters) and ended up being mostly an exercize.

  - library 1 of N: [!as] had a self-rolled, ancient solution. sunsetted
    when that project was dissoved into [tmx] "map" (select) operation.





## document meta

  - #tombstone-B: susetted longer synopses of each legacy solution
  - #tombstone-A: got rid of confused list
