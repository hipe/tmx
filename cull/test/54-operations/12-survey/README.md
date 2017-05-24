## numbering scheme

the [#sl-137].H preferred development order of these operations is:

  1. list
  2. retrieve
  3. delete
  4. create
  5. update


trying to apply the "spirit" of the above to our particular operations,
some of it contradicts the above guidelines..

   8. create
  25. status
  41. upstream
  58. mutator
  74. reduce
  91. aggregator

we put "create" before "status", for whatever reason.
the other four, however, are in a sane order.


also (just for fun) in code, the order of corresponding methods should be:

  - create
  - delete
  - retrieve
  - list

(because mutators go above readers, delete is like create but less complex,
and retrieve goes above list because of the idiomatic story of [#ze-051],
where dereference (equivalent to retrieve here) must be able to dereference
each reference that is produced by the stream method ("list" here))
