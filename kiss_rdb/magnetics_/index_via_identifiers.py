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
    if that number is zero:
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
    |B (C D)


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
time; but at the time the main thing that bothered us was all the visual and
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


def CLI_(sin, sout, serr, argv):
    """
    description: output to STDOUT the should-be lines of an index file

    Quick and dirty aid in re-generating index files FOR NOW..

    at #history-A-1 this works for our 32x32x32 collection but it borks
    with an assertion failure for our 32^2 collection perhaps because single
    file schemas have no index..
    """

    usage = "usage: {{prog_name}} generate [-i] [--preview] COLLECTION_PATH\n"  # [#857.13] [#608.20]
    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
            sin, sout, serr, argv,
            usage_lines=(usage,),
            docstring_for_help_description=CLI_.__doc__)

    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc

    assert ('generate',) == pt.subcommands
    dct = pt.values
    coll_path = dct.pop('collection_path')
    do_preview = dct.pop('preview', None)
    do_edit_in_place = dct.pop('-i', None)
    assert not dct

    def check_mutex():  # also called by client at #history-B.4

        if do_edit_in_place:
            if do_preview:
                w("'-i' and '--preview' are mutually exclusive\n")
                return xx()

        elif not do_preview:
            w("Must have one of '-i' or '--preview'\n")
            return 128

    def main():
        listener = build_listener()

        # coll_path = self.os_path.abspath(coll_path)

        # resolve collection
        from kiss_rdb import collectionerer
        coll = collectionerer().collection_via_path(coll_path, listener)
        if coll is None:
            return 123

        def produce_opened():
            if do_edit_in_place:
                # Open the file as 'r+' (not 'w') to ensure it exists first
                return wpath, open(wpath, 'r+')  # #here1

            assert do_preview
            from contextlib import nullcontext as func
            return f"«stdout» (not {wpath})", func(sout)

        from kiss_rdb.magnetics_.identifiers_via_index import \
            index_file_path_via_collection_path_ as func
        wpath = func(coll_path)

        depth = coll.custom_functions.number_of_digits_

        with coll.open_identifier_traversal(listener) as idens:
            lines = _lines_of_index_via_identifiers(idens, depth, listener)
            desc_and_fh = produce_opened()
            if desc_and_fh is None:
                return 124
            desc, wopened = desc_and_fh

            bytes_tot = 0
            with wopened as out_filehandle:
                write = out_filehandle.write
                for line in lines:
                    bytes_tot += write(line)

                # (if the new file size is smaller than previous. ok on stdout)
                # (WAS ok on stdout before #history-C.1)
                if not out_filehandle.isatty():
                    out_filehandle.truncate()  # #here1


        serr.write(f"(wrote {bytes_tot} bytes to {desc})\n")
        return 0

    def build_listener():
        # build a "error case expressor" (listener) that is similar in spirit
        # to our real CLI but worse in several observed ways. We don't want to
        # depend on the CLI because that defeats the purpose of a quarantined
        # one-off, but #trak #[#008.11] is to abstract it to be more accessible

        def listener(*args):
            write = serr.write
            mood, shape, typ, *rest, payloader = args
            if 'expression' == shape:
                for line in payloader():
                    write(f'{line}\n')
            assert 'structure' == shape
            dct = payloader()
            chan_tail = (typ, *rest)
            from script_lib.magnetics.expression_via_structured_emission \
                import func
            itr = func(chan_tail, dct)
            for line in itr:
                write(line)
                if '\n' != line[-1]:
                    write('\n')
        return listener
    return main()

# ==

def new_lines_via_delete_identifier_from_index_(orig_lines, iden, listener):
    """(although the index file is written tree-like, we search for
    the item to delete in an inefficient way, because we don't care
    about the efficiency of deletes right now.)

    (this function is in this file because it was light.)
    """

    from .identifiers_via_index import identifiers_via_lines_of_index

    # Put all the identifiers into memory :(
    idens = tuple(identifiers_via_lines_of_index(orig_lines))

    # Find the offset of the target identifier
    offset = -1
    did_find = False
    for curr_iden in idens:
        offset += 1
        if curr_iden < iden:
            continue

        if curr_iden == iden:  # #here4
            did_find = True
            break

        assert(iden < curr_iden)
        break

    if not did_find:
        msg = _say_entity_not_found(iden.to_string(), len(idens))
        listener('error', 'expression', 'entity_not_found', lambda: (msg,))
        return

    # Read all the would-be lines of the new index file in to memory
    new_idens = (*idens[0:offset], *idens[offset+1:])

    # Put the new list of identifiers in to memory
    depth = iden.number_of_digits
    return _lines_of_index_via_identifiers(new_idens, depth, listener)


