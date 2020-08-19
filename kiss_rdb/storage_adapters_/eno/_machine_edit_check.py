# The conceit of this storage adapter around editing is a peculiar one, but
# one that should "feel" familiar to users of markdown.
#
# We want the files to be both "human editable" and "machine editable".
#
# When the human creates and maintains files, they effect some or another
# "style choices" with respect to how whitespace is used (blank lines where
# and why?), what order certain elements appear (when the order isn't otherwise
# significant), and (perhaps most importantly here,) comments.
#
# When the file is edited by machine, we don't want to disrupt any of the
# above style choices (even though, by definition the machine is not supposed
# to be sensitive to any of these aspects (that is, whitespace, comments, and
# those aspects of ordering that are aesthetic but not significant)).
#
# Comments provide a particular challenge: We don't want to machine-edit a
# value that has a comment associated with it, because editing the value is
# as likely as not to render the comment false and possibly harmful.
#
# Imagine:
# | value_added_tax: 3.8%
# | > valid as of 2021
#
# If the above gets machine-edited to become another value, then the comment
# becomes false and spreads misinformation. Someone could get fired!
#
# Our solution to this is simply to say that yes your attributes can have
# comments, but in doing so your forfeit the ability to machine-edit their
# values.
#
# We apply this same principle to entities. Enter "slot theory":
#
# | > I am some comment       |  "slot A"
# | # entity: ABC: attributes |
# | > I am some comment       |  "slot B"
# | foo: bar                  |
# | > I am some comment       |  "slot C"
#
# Commented-ness does not cascade upward: Just because an entity's attribute
# has a comment doesn't not mean the entity has a comment.
#
# In the above example the comments in "slot B" and "slot C" are ambiguously
# associated: are they comments about attributes or the entity? Undefined for
# now. Experimental.
#
# Another whole thing this module helps do is move comment lines from
# "slot C" up to "slot A" ..


def BREAK_OFF_LINES(entb, which, offset, clines):
    keep_these_lines = clines[0:offset]
    these_lines_broken_off = clines[offset:]

    if 'break_attr_clines' == which:
        attrs = entb.attribute_blocks
        attr = attrs[-1].but_with(
          tail_anchored_comment_or_whitespace_lines=keep_these_lines)
        new_entb = entb.but_with(attribute_blocks=(*attrs[0:-1], attr))
    else:
        assert('break_slot_B_clines' == which)
        new_entb = entb.but_with(slot_B_lines=keep_these_lines)

    return new_entb, these_lines_broken_off


def MATCH_DATA(clines):

    assert(len(clines))
    sig = _signature_via_comment_block(clines)
    leng = len(sig)
    if 1 == leng:
        # either it's a solid block of commments or a continuous run of
        # newlines. either way it belongs to the above element
        return
    if 2 == leng:
        # either it's blank lines then comments or comments then blank lines

        # if it's comments then blank lines, it belongs to the thing above
        if 'comment_lines' == sig[0]:
            return

    # now you have (blanks, comments) or at least 3 sig components,
    # one of which must be a run of blanks

    # the "breakpoint" is (somewhat arbitrarily) the line that starts the
    # last run of comment lines.

    here = leng - 1
    if 'blank_lines' == sig[here][0]:
        here -= 1
    assert('comment_lines' == sig[here][0])
    return sig[here][1]


# == Signature stuff

def _signature_via_comment_block(clines):
    _ = ((_category_via_line(clines[i]), i) for i in range(0, len(clines)))
    return tuple(_repeater_reducer_thing(_, lambda two: two[0]))


def _category_via_line(line):
    if '\n' == line:
        return 'blank_lines'
    assert('>' == line[0])  # big flex
    return 'comment_lines'


# == These

def slot_A_(clines, entb):
    return _entity_comments("slot A", clines, entb)


def slot_B_(clines, entb):
    return _entity_comments("slot B", clines, entb)


def _entity_comments(which_slot, clines, entb):
    comm = _first_nonblank(clines)
    eid = entb.entity.identifier.to_string()
    yield (f"Won't delete entity '{eid}' because it has associated comments"
           f' in "{which_slot}".'
           " (We don't know what it says and it could be important!")
    yield f'(the first comment line: {repr(comm)})'


def _first_nonblank(clines):
    return next(x for x in clines if '\n' != x)


# == Stream stuff

def _repeater_reducer_thing(itr, f):
    prev = None
    for x in itr:
        curr = f(x)
        if prev == curr:
            continue
        prev = curr
        yield x

# #history-A.1: lost extensive DSL
# #born
