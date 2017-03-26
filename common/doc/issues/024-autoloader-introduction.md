# the new autoloader narrative :[#024]

## objective & scope

### why autoload at all?

  - runtime efficiency

### why use this autoloader over platform autoloading?

  - makes code more readable
  - with less code, reduces the cost of change
  - we *do* use platform autoloading to bootstrap



## the central algorithm (overview) (:#note-1)

we reduce trips to the filesystem by taking "snapshots" of the filesystem
one directory listing at a time as opposed to by checking for one file
at a time. we hold the assumption that all "asset files" will have a
certain extension, and that all directories that hold asset files will
not have an extension. (further details of our assumptions are in the
next section.)




## the isomorphism you must follow to use this autoloading (:#note-2) :[#here.2]

the general convention is this: code "assets" that you want autoloaded
(often classes, but just as possibly non-class modules or any other value)
will (perhaps tautologically) fit into the platforms "const" system.
(in other words, name your classes using consts as your probably do
already.)

these assets will "live" in files that have name that correspond
to the const name (recursively).

so, `::YourGem::YourSubModule::YourClass` is typically in a file named
something like: `lib/your_gem/your-sub-module/your-class.kode`, such that:

  - we use *underscores* to join the word-parts of the gem name, because
    that seems to be the platform idiom when it comes to gem names.

  - however, we use *dashes* to join the word-parts of most other filenames,
    because they are (subjectively) nicer to look at than underscores,
    as many CSS desigers seem to have discovered.





## document meta
  - full rewrite #tombstone
