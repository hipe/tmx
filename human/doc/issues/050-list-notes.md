# list notes

## :#flatten

• for now the native (internal) representation of list data is as a
  single-use stream builder. (this is so that we can wrap possibly large
  datasets efficiently, and the clients need not provide a means to
  build stream, only the stream itself (or an array)).

• for aggregation functions we need to compare this list against other
  lists for semantic equality.

• if we were crazy we could implement a stream-centric function for
  comparision that would cache the head of each stream while comparing
  each next element one-by-one. but we aren't that crazy yet. so to
  implement this comparision, we start with a comparions of the lengths
  of each list (as an array).

• so we need to "flatten" ("flush") the stream to an array.

• aggregations involve comparing an "inside" list against multiple
  "outside" lists over and over multiple times, once for each
  "outside" list. it would be nasty to convert stream-to-list
  over and over for each comparision. so we cache this conversion.

• we want to preserve the ignorance of the rest of the subject
  to this change - to the rest of it we should still be
  once-built-stream-centric.
