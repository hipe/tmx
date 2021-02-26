"""NOTE all interfaces are VERY subject to change! just a rough proof of con"""


from dataclasses import dataclass


def _words_via_business_items(items, lexicon, datetime_now=None):  # #testpoint

    # Flatten the table early because we're gonna operate from the end
    table = _GenericTable(assert_in_order(items))

    # Break the table into N precision chunks (low precision to high precision)
    oldest, last_3_months, very_recent = table.split_and_map(
        maps_and_boundaries=_maps_and_boundaries(datetime_now), reverse=True)
    precision_chunks = oldest, last_3_months, very_recent
    # (we hard-code the 3 chunks for clarity, just to say hello. but imagine
    #  it's just N chunks. note: everything is chronological left-to-right)

    # The context stack of each frame is just a quantization of the datetime
    # for that event, to some particular level of precision as decided #here2.
    # We intentionally reduce the precision the farther back in time we go
    # (e.g.; events from yesterday are to-the-minute, events from a year ago
    # are to-the-month etc.) so that we can now "chunk by" context stack
    # and all the events will be bucketed into a bucket of a timespan
    # appropriate for what level of detail we want for that event, given how
    # old it is. Whew!

    def these():
        for table in precision_chunks:
            for sub_table in table.chunk_on_attribute('context_stack'):
                yield sub_table

    # Now, each of these tables has events that can be AND'ed together
    return _words_via_timebucket_chunks(these(), lexicon)


def _words_via_timebucket_chunks(tables, lexicon):
    """There is an excellent exercise in orthogonality that happens here:

    Each next table is definitely a "jump" in timebucket (e.g. "March 21"
    then "March 22"). But you may also have:

    - A jump in denomination(s): e.g., "February 28" to "March 1"
      changed day AND month. You might roll over to another year too etc.

    - Also you could have contiguous buckets that change their level of
      precision (detail), like you could jump from "March 19" to
      "March 19, 10:58 AM" (because that's where the boundary of (say) the
      last 48 hours falls, is probably in the middle of some day).

    The extent to which these meta-changes are interesting is an open
    question we explore now. What we know for sure is:

    - We want to express _or imply_ *every* component of the context stack
      that is the rubric of each table. (They are chunked by same context
      stack. We have already pruned components-of-too-much-precision way
      earlier in the pipeline; all these components are considered "relevant".)

    - Towards avoiding superfluity, we want to trend away from re-introducing
      context values that have already been expressed. The context stacks
      we have are trimmed to desired precision, but they don't "know" what
      stacks are behind them so they don't know to avoid superfluity (yet).
      (So, when jumping from "March 5" to "March 20", we don't need to
      re-introduce "March".)

    - However, avoiding superfluity needs to be anchored to the root of the
      context stack: if you jump from "March 2020" to "March 2021" it's not
      the same March; and this needs to be clear in the expression.

    We refer to this as "orthogonality" to mean that certain of these kinds
    of jumps in buckets don't "care about" _why_ the bucket changed: If you
    jump from the "March 20" bucket to the "March 20, 10:15pm" bucket, the
    concern that wants _not_ to re-introduce "March 20" is distinct from the
    concern that brought us the change in buckets. So the concern we're coding
    for here needn't care _why_ the bucket changed, the change in buckets won't
    effect how we make our decisions about avoiding superfluity.
    """

    itr = iter(tables)
    first_table = next(itr)  # ..

    prev_context_stack = first_table[0].context_stack

    for w in _words_via_timebucket(prev_context_stack, first_table, lexicon):
        yield w

    for table in itr:
        this_context_stack = table[0].context_stack
        USE_context_stack = _TRIM_CONTEXT_STACK_FROM_HEAD(
                this_context_stack, prev_context_stack)
        prev_context_stack = this_context_stack
        for w in _words_via_timebucket(USE_context_stack, table, lexicon):
            yield w


def _words_via_timebucket(relevant_context, table, lexicon):
    these_keys = tuple(frame.verb_lexeme_key for frame in table)
    counts = _crunch_into_counts(these_keys)
    return lexicon.words_via_frame_ish(relevant_context, counts)


def _crunch_into_counts(verb_lexeme_keys):
    result = {}  # rely on order
    for key in verb_lexeme_keys:
        current = result.get(key)
        if current is None:
            result[key] = 1
        else:
            result[key] = current + 1
    return tuple(result.items())


