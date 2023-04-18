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
xx

The contents herein won't generally  xx (and at some point xx)


## `sqflite` on linux

Only once we sat down to follow the cookbook we discovered that sqlite
isn't available on linux desktop out of the box.

1. We googled "sqflite linux" (sic)
1. found [this][gh1]

Our unit test awkwardly creates a database file with the schema the code
defines, which we consider as "passing" at writing.



## We are following this codelab

We are following [this codelab][cl1].



## We upgraded flutter when it told us a version was available

```bash
$ flutter upgrade
```


## beginnings: .. the beginnings.

Googled "flutter what to commit" got [dart what not to commit][g01].
Using that as a basis for our one-off script committed in this same
commit as this writing.



# (the identifier registry)

(Our range: [#892-#894])

| ID      | Main Tag | Content  |
|---------|:-----:|----|
|[#895]   | #exmp | This is an example issue
|[#892.3] |       | Replication notes
|[#892.2] |       | Flutter from scratch
|[#892.1] |       | Digraph of things from notebook



[gh1]: https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/using_ffi_instead_of_sqflite.md#initialization
[g01]: https://dart.dev/guides/libraries/private-files
[cl1]: https://codelabs.developers.google.com/codelabs/flutter-codelab-first



# (document-meta)

- #born