def new_lines_via_add_identifier_into_index_(identifier, iids):
    # (we could save on compute by making this more tightly coupled with the
    # provisioning mechanism but yuck.)

    def unsorted():
        for iid in iids:
            yield iid
        yield identifier

    _depth = identifier.number_of_digits

    return _lines_of_index_via_identifiers(sorted(unsorted()), _depth, None)


def _lines_of_index_via_identifiers(identifiers, depth, listener):  # noqa: E501 #testpoint

    if 2 < depth:
        return __lines_of_index_via_identifiers_when_deeper(identifiers, depth)
    elif 2 == depth:
        return __lines_of_index_via_identifiers_when_shallo(identifiers, depth)
    else:
        xx("no - we don't make indexes for numberspaces this small")


def __lines_of_index_via_identifiers_when_deeper(identifiers, depth):

    assert(2 < depth)

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

    def produce_head_character():
        return head[offset_of_penult_digit].character

    flush_rack = _build_rack_flusher(rack, produce_head_character)

    def insert_in_rack():
        nd = nd_tup[offset_of_final_digit]
        rack[nd.integer] = nd

    itr = iter(identifiers)

    # for the first identifier, write context lines while populating `head`

    had_at_least_one = False

    for id_o in itr:  # #once

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


def __lines_of_index_via_identifiers_when_shallo(identifiers, depth):

    # we want this to be much easier because we never indent
    # NOTE abtract something from above maybe

    assert(2 == depth)

    itr = iter(identifiers)

    rack = [None for _ in range(0, _num_digits)]

    # == define funcs

    def produce_head_character():
        return rubric_nd.character

    flush_rack = _build_rack_flusher(rack, produce_head_character)

    # == run

    had_at_least_one_identifier = False

    for iid in itr:  # #once

        had_at_least_one_identifier = True

        rubric_nd, tail_nd = iid.native_digits  # assert identifier depth

        # the first identifier in the list determines the first rubric
        rubric_int = rubric_nd.integer

        # store this guy
        rack[tail_nd.integer] = tail_nd

        break

    for iid in itr:

        curr_rubric_nd, tail_nd = iid.native_digits  # assert ID depth

        curr_rubric_int = curr_rubric_nd.integer

        if rubric_int < curr_rubric_int:

            yield flush_rack()

            # update rubric to reflect new .. rubric
            rubric_nd = curr_rubric_nd
            rubric_int = curr_rubric_int
            rack[tail_nd.integer] = tail_nd
        elif rubric_int == curr_rubric_int:
            rack[tail_nd.integer] = tail_nd
        else:
            xx('out of order (not all out of orders are detected!)')

    if had_at_least_one_identifier:
        yield flush_rack()


def _build_rack_flusher(rack, produce_head_character):

    rightmost_offset = _num_digits - 1

    def flush_rack():

        # backtrack from the end so we trim runs of trailing whitespace:

        offset_of_last = rightmost_offset
        while rack[offset_of_last] is None:
            offset_of_last -= 1

        # when you output a digit, also nullify it in the rack BE CAREFUL:

        def char_at(i):
            nd = rack[i]
            if nd is None:
                return ' '
            else:
                rack[i] = None
                return nd.character

        # ok go:

        _run = ' '.join(char_at(i) for i in range(0, offset_of_last + 1))

        _head_char = produce_head_character()

        return f'{_head_char} ({_run})\n'

    return flush_rack


# == whiners & related

def _say_entity_not_found(eid, idens_count):
    return f"entity '{eid}' not found (in {idens_count}) entities)"


# ==

def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_num_digits = 32  # copy paste! from sibling


if __name__ == '__main__':
    from sys import stdin, stdout, stderr, argv
    exit(CLI_(stdin, stdout, stderr, argv))


# #history-C.1 as was referenced
# #history-B.4 mounted by legacy CLI
# #history-A-1: add CLI
# #history: received transplant
# #born.