def _TRIM_CONTEXT_STACK_FROM_HEAD(this_context_stack, context_context_stack):
    leng_this_context_stack = len(this_context_stack)
    shortest = min(leng_this_context_stack, len(context_context_stack))
    assert shortest  # neither context stack should be zero in length:167

    furthest_right_offset_that_was_same = None
    for i in range(0, shortest):
        this_key, this_value = this_context_stack[i]
        context_key, context_value = context_context_stack[i]

        assert this_key == context_key
        # (context stacks must always be head-anchored to the same
        # "coordinate system" lol)

        # If they are the same value (e.g. "March"), keep extending the "how f"
        if context_value == this_value:
            furthest_right_offset_that_was_same = i
            continue

        # They are not the same. We have found the start of new information.
        break

    # If nothing was the same between the two stacks (then year change prob.)
    if furthest_right_offset_that_was_same is None:
        return this_context_stack

    # It should never be the case that the two context stacks were totally
    # the same (at the moment I don't know where to cite to "prove" this),
    # so there should always be some new-information tail of the "this".
    last_offset_of_this = leng_this_context_stack - 1
    first_interesting_offset_in_this = furthest_right_offset_that_was_same + 1

    assert first_interesting_offset_in_this <= last_offset_of_this

    return this_context_stack[first_interesting_offset_in_this:]  # AWESOME


"""Our over-arching theory of expression might be of as constant engineering-
type trade-off of the two "core vectors" of "concision" versus "relevance".

NO there's narrative coherence, fill the space EDIT

Superfluity is a violation of concision and probably relevance: When something
is "superfluous", it takes up space that is not justified by how relevant it
is (or is not).

If (with no other conversational context) I say "January 21", you probably
assume it refers to the most recent such day (or maybe you will assume
it is the next such day that will occur in the future); in any case, the
general thing is that what is assumed is "proximity to now".

Notwithstanding, because this site is generated statically and not at
"read time", we want the productions to still be "true" whether it's written
today or at some unimaginably far date in the future, like two years from now.

"""


def _maps_and_boundaries(dt_now):
    o = _maps_and_boundaries
    if o.x is None:
        o.x = tuple(_do_maps_and_boundaries(dt_now))
    return o.x


_maps_and_boundaries.x = None


def _do_maps_and_boundaries(now):
    # Break the table up into N tables by finding the following boundaries
    # (and also, map the items thru the provided corresponding maps) #here2

    # Those from the last 2 days, show to-the-minute precision

    yield 'map', _map_via(_minute_precision)

    def test(bi):
        # Towards finding the first event "more than 2 days ago"
        difference = now - bi.datetime
        return number_of_seconds_in_two_days < difference.total_seconds()

    number_of_seconds_in_two_days = 48 * 60 * 60

    yield 'test', test

    # Then, those from the last 90 days, show to-the-day precision

    yield 'map', _map_via(_day_precision)

    def test(bi):
        difference = now - bi.datetime
        return 90 < difference.days  # if off-by-one meh

    yield 'test', test

    # Then, for the last group, show to-the-month precision

    yield 'map', _map_via(_month_precision)

    if now:
        return
    from datetime import datetime
    now = datetime.now()


def _map_via(context_components_via_datetime):
    def func(bi):
        cstack = list(context_components_via_datetime(bi.datetime))
        return _Frame(bi.verb_lexeme_key, cstack, bi)  # #here1
    return func


def _minute_precision(dt):
    for k, v in _day_precision(dt):
        yield k, v
    yield 'hour', dt.hour
    yield 'minute', dt.minute


def _day_precision(dt):
    for k, v in _month_precision(dt):
        yield k, v
    yield 'day', dt.day


def _month_precision(dt):
    yield 'year', dt.year
    yield 'month', dt.month


def assert_in_order(items):
    itr = iter(items)
    bi = next(itr)  # ..
    yield bi
    prev = bi.datetime

    for bi in itr:
        curr = bi.datetime
        if curr <= prev:
            xx(f"business items are out of order: had {prev} then {curr}")
        yield bi
        prev = curr


class _GenericTable(tuple):
    # Subclassing tuple just to make dumps prettier. very experimental

    def split_and_map(self, maps_and_boundaries, reverse=False):
        return _split_and_map(maps_and_boundaries, reverse, self)

    def chunk_on_attribute(self, attr):
        return _chunk_on_attribute(attr, self)


