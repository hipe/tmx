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

      time ->
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

(And having all the supposedly already allocated identifiers in one index
file means we don't actually have to traverse the whole collection to
provision a new identifier.)
"""


# eidr = entity identifer reservation


def reserve_new_entity_identifier_(eid, directory, rng, depth, listener):

    def main():
        lines_tup = read_all_lines_into_memory_because_used_in_patch_later()
        identifiers = iterator_of_identifiers_via_lines_of_file(lines_tup)
        iden_idens = provision_or_otherwise_produce_identifier(identifiers)
        if iden_idens is None:
            return
        iden, idens = iden_idens
        return build_index_file_patch(iden, idens, lines_tup)

    def build_index_file_patch(iden, idens, lines_tup):

        def index_file_new_lines():
            return do_index_file_new_lines(iden, idens)

        return _index_file_patch(
            index_file_new_lines, lines_tup, index_path, iden)

    def do_index_file_new_lines(iden, all_existing_idens):
        from .index_via_identifiers import \
            new_lines_via_add_identifier_into_index_ as func
        return func(iden, all_existing_idens)

    def provision_or_otherwise_produce_identifier(idens):
        if eid:
            return _when_EID_is_passed_explicitly(eid, idens, depth, listener)
        return provision(idens)

    def provision(identifiers):
        return provision_new_identifier_(
            rng, lambda: identifiers, depth, listener)

    def iterator_of_identifiers_via_lines_of_file(lines_tup):
        from .identifiers_via_index import \
            identifiers_via_lines_of_index as func
        return func(lines_tup)

    def read_all_lines_into_memory_because_used_in_patch_later():
        with open(index_path) as lines:
            return tuple(lines)

    index_path = _index_path_for_directory(directory)
    return main()


def _when_EID_is_passed_explicitly(eid, idens, depth, listener):

    # Does the EID parse correctly?
    from .identifier_via_string import func
    iden = func(eid, listener)
    if iden is None:
        return

    # Is it the correct depth?
    if depth != (d := iden.number_of_digits):
        def lines():
            yield f"identifier needs depth {depth} had {d}: {eid!r}"
        listener('error', 'expression', 'depth_mismath', lines)
        return

    # Is it already occupied? #b-tree
    traversed, collided = [], False
    assert hasattr(idens, '__next__')
    for this_iden in idens:
        traversed.append(this_iden)
        if this_iden < iden:
            continue
        if this_iden == iden:
            collided = True
            break
        assert iden < this_iden
        break

    if not collided:
        for this_iden in idens:
            traversed.append(this_iden)
        return iden, tuple(traversed)

    def lines():
        yield f"identifier {eid!r} is already occupied"
    listener('error', 'expression', 'already_occupied', lines)


def REMOVE_IDENTIFIER_FROM_INDEX_(eid, directory, depth, listener):
    # (covered by pho for now)

    from .identifier_via_string import identifier_via_string_
    iden = identifier_via_string_(eid, listener)

    # Read all lines of the index file into memory
    index_path = _index_path_for_directory(directory)
    with open(index_path) as lines:
        orig_lines = tuple(lines)

    from .index_via_identifiers import \
        new_lines_via_delete_identifier_from_index_

    itr = new_lines_via_delete_identifier_from_index_(
            orig_lines, iden, listener)
    if itr is None:
        return

    return _index_file_patch(
            lambda: itr, orig_lines, index_path, iden)


def _index_file_patch(
        to_index_file_new_lines, existing_lines, index_file_path, iden):

    def to_dictionary():
        return {
            # 'identifier_string': iden.to_string(),
            'to_index_file_new_lines': to_index_file_new_lines,
            'index_file_existing_lines': existing_lines,
            'index_file_path': index_file_path}

    class identifier_reservation:  # #class-as-namespace

        def to_dictionary(_):
            return to_dictionary()

        @property
        def identifier_string(_):
            return iden.to_string()

        # index_file_existing_lines = existing_lines
        # index_file_path = index_file_path

    return identifier_reservation()


def _index_path_for_directory(directory):
    from .identifiers_via_index import \
            index_file_path_via_collection_path_ as func
    return func(directory)


def provision_new_identifier_(
        random_number_generator,
        identifierser,
        identifier_depth,
        listener):

    # convert the identifiers file into a big flat tuple of identifier objects
    # (we may be able to avoid this, but for now we don't care..)

    itr = identifierser()
    if itr is None:
        xx()
    ALL_iids = tuple(itr)

    if not len(ALL_iids):
        pass  # #cover-me (tested visually lol)

    # get the decoder function from the depth

    from .identifier_via_string import three_via_depth_ as func
    iid_via_int, int_via_iid, cap = func(identifier_depth)

    # run the function against the list of things

    _ints = tuple(int_via_iid(iid) for iid in ALL_iids)

    _prov_int = provision_integer(_ints, cap, random_number_generator)

    _prov_IID = iid_via_int(_prov_int)

    return _prov_IID, ALL_iids


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
            xx("provisioned integer stream is not in order")
        previous_int = i
        a.append(i)

    if len(a):
        if 0 > a[0]:
            xx("lowest integer is too low")

        if capacity <= a[-1]:
            xx("highest integer is too high")

    return a


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-A.1: "identifier reservation" is born
# #born.
