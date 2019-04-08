"""
experimentally, an "index"

  - can be seen from three sides:
  - maybe as a bunch of lines
  - maybe as a hash
  - maybe as a B-tree

the way an index is made: traverse over the *sorted* identifiers,

with each next identifier,

    what is the integer distance between it and the previous identifier?

    take that number,
    take the "number of slots left in the line",
    if that number is greater:
        start a new line
    otherwise:
        place the new item in the line and update the "number of slots left .."

just kidding.

our index is an ordered series of identififiers:

    "ABC", "ABE", "ABF"

arranged as a tree-like structure in a file:

    A
     +-B
       +-C
       +-E
       +-F

but we squash the terminals into one line with its parent
(the list of terminals we call a "rack" in the code):

    A
     +-B (C E F)

also put blank spaces for placeholders for digits not yet used (holes):

    A
     +-B (C   E F)

and also the semantics of "indenting" are *negative* depth:


    (not like this:)
    +-----------------
    |A
    | B (C D)


    (like this:)
    +-----------------
    | A
    |B(C D)


or when deeper. at the unlikely depth of four:

    +--A
    |  +--B
    |  |  +--C
    |  |  |  +--D
    |  |  |  +--E
    |  |  +--F
    |  |     +--G
    |  +--H
    |     +--J
    |        +--K
    +--L
       +--M
          +--N
             +--P


it would be:

    (not like this:)
    +-----------------
    |A
    | B
    |  C (D E)
    | H
    |  J (K)
    |L
    | M
    |  N (P)


    (like this:)
    +-----------------
    |  A
    | B
    |C (D E)
    | H
    |J (K)
    |  L
    | M
    |N (P)


while writing the pseudocode and the head of this asset file, we changed
the format from what's there in in pseudocode to what was just described.

for reference, the original specification imagined lines something like this:

    AXB XCB AXB XCB AXB XCB AXB XCB AXB XCB AXB XCB AXB XCB AXB XCB AXB XCB ..

now that we think about it, this has problems we didn't even consider at the
time; but at the time the man thing that bothered us was all the visual and
spatial redundancy of the more significant digits.

we considered using toml but didn't like the "impurity" of how shardings
would have looked there (really crazy).

for reference:

    .
     A
    B (2 3 4 5 6 7 8 9 A B C D E F G H J K L M N P Q R S T U V W X Y Z)
    C (2 3 4 5 6 7 8 9 A B C D E F G H J K L M N P Q R S T U V W X Y Z)

our current specification is optimized for these design objectives:

    - human readability: reduce visual noise by not repeating the
      the non-tail (more significant) digits.

    - version control austertity: if you push or pop levels of depth in your
      identifier (provisioning more space with a schema change), change to
      the file is minimized because of the mirror-image-ing of indenting.
      (this one is some real OCD fanservice.)

    - whitespace austertity: the "negative indenting" also reduces how wide
      the overall file is, because what are the widest line are always
      flush-left.

    - visually isomorphic for population density: because we line up
      the terminal digits each into their own column, you can see the
      holes visually, which is mostly just a novelty and debugging nicety.
"""


def new_lines_via_delete_identifier_from_index__(
        orig_lines, identifier, listener):

    """(although the index file is written tree-like, we search for
    the item to delete in an inefficient way, because we don't care
    about the efficiency of deletes right now.)

    (this function is in this file because it was light.)
    """

    from . import identifiers_via_index as _
    itr = _.identifiers_via_lines_of_index(orig_lines)
    keep_iids = []
    did_find = False
    count_for_debug = 0

    # find the IID you want to delete (traversal search yikes!)

    for this_iid in itr:
        if identifier == this_iid:  # #here4
            did_find = True
            break
        count_for_debug += 1
        keep_iids.append(this_iid)

    if not did_find:
        cover_me(_say_integrity_error(identifier, count_for_debug))

    # pass-thru any remaining IID's after the one you found

    for this_iid in itr:
        keep_iids.append(this_iid)

    # death if there wasn't at least one :(

    _depth = len(this_iid.native_digits)

    from . import index_via_identifiers as _

    return _.lines_of_index_via_identifiers(keep_iids, _depth)


def new_lines_via_add_identifier_into_index__(identifier, iids, listener):
    # (we could save on compute by making this more tightly coupled with the
    # provisioning mechanism but yuck.)

    def unsorted():
        for iid in iids:
            yield iid
        yield identifier

    _depth = len(identifier.native_digits)  # ..

    return lines_of_index_via_identifiers(sorted(unsorted()), _depth)


def lines_of_index_via_identifiers(identifiers, depth):

    assert(2 < depth)  # really shallow schemas are out of scope for now..

    # --

    offset_of_final_digit = depth - 1
    offset_of_penult_digit = offset_of_final_digit - 1

    head = [None for _ in range(0, offset_of_final_digit)]
    rack = [None for _ in range(0, _num_digits)]

    nd_tup = None

    def context_lines_via_rerack(begin):

        for i in range(begin, offset_of_penult_digit):
            nd = nd_tup[i]
            head[i] = nd
            _margin = ' ' * (offset_of_penult_digit - i)
            _digit_string = nd.character
            yield f'{_margin}{_digit_string}\n'

        # when re-racking, update the "penult" too
        head[offset_of_penult_digit] = nd_tup[offset_of_penult_digit]

    def flush_rack():

        # backtrack from the end so we trim runs of trailing whitespace:

        offset_of_last = _num_digits - 1
        while rack[offset_of_last] is None:
            offset_of_last -= 1

        # when you output a digit, also nullify it in the rack BE CAREFUL:

        def f(i):
            x = rack[i]
            if x is None:
                return ' '
            else:
                rack[i] = None
                return x.character

        # ok go:

        _run = ' '.join(f(i) for i in range(0, offset_of_last + 1))

        _head_char = head[offset_of_penult_digit].character
        return f'{_head_char} ({_run})\n'

    def insert_in_rack():
        nd = nd_tup[offset_of_final_digit]
        rack[nd.integer] = nd

    itr = iter(identifiers)

    # for the first identifier, write context lines while populating `head`

    had_at_least_one = False

    for id_o in itr:  # once

        had_at_least_one = True

        nd_tup = id_o.native_digits

        for line in context_lines_via_rerack(0):
            yield line

        insert_in_rack()
        break

    for id_o in itr:
        nd_tup = id_o.native_digits

        # this identifier goes in the same "rack" IFF its head digits are
        # all the same. so look for any first digit in head that differs.

        found = False
        for i in range(0, offset_of_final_digit):
            if head[i].integer != nd_tup[i].integer:
                found = True
                break

        # re-rack if necessary

        if found:
            yield flush_rack()
            for line in context_lines_via_rerack(i):
                yield line
            insert_in_rack()
        else:
            # otherwise just add this digit to the rack
            insert_in_rack()  # hi.

    if had_at_least_one:
        yield flush_rack()


def _say_integrity_error(identifier, count_for_debug):
    return (
        f'integrity error: did not find {identifier.to_string()}'
        f' in {count_for_debug}')


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_num_digits = 32  # copy paste! from sibling

# #history: received transplant
# #born.
