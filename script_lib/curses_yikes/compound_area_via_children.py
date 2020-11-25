from collections import namedtuple as _nt
import re


def abstract_compound_area_via_children_(cx):
    cx = _children_initially(cx)
    if 0 == len(cx):
        reason = "A compound area must have at least one child"
        raise _my_exception_class()(reason)

    cx, index = _reify_and_index_children(cx.items())
    if 0 == len(index.can_fill_vertically):
        reason = 'Need at least one component that can fill vertically'
        raise _my_exception_class()(reason)  # #here3

    class abstract_compound_area:  # #class-as-namespace
        def hello_I_am_ACA():
            return True

        def concretize_via_available_height_and_width(h, w, listener):
            return _concretize(h, w, index, cx, listener)

    return abstract_compound_area


def _concretize(h, w, index, cx, listener):
    tup = _check_constraints(h, w, index, cx, listener)
    if tup is None:
        return

    extra_available_height, min_height_via_key = tup
    add_these = _distribute_extra_available_height(
            extra_available_height, min_height_via_key, cx, index)

    result = {}
    curr_y = 0

    for k, abstract_area in cx.items():

        starting_h = min_height_via_key[k]
        assert isinstance(starting_h, int)
        final_h = starting_h + add_these.get(k, 0)

        if 0 == final_h:
            xx("fine but cover me")
            result[k] = None  # #here5
            continue
        else:
            concrete_area = abstract_area.\
                concretize_via_available_height_and_width(final_h, w, listener)

        if not concrete_area:
            xx("no problem, but interesting..")

        area_harness = _AreaHarness(curr_y, 0, final_h, w, concrete_area)
        result[k] = area_harness
        curr_y += final_h

    return _ConcreteCompoundArea(result)


class _ConcreteCompoundArea:

    def __init__(self, cx):
        self._children = cx

    def to_rows(self):
        for harness in self._children.values():
            if harness is None:  # #here5
                continue
            formal_w = harness.width
            formal_h = harness.height
            ch = harness.concrete_area

            count = 0
            for string in ch.to_rows():
                if formal_h == count:
                    xx('wat do when component breaks the contract (h)')
                count += 1
                if formal_w != len(string):
                    xx('wat do when component breaks the contract (w)')
                yield string


_AreaHarness = _nt('_AreaHarness', 'y x height width concrete_area'.split())


def _distribute_extra_available_height(
        extra_available_height, min_height_via_key, cx, index):

    # Only those (#here3) one or more components that can stretch vertically
    # get this ZERO or more extra height. Rather than dividing it up
    # evenly, we distribute the extra height proportionally based on the
    # minimum height each component reported having (such that components that
    # were taller to begin with get proportionally more of the extra height).
    # This way, the distorting effect of stretching the whole interface
    # vertically is scaled out to the components in a way that feels ..
    # proportional. Experimental. #[#608.2.B]

    # Group the participating components by their min height for reasons..
    # Munge 0's up to 1's so sections that said they are optional participate
    ks_via_h = {}
    total_minheight = 0
    ks = index.can_fill_vertically
    for k in ks:
        use_h = min_height_via_key[k] or 1
        if (arr := ks_via_h.get(use_h)) is None:
            ks_via_h[use_h] = (arr := [])
        arr.append(k)
        total_minheight += use_h
    low_to_high = sorted(ks_via_h.keys())

    # For each height group, dole-out the same amount to each member (to start)
    pool = extra_available_height  # 21
    add_this_amount = {k: 0 for k in ks}
    for min_h in low_to_high:
        group_ks = ks_via_h[min_h]
        num_members = len(group_ks)
        total_minheight_in_group = min_h * num_members
        numerator = extra_available_height * total_minheight_in_group
        whole, remainder = divmod(numerator, total_minheight)

        # If you didn't get any whole to distribute, skip the group for now
        # (Although the group height numbers only get bigger, we don't quit
        # out of the whole loop yet because we don't know how many members)
        if 0 == whole:
            continue

        add_to_each, remainder2 = divmod(whole, num_members)
        # Same as above
        if 0 == add_to_each:
            continue

        we_are_distributing_this_much = add_to_each * num_members
        pool -= we_are_distributing_this_much
        for k in group_ks:
            add_this_amount[k] += add_to_each

    # Here's the kicker that might make math-strong readers cringe: With
    # whatever extra height is remaining in the pool, we distribute it out in
    # a one-for-you-and-one-for-you manner ONE BY ONE until it's gone. We
    # start with the shortest components first because of the utility value
    # of money. For all we know this loops around the whole traveral again..

    # (Note that for components in the same height group, this always favors
    # the ones higher on the screen. meh. we could invert it, we could
    # randomize it. but big meh.)

    if 0 == pool or 0 == len(low_to_high):
        return add_this_amount  # #here4

    while True:
        for min_h in low_to_high:
            for k in ks_via_h[min_h]:
                add_this_amount[k] += 1
                pool -= 1
                if not pool:
                    return add_this_amount  # #here4


