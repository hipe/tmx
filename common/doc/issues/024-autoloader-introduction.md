# the new autoloader narrative :[#024]

## objective & scope

### why autoload at all?

  - runtime efficiency



### why use this autoloader over platform autoloading?

  - makes code more readable
  - with less code, reduces the cost of change
  - we *do* use platform autoloading to bootstrap




## the central algorithm (overview) :[#here.B]

we reduce trips to the filesystem by taking "snapshots" of the filesystem
one directory listing at a time as opposed to by checking for one file
at a time. we hold the assumption that all "asset files" will have a
certain extension, and that all directories that hold asset files will
not have an extension. (further details of our assumptions are in the
next section.)




## the isomorphism you must follow to use this autoloading :[#here.3]

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

  - however (and more relevant to out autoloading generally), we use
    *dashes* to join the word-parts of most other filenames,
    because they are (subjectively) nicer to look at than underscores,
    as many CSS desigers seem to have discovered.




## the main design challenge of this convention :[#here.4]

this convention is not a "lossless" "isomorphism", because filenames
(for our purposes) never use uppercase letters in their names; however
casing *is* used in const names in a manner that cannot be derived
simply from the constituent terms inside the name. huh?

(this property of const names is mentioned at [#060.7] also, but
adds little to this discussion.)

([#here.E] describes cases where we *do* allow captial letters in filenames,
but those cases are not relevant to autoloading (tautologically).)

our oft-used example to illustrate this is a name like `NCSA_Spy`.
(reminder: the use of the underscore in a name like that is explained
at [#bs-029.2].) such a const, if to be given its own file, would be
in a file called "ncsa-spy.rb".

now, we cannot go in the other direction "deterministically". that is,
there is reasonable way to know that "ncsa-spy.rb" holds `NCSA_Spy`
and not `NcsaSpy`. (yes, a human is capable of "probably" inferring
the correct const from a filename, but this requires a priori knowlege
about what terms are likely to be acronyms to an extent we are not
interested in building into our autloading logic.) as such:




## design consequences of this challenge (in summary)

  - often when autoloading we already "know" the correct casing of
    the const before we load the file. in such cases we probably load
    the file and then raise an exception if the expected const isn't
    defined by that file.

  - we can use [#029] "value via const path" (formerly "const reduce")
    to use fuzzy techniques to first load the file and then see what
    consts were set by the file, and then search for the const we think
    we are looking for using fuzzy techniques from there.

  - [#tm-011] and [#dt-006]  (for their reasons) utilize facilities
    (that necessarily contain "hack-peek" in their filenames) to do
    FRAGILE tricks to infer the consts that files define before those
    files are loaded. eek!




### sidebar: for aesthetics, we *do* allow the use of uppercase letters.. :[#here.E]

in filenames IFF *both* of these criteria are met:

  - uppercase letters may be used only to comprise all the letters
    of an acronym (so not for titlecase, not for camelcase).

  - uppercase letters may be used only if the file or directory would
    never possibly be autoloaded (so never for an "asset" (i.e non-test
    "code") file).

in practice this means that we are allowed to (encouraged to, even) use
all caps for such terms those filenames that are part of test files and the
directories that hold them (but no test support files or the directories
that hold them), and also for filenames of documentation ("document") files.



## document meta

  - full rewrite #tombstone
