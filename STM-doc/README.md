# Introducing "Skill Tree Maker"

This is a toy app whose purpose is to learn development with Flutter.

See "app flow" documentation for a journal of how we set up
our Flutter development environment.


# Development Notes (scope)

The main objective of this project (a toy app) is to figure out what our
own process is for other, non-toy apps.

We'll write things we do here for this project as a "scratch space".
As the thing feels like it's part of our process, we'll move the content
into "app flow".


# Development Quick Reference

## Running the app

```bash
$ cd STM ; flutter run -d linux
```


## Run the tests (example for one test)

(from the app directory)

```bash
flutter test test/replication_test.dart --name '^TEST TWO'
```


# Development Log (most recent at top)

This section is to keep a record "for posterity" of how we arrived at various
development processes and tools.

The contents herein won't generally need to be referenced again after
roundabout their first use; except _during development_ (but this remains
to be seen - maybe it _will_ be useful generally).

At some point we may go back and clean this up; in an ongoing manner as
the development ecosystem changes.


## reminder of reverse direction

Reminder: the below sections in this document are added most recent first.
So if you want to read the narrative from the beginning; start at the end
of the section and read each "next" subsection upwards back up to here.


## Fold-in UI changes from the "advanced version"

At the end of [this first codelab][cl1] they link to [this advanced version][cl2]
that does some cool animation transitions.

We're gonna attempt to fold-in these changes so we get "all of" the example
UI and functionality; the main reason being: this version of the app has
functionality that we require in our own app. Also this version has usability
improvements that will look good in our app.

(This was accomplished in #history-A.2.)


## `sqflite` on linux

Only once we sat down to follow the cookbook we discovered that sqlite
isn't available on linux desktop out of the box.

1. We googled "sqflite linux" (sic)
1. found [this][gh1]

Our unit test awkwardly creates a database file with the schema the code
defines, which we consider as "passing" at writing.



## We are following this codelab

We are following [this codelab][cl1].


## Appendix: flutter upgrades

Generally we upgrade flutter "as soon" as a new version (patch version
or more significant) is reported to us by the thing that reports it.

A cursory search didn't at first glance tell us how this information
is supposed to be versioned so here's how we're doing it instead.

```bash
$ flutter upgrade
```

- At #history-A.5 we upgraded flutter to version 3.10.4
- At #history-A.4 we upgraded flutter to version 3.10.2 (sic)
- At #history-A.4 we upgraded flutter to version 3.10.1
- At #history-A.3 we upgraded flutter to version 3.10.0
- At #history-A.1 we upgraded flutter to version 3.7.12


## beginnings: .. the beginnings.

Googled "flutter what to commit" got [dart what not to commit][g01].
Using that as a basis for our one-off script committed in this same
commit as this writing.


# Appendix: Other things we learned about dart

Our main learning of dart happened with pen & paper. Subsections in this
section are addendum to that. We order them aesthetically (top to bottom).


## Streams

Googled "dart stream", got [this](https://dart.dev/tutorials/language/streams).

(We ended up not using `Stream` at the one particular place. We suspect
an issue with the vendor library but we aren't sure yet. #[#892.E].)


## Data tables

Googled "flutter data table", found its class page and a widget of the week
video.


# (the identifier registry)

(Our range: [#892-#894])

| ID      | Main Tag | Content  |
|---------|:-----:|----|
|[#895]   | #exmp | This is an example issue
|[#892.I] |       | this one issue
|[#892.8] |       | learning how to test
|[#892.G] |       | "Cupertino Panopticon": grok [this link][cu1] somehow
|[#892.6] |       | case study: grid view case study
|[#892.E] |       | track various needs for refactoring
|[#892.D] | #open | You don't know how to require not at the top of the file
|[#892.3] |       | Replication notes
|[#892.2] |       | Flutter from scratch
|[#892.1] |       | Digraph of things from notebook


[gh1]: https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/using_ffi_instead_of_sqflite.md#initialization
[g01]: https://dart.dev/guides/libraries/private-files
[cu1]: https://api.flutter.dev/flutter/cupertino/cupertino-library.html
[cl2]: https://dartpad.dev/e7076b40fb17a0fa899f9f7a154a02e8
[cl1]: https://codelabs.developers.google.com/codelabs/flutter-codelab-first


# (document-meta)

- #history-A.5: as referenced
- #history-A.4: as referenced
- #history-A.3: as referenced
- #history-A.2: as referenced
- #history-A.1: as referenced
- #born