def _check_constraints(h, w, index, cx, listener):

    # If the available width is less that the maximum minimum width, complain
    mmw = index.maximum_minimum_width
    if w < mmw:
        def lines():
            ks = index.maximum_minimum_width_holders
            return _dejumble(_whine_about_width(ks, w, mmw))
        return listener('error', 'expression', 'constraints_not_met', lines)

    # We can't know the minimum heights until we know the available width
    # because (at writing) one formal component does a word wrap thing
    min_height_via_key = {}
    total_minimum_height = 0
    for k, ch in cx.items():
        mh = ch.minimum_height_via_width(w)
        assert isinstance(mh, int)  # use 0 not None here
        min_height_via_key[k] = mh
        total_minimum_height += mh

    # How we handle the height constraint is different than what we do with
    # the width constraint b.c areas are stacked by not side-by-sided #here2
    extra_available_height = h - total_minimum_height
    if extra_available_height < 0:
        def lines():
            ks = tuple(cx.keys())
            return _dejumble(_whine_about_height(ks, h, total_minimum_height))
        return listener('error', 'expression', 'constraints_not_met', lines)

    return extra_available_height, min_height_via_key


def _dejumble(pieces):
    return (' '.join(pieces),)


def _whine_about_width(ks, w, mmw):
    yield f"available width is {w} but at least {mmw} is required by"
    if 1 == len(ks):
        yield ''.join(("'", ks[0], "'"))
    else:
        yield ''.join(('(', ', '.join(ks), ')'))


def _whine_about_height(ks, h, tmh):
    yield f"available height is {h} but"
    yield f"a height of at at least {tmh} is required for"
    if 1 == len(ks):
        yield f"this '{ks[0]}' component"
    else:
        yield f"these {len(ks)} components"


def _reify_and_index_children(cx):
    # Assume only: each key is a unique string and each value is a tuple whose
    # length is at least one. Yield result pairs with the same keys in the same
    # order, and values..

    before = ('before', *locals().keys())

    can_fill_vertically = []

    maximum_minimum_width = 0
    maximum_minimum_width_holders = []

    # NOTE the complexity below & #here1 is b.c we want to preserve the order
    these_local_keys = {k: None for k in locals().keys()}
    tuple(these_local_keys.pop(k) for k in before)  # ick/meh

    reified_children = {}

    for k, tup in cx:
        stack = list(reversed(tup))
        x = stack.pop()
        if isinstance(x, str):
            class_loader = _loader_via_type_string[x]  # ..
            args = tuple(reversed(stack)) if stack else ()
            klass = class_loader()
            abstract_instance = klass(*args)
        else:
            xx("one day, arbitrary loader")

        o = abstract_instance

        cfv = o.can_fill_vertically
        min_w = o.minimum_width
        del o

        # Keep track of maximum minimum width and all responsible components
        if min_w is not None and maximum_minimum_width <= min_w:
            if maximum_minimum_width < min_w:
                maximum_minimum_width = min_w
                maximum_minimum_width_holders.clear()
            maximum_minimum_width_holders.append(k)

        # Track things that want to or can vertically stretch
        if cfv:
            can_fill_vertically.append(k)

        reified_children[k] = abstract_instance

    can_fill_vertically = tuple(can_fill_vertically)
    maximum_minimum_width_holders = tuple(maximum_minimum_width_holders)

    locs = locals()
    index = {k: locs[k] for k in these_local_keys.keys()}  # #here1
    return reified_children, _Index(**index)


_ = ('can_fill_vertically',
     'maximum_minimum_width', 'maximum_minimum_width_holders')


_Index = _nt('_Index', _)


_loader_via_type_string = {
    # we could make this more dynamic, but why
    'horizontal_rule': lambda: _AbstractHorizontalRule,
    'vertical_filler': lambda: _AbstractVerticalFiller,
}


class _AbstractVerticalFiller:

    def __init__(self, *wat):
        if wat:
            xx("wee, args for vertical filler")

    def concretize_via_available_height_and_width(self, h, w, listener):
        assert h  # #here5
        return _ConcreteVerticalFiller(h, w)

    def minimum_height_via_width(_, __):
        return 0

    can_fill_vertically = True
    minimum_width = 1


class _ConcreteVerticalFiller:

    def __init__(self, h, w):
        assert h
        assert w
        self._row = ' ' * 2
        self._range = range(0, h)

    def to_rows(self):
        for _ in self._range:
            yield self._row


class _AbstractHorizontalRule:

    def __init__(self, *wat):
        if wat:
            xx("wee, args for horizontal rule")

    def concretize_via_available_height_and_width(self, h, w, listener):
        assert 1 == h
        return _ConcreteHorizontalRule(w)

    def minimum_height_via_width(_, __):
        return 1

    can_fill_vertically = False
    minimum_width = 1


class _ConcreteHorizontalRule:

    def __init__(self, w):
        glyph = '-'
        assert 1 == len(glyph)
        self._row = glyph * w

    def to_rows(self):
        yield self._row


def _children_initially(cx):
    children = {}
    anon_counts = {}

    for ch in cx:
        if isinstance(ch, tuple):
            k, *rest = ch
        else:
            assert isinstance(ch, str)
            assert re.match(r'[a-z]+(?:_[a-z]+)*\Z', ch)
            count = anon_counts.get(ch, 0)
            count += 1
            anon_counts[ch] = count
            k = '_'.join((ch, str(count)))
            rest = (ch,)
        del ch

        if k in children:
            reason = f"Encountered duplicate child name: {k!r}"
            raise _my_exception_class()(reason)
        children[k] = rest
    return children


def _my_exception_class():
    from script_lib.curses_yikes import MyException_ as klass
    return klass


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