# == Split and map

def _split_and_map(maps_and_boundaries, reverse, table):
    result_tables = [[]]

    maps, tests = _prepare_maps_and_tests(maps_and_boundaries)

    if reverse:
        map_stack = list(reversed(maps))
    else:
        xx('not covered, not sure')
        map_stack = list(maps)

    for direc in _split_and_map_main(tests, reverse, table):
        typ = direc[0]
        if 'boundary' == typ:
            result_tables.append([])
            map_stack.pop()
            continue
        assert 'item' == typ
        item, = direc[1:]
        result_tables[-1].append(map_stack[-1](item))

    cls = table.__class__

    if reverse:
        actual_class = cls
        def cls(row): return actual_class(reversed(row))
        result_tables = reversed(result_tables)

    return (cls(rows) for rows in result_tables)


def _split_and_map_main(tests, reverse, table):
    if reverse:
        generic_items = reversed(table)
    else:
        xx("Not implemented. We've only ever wanted this in reverse")

    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    scn = func(generic_items)

    test_stack = list(reversed(tests))
    test = test_stack.pop()

    while scn.more:
        if test(scn.peek):
            test = None
            yield ('boundary',)
            # (before you can yield out the item, you've got to
            # see if it also passes any next test too etc)
            if 0 == len(test_stack):
                break
            test = test_stack.pop()
            continue
        yield 'item', scn.next()

    # (the only way you get out of the above loop is if EITHER no more
    #  unsatisfied tests OR no more items)

    num_unsatisfied_tests = (1 if test else 0) + len(test_stack)
    # (or do test_stack[-1](..))

    if scn.empty:
        assert num_unsatisfied_tests
        for _ in range(0, num_unsatisfied_tests):
            yield ('boundary',)
        return

    assert scn.more
    while scn.more:
        yield 'item', scn.next()


def _prepare_maps_and_tests(maps_and_boundaries):
    maps, tests = [], []

    expecting_map = True
    for k, v in maps_and_boundaries:
        if expecting_map:
            if 'map' != k:
                xx(f"expecting 'map', had: {k!r}")
            maps.append(v)
            expecting_map = False
            continue
        if 'test' != k:
            xx(f"expecting 'test', had: {k!r}")
        tests.append(v)
        expecting_map = True

    if not (len(maps) == len(tests) + 1):
        xx("need the format: MAP TEST [MAP TEST [..]]")

    return maps, tests


# == Chunk on attribute

def _chunk_on_attribute(attr, table):
    """like "group-by" of SQL fame but same-group things must be contigiuous"""

    if not len(table):
        return table

    itr = iter(table)
    first_frame = next(itr)

    cache = [first_frame]
    comparable_of_this_group = getattr(first_frame, attr)

    table_class = table.__class__
    for frame in itr:
        current_comparable = getattr(frame, attr)
        if comparable_of_this_group == current_comparable:
            cache.append(frame)
            continue

        yield table_class(cache)
        cache.clear()

        comparable_of_this_group = current_comparable
        cache.append(frame)

    if len(cache):
        yield table_class(cache)


# ==

@dataclass
class _Frame:
    verb_lexeme_key: str
    context_stack: list
    business_item: object


@dataclass
class _BusinessItem:
    verb_lexeme_key: str
    datetime: object


# == (imagine in [place 1] or [place 2])

def _words_of_oxford_join(slug_words_es, sep):  # #testpoint
    rows = _do_words_of_oxford_join(slug_words_es, sep)
    return (w for row in rows for w in row)


def _do_words_of_oxford_join(slug_words_es, sep):
    stack = list(slug_words_es)
    if 0 == len(stack):
        return (('(nothing)',),)
    last = stack.pop()
    if 0 == len(stack):
        return (last,)
    penult = stack.pop()
    return _do_do_words_of_oxford_join(stack, penult, last, sep)


def _do_do_words_of_oxford_join(stack, penult, last, sep):
    for item_words in stack:
        mutable = list(item_words)
        mutable[-1] = ''.join((mutable[-1], ','))
        yield mutable
    yield penult
    yield (sep,)
    yield last


def xx(msg=None):
    raise RuntimeError(''.join(('not covered', *((': ', msg) if msg else ()))))

# #born
