"""SO...

here we conceive of the collection as a numberspace (just a range) with each
"spot" (integer) in the range either already occupied by an item or it's an
open "slot" available for an item to be placed in it.

our behavior for "new identifier provision" is that each time we have a new
item to place in the collection, we chose a slot pseudo-randomly so that on
balance the items are placed in to the space with a flat, even distribution.

"why" is outside of this scope, but the short of it is that it's about
avoiding smells:

  - it's a smell to assume that your items will be yielded out in the same
    order they were added in (more specifically it's a big liability).

  - thought should be put into what "business sequence" means. one should
    design and specify explicitly how to represent business sequence in
    data; rather than it being an afterthought decided implicitly by the
    datastore in its implementation detail.

if you have 1,000 "slots" then the first number you allocate you say
"give me a random number between 0 and 999". for the second identifier
you provision, we say "give me a random number between 0 and 998". now,
this second time you do *not* use *that* number as the new identifier..

rather, you use that number (N) and say "the Nth open slot is the new
identifier".

in this ASCII visualization, X'es are already occupied integers and
"|"s are open slots:

                  -      -      -      -      -      -      -
                0 |    0 |    0 |    0 |    0 X    0 X    0 X
                1 |    1 |    1 |    1 |    1 |    1 |    1 X
                2 |    2 X    2 X    2 X    2 X    2 X    2 X
                3 |    3 |    3 X    3 X    3 X    3 X    3 X
                4 |    4 |    4 |    4 |    4 |    4 X    4 X
                5 |    5 |    5 |    5 X    5 X    5 X    5 X
                  -      -      -      -      -      -      -

      size of pool:  6     5     4      3      2      1      0 (full)

      randomly gen'd:  2     2     3      0      1      0

      new integer is:    2     3     5      0      4      1

at each step, we get a random number between 0 and N-1 given pool size N.
in effect, walk along every open slot that random number number of times.
whenever you stop, that integer in the space you are "standing on" is the
newly provisioned integer for you.

note:

    - after each step (allocation) the pool is one smaller

    - to generate the random number you have to know the pool size

    - mapping from random number to provisioned identifier is not magic: you
      have to know every occupied slot; i.e the whole existing allocated state.

there's a variety of ways we considered implementing this, with things
like B-trees or custom data structures so that we don't have to traverse
the whole collection of identifiers twice. but MEH:
"""

# == BEGIN GLUE


def NEW_THING(random_number_generator, lmif, listener):

    # convert the identifiers file into a big flat tuple of identifier objects
    # (we may be able to avoid this, but for now we don't care..)

    from . import identifiers_via_index as _
    ALL_iids = tuple(_.identifiers_via_lines_of_index(lmif))

    # depth is squarely in the domain of the vaporous "schema" #[#867.K],
    # but for now we hackishly determine it from the 1st identifier

    if not len(ALL_iids):
        cover_me("it's time to refactor to use schema")

    depth = len(ALL_iids[0].native_digits)

    # get the decoder function from the depth

    from . import identifier_via_string as _
    iid_via_int, int_via_iid, cap = _.three_via_depth__(depth)

    # run the function against the list of things

    _ints = tuple(int_via_iid(iid) for iid in ALL_iids)

    _prov_int = provision_integer(_ints, cap, random_number_generator)

    _prov_IID = iid_via_int(_prov_int)

    return _prov_IID, ALL_iids


# == END GLUE


def provision_integer(provisioned_integers, capacity, random_number_generator):
    """DISCUSSION:

    assume the already provisioned integers each fall within the range
    between ZERO and (capacity minus one) INCLUSIVE.

    there will be other ways that save on compute (maybe), but this way will
    be easiest to code:

      - determine the "pool size" by flattening ALL already provisioned
        integers into one big array.

      - send this pool size into the random number generator. (if the pool
        size is one, the only possible random number generated is zero.)

      - this pseudo-randomly generated number is the "slot offset". to get
        from this to the newly provisioned integer, YOU HAVE TO COUNT the
        open slots from the beginning...

    keep searching for the slot by hopping along "gaps" and adding up how
    many "slots" you've passed over until you go past the "slot offset"
    determimed by the random number generated. once you do, "back up" to
    the exact right slot/integer.
    """

    provisioned_integers_sanitized = __sanitized_provisioned_integers(
            provisioned_integers, capacity)

    count_already_provisioned = len(provisioned_integers_sanitized)

    pool_size = capacity - count_already_provisioned

    slot_offset = random_number_generator(pool_size)

    total_slots_passed_over = 0

    for cursor, w in _gaps_via(provisioned_integers_sanitized, capacity):

        total_slots_passed_over += w

        if slot_offset < total_slots_passed_over:

            _back_up_this_far = total_slots_passed_over - slot_offset
            _end = cursor + w

            result = _end - _back_up_this_far
            break

    return result


def _gaps_via(integers, capacity):
    """a really useful abstraction for our purposes:

    convert (reduce) a stream of integers into a stream of
    *non-zero width gaps* between the integers:

    for "--XX-X" yield ("--", "-")..
    """

    cursor = 0
    for integer in integers:
        distance = integer - cursor
        if 0 < distance:
            yield (cursor, distance)
        cursor = integer + 1

    distance = capacity - cursor
    if 0 < distance:
        yield (cursor, distance)


def __sanitized_provisioned_integers(provisioned_integers, capacity):
    """produce an array of integers from the argument while validating

    so:
      - collapse a collection that's a generator (so we know length)
      - ensure that it came in ordered. (do not order it yourself.)
      - IFF the collecton is non-empty:
          - make sure its lowest (so beginning) integer is not less than zero.
          - make sure its highest (so ending) integer is within the
            boundary implied by `capacity`.
    """

    a = []

    itr = iter(provisioned_integers)
    for i in itr:  # once
        previous_int = i
        a.append(i)
        break

    for i in itr:
        if previous_int >= i:
            cover_me("provisioned integer stream is not in order")
        previous_int = i
        a.append(i)

    if len(a):
        if 0 > a[0]:
            cover_me("lowest integer is too low")

        if capacity <= a[-1]:
            cover_me("highest integer is too high")

    return a


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.
