# The conceit of this storage adapter around editing is a peculiar one, but
# one that should "feel" familiar to users of markdown.
#
# We want the files to be both "human editable" and "machine editable".
#
# When the human creates and maintains files, they effect some or another
# "style choices" with respect to how whitespace is used (blank lines where
# and why?), what order certain elements appear (when the order isn't otherwise
# significant), and comments.
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


def thing(orig_f):
    def use_f(run, entb, client_stop):
        repetoire = orig_f(entb, client_stop)
        try:
            run(repetoire)
        except _MyStop:
            pass
    return use_f


@thing
def on_delete_check_above_entity(prev_entb, client_stop):

    class on_delete_check_above_entity:  # #class-as-namespace

        def if_entity_has_entity_above():
            if prev_entb is None:
                raise _my_stop

        def and_if_entity_above_has_a_last_attribute():
            attrb = _last(prev_entb.to_attribute_block_stream())
            if attrb is None:
                raise _my_stop
            _ = tuple(attrb.to_tail_anchored_comment_or_whitespace_lines())
            o.clines = _
            o.signature = _signature_via_comment_block_lines(_)
            o.attrb = attrb

        def if_the_attribute_has_no_extraneous_lines_after_it_this_is_fine():
            if not len(o.signature):
                raise _my_stop

        def if_the_attribute_has_nothing_but_blank_lines_this_is_fine():
            if ('blank_lines',) == o.signature:
                raise _my_stop

        def if_it_finishes_with_blank_lines_its_fine():
            if 'blank_lines' == o.signature[-1]:
                raise _my_stop

        def this_is_not_okay_because_theres_a_touching_comment():
            client_stop(_touching, o.clines, o.attrb)

    class State:
        pass

    o = State()

    return on_delete_check_above_entity


@thing
def on_delete_check_this_entity(entb, client_stop):

    class on_delete_check_this_entity:
        def if_the_entity_has_a_slot_B_comment_this_is_not_okay():
            clines = entb.slot_B_associated_lines
            sig = _signature_via_comment_block_lines(clines)
            if not len(sig):
                return
            if ('blank_lines',) == sig:
                return
            client_stop(_slot_B, clines, entb)

        def if_this_entity_has_a_last_attribute():
            attrb = _last(entb.to_attribute_block_stream())
            if attrb is None:
                raise _my_stop
            o.last_attribute_block = attrb

        def if_has_this_one_kind_of_comment_not_okay():
            # Experimentally, a block of comment lines down here (in slot C)
            # is associated with the entity and not other things IFF it has
            # blank lines above it and below it.
            #
            # This is made easier because we (unofficially?) assume a
            # "# document-meta" section at the tail of every file, which means
            # we can assume that every entity section always has a section that
            # follows it. If it weren't for this, then we would have the
            # daunting task of also checking for "blanks lines, comment lines,
            # <end of file>".
            #
            # Also ..

            attrb = o.last_attribute_block
            clines = tuple(attrb.to_tail_anchored_comment_or_whitespace_lines())  # noqa: E501
            sig = _signature_via_comment_block_lines(clines)
            leng = len(sig)
            if not leng:
                return  # no comments? no problem

            if 1 == leng:
                if ('blank_lines',) == sig:
                    # solid block of blank lines? discard how many blank lines
                    return

                assert (('comment_lines',) == sig)
                # solid block of comments? it's ugly but for now we classify
                # this as belonging to the attrbute and it's okay to del entity
                return

            if 2 == leng:
                if ('comment_lines', 'blank_lines') == sig:
                    # comments then blanks? comments belong to the attribute
                    return

                assert(('blank_lines', 'comment_lines') == sig)
                # blanks then comments? comments belong to next entity
                return _remove_from_head(clines, ('blank_lines',))

            if 3 == leng and 'comment_lines' == sig[0]:
                # "comments, blanks, comments" first comments belong to attr,
                # the second ones belong to the next entity
                assert(('comment_lines', 'blank_lines', 'comment_lines') == sig)  # noqa: E501
                return _remove_from_head(clines, ('comment_lines', 'blank_lines'))  # noqa: E501

            # a signature of length 4 or more (or the case above) is
            # guaranteed to have in it "blanks, comments, blanks" somewhere

            client_stop(_slot_C, clines, entb)

    class State:
        pass

    o = State()

    return on_delete_check_this_entity


# == Ad-hoc medium sized stuff

def _remove_from_head(clines, these):
    work_stack = list(reversed(these))
    line_stack = list(reversed(clines))

    def is_comment_line(line):
        return not is_blank_line(line)

    def is_blank_line(line):
        return '\n' == line

    while len(work_stack):
        which = work_stack.pop()
        if 'comment_lines' == which:
            test = is_comment_line
        else:
            assert('blank_lines' == which)
            test = is_blank_line

        while test(line_stack[-1]):
            line_stack.pop()

    assert(len(line_stack))
    return tuple(reversed(line_stack))


# == Signature stuff

def _signature_via_comment_block_lines(clines):
    _ = (_line_category_via_line(line) for line in clines)
    return tuple(_repeater_reducer_thing(_))


def _line_category_via_line(line):
    if '\n' == line:
        return 'blank_lines'
    assert('>' == line[0])  # big flex
    return 'comment_lines'


# == These

def _slot_C(clines, entb):
    return _entity_comments("slot C", clines, entb)


def _slot_B(clines, entb):
    return _entity_comments("slot B", clines, entb)


def _entity_comments(which_slot, clines, entb):
    comm = _first_nonblank(clines)
    eid = entb.entity.identifier.to_string()
    yield (f"Won't delete entity '{eid}' because it has associated comments"
           f' in "{which_slot}".'
           " (We don't know what it says and it could be important!")
    yield f'(the first comment line: {repr(comm)})'


def _touching(clines, attrb):
    yield ("can't delete an entity because the entity above it's last"
           f" attribute ('{attrb.key}') has a block of comments where"
           " the last comment line touches the entity to be deleted,"
           " and we can't be sure it doesn't say something important"
           " about the entity to delete.")
    yield f'(the first comment line: {repr(clines[0])})'


def _first_nonblank(clines):
    return next(x for x in clines if '\n' != x)


# == Stream stuff

def _repeater_reducer_thing(itr):
    prev = None
    for curr in itr:
        if prev == curr:
            continue
        prev = curr
        yield curr


def _last(itr):
    res = None
    for res in itr:
        pass
    return res


# == Low-level support

class _MyStop(RuntimeError):
    pass


_my_stop = _MyStop()

# #born
