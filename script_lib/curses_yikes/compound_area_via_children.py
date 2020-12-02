from collections import namedtuple as _nt


def abstract_compound_area_via_children_(cx):
    cx = _children_initially(cx)
    if 0 == len(cx):
        reason = "A compound area must have at least one child"
        raise _my_exception_class()(reason)

    cx, index = _abstract_areas_and_index(cx.items())
    if 0 == len(index.can_fill_vertically):
        reason = 'Need at least one component that can fill vertically'
        raise _my_exception_class()(reason)  # #here3

    class abstract_compound_area:  # #class-as-namespace
        def hello_I_am_ACA():
            return True

        def concretize_via_available_height_and_width(h, w, listener=None):
            if listener is None:
                listener = _throwing_listener
            return _concretize(h, w, index, cx, listener)

        two_pass_run_behavior = 'break'

    return abstract_compound_area


def _concretize(h, w, index, cx, listener):
    def main():
        check_required_dimensions_against_available_dimensions()
        distribute_extra_height_to_vertical_fillers()
        return first_and_second_pass()

    def first_and_second_pass():
        is_in_run, memo, run = False, None, []
        curr_y = 0

        for k, aa in cx.items():  # aa = abstract area

            # Establish the correct order in this result fellow
            harnesses[k] = None

            # Whether or not two-pass, determine comp height and advance curr_y
            comp_h = calculate_component_height(k)
            use_curr_y = curr_y
            curr_y += comp_h

            if 0 == comp_h:
                xx("fine but cover me - zero-height components")  # #here5

            # Do two-pass run stuff
            which = aa.two_pass_run_behavior
            if 'participate' == which:
                if is_in_run:
                    aa.write_to_memo(memo)
                else:
                    is_in_run = True
                    memo = {}
                    aa.write_to_memo(memo)  # or not
                run.append((k, aa, use_curr_y, comp_h))  # #here6
            else:
                assert 'break' == which
                if is_in_run:
                    flush_run(memo, run)
                    memo = None
                    is_in_run = False
                ca = aa.concretize_via_available_height_and_width(
                    comp_h, w, listener)
                add_to_harnesses(k, use_curr_y, comp_h, ca)

        if is_in_run:
            flush_run(memo, run)

        # We need to have one of the components selected from the start for
        # two reasons: 1) what would the up & down arrows mean if nothing was
        # selected to begin with? 2) it's tempting to have the controller do
        # this on init because that's its domain but controller isn't allowed
        # to change state on its own; we have to apply changes explicitly.
        # The hardcoded rule is we must select the topmost one; just because
        topmost_interactable = None
        for h in harnesses.values():
            c = h.concrete_area
            if c.state is None:  # interactability thus
                continue
            topmost_interactable = c
            break
        if topmost_interactable:  # (tests like (Case7650) have no interac.)
            topmost_interactable.state.move_to_state_via_state_name('has_focus')  # noqa: E501

        return _ConcreteCompoundArea(harnesses)

    def flush_run(memo, run):
        for k, aa, curr_y, comp_h in run:  # #here6
            ca = aa.concretize_via_memo_and(memo, comp_h, w, listener)
            add_to_harnesses(k, curr_y, comp_h, ca)
        run.clear()

    def add_to_harnesses(k, curr_y, comp_h, ca):
        if not ca:
            xx("no problem, but interesting..")
        harnesses[k] = _AreaHarness(k, curr_y, 0, comp_h, w, ca)

    def calculate_component_height(k):
        min_h = self.min_height_via_key[k]
        assert isinstance(min_h, int)
        return min_h + self.add_these.get(k, 0)

    def distribute_extra_height_to_vertical_fillers():
        self.add_these = _distribute_extra_available_height(
            self.extra_available_height, self.min_height_via_key, cx, index)

    def check_required_dimensions_against_available_dimensions():
        tup = _check_constraints(h, w, index, cx, listener)
        if tup is None:
            raise stop()
        self.extra_available_height, self.min_height_via_key = tup

    self = main  # #watch-the-world-burn
    harnesses = {}

    class stop(RuntimeError):
        pass

    try:
        return main()
    except stop:
        pass


def input_controller_via_CCA_(cca):  # cca = concrete compound area

    cx = cca._MAKE_THIS_ONE_VIEW()

    from script_lib.curses_yikes.focus_controller_ import \
        vertical_splay_selection_controller_ as func

    selection_controller = func(cx)

    # [#608.2.C] magic name. allow it not to exist probably just for testing
    buttons_area = cx.get('buttons')

    from script_lib.curses_yikes.input_controller_ import \
        BUSINESS_BUTTONPRESS_CONTROLLER_VIA_ as func, \
        InputController__ as func2

    bbc = func(selection_controller, cx)
    return func2(selection_controller, bbc, buttons_area)


class _ConcreteCompoundArea:

    def __init__(self, cx):
        self._children = cx  # harnesses, for now

    def MAKE_A_COPY(self):
        cx = {k: v.MAKE_A_COPY() for k, v in self._children.items()}
        return self.__class__(cx)

    def to_EXPERIMENTAL_input_controller__(self):
        return input_controller_via_CCA_(self)

    def to_rows(self):
        for harness in self._to_component_harnesses():

            if harness is None:  # #here5
                continue

            for row in harness.to_rows():
                yield row

    def __getitem__(self, k):
        return self.HARNESS_AT(k).concrete_area

    def HARNESS_AT(self, k):
        return self._children[k]

    def _to_component_harnesses(self):
        return self._children.values()

    def to_component_keys(self):
        return tuple(self._children.keys())

    def _MAKE_THIS_ONE_VIEW(self):
        # pretend like there exists a dictionary of just comps not harnesses

        class view:
            def items(_):
                return ((k, getitem(k)) for k in harnesses.keys())

            def get(_, k):
                return (ca := harnesses.get(k)) and f(ca)

            def __getitem__(_, k):
                return getitem(k)

        def getitem(k):
            return f(harnesses[k])

        def f(ca):
            return ca.concrete_area

        harnesses = self._children
        return view()

    def hello_I_am_CCA(_):
        return True


class _AreaHarness:

    def __init__(self, k, y, x, height, width, concrete_area):
        self.key = k
        self._y, self._x = y, x
        self._height, self._width = height, width
        self.concrete_area = concrete_area

    def MAKE_A_COPY(self):
        ca = self.concrete_area.MAKE_A_COPY()
        return self.__class__(self.key, self._y, self._x, self._height, self._width, ca)  # noqa: E501

    def to_rows(self):
        for _, _, row in self.TO_SCREEN_ROWS():
            yield row

    def TO_SCREEN_ROWS(self):

        curr_y, always_same_x = (self._y - 1), self._x
        formal_w, formal_h = self._width, self._height

        count = 0
        for row in self.concrete_area.to_rows():

            if formal_h == count:
                xx(f'wat do when component breaks the contract (h): {self.key!r}')  # noqa: E501
            count += 1

            if formal_w != len(row):
                xx(f'wat do when component breaks the contract (w): {self.key!r}')  # noqa: E501

            curr_y += 1

            yield curr_y, always_same_x, row

    @property
    def harness_y__(self):
        return self._y

    @property
    def harness_x__(self):
        return self._x


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


def _abstract_areas_and_index(cx):
    # Assume only: each key is a unique string and each value is a tuple whose
    # length is at least one. Result is a dictionary and an index structure.
    # Dictionary has same keys in the same order, with abstract areas as
    # values. Various characteristics are indexed.
    # Auto buttons require a special pass, which happens here manually

    def main():
        first_pass()
        second_pass()
        return finish()

    def second_pass():
        dct = {k: abstract_areas[k] for k in interactables}
        for k, klass, args in deferred:
            probably_same_k, *rest = args
            abstract_areas[k] = klass(probably_same_k, dct, *rest)

    def first_pass():
        for k, tup in cx:

            # First element of tuple is type because #here1
            mixed_type_ref = (stack := list(reversed(tup))).pop()
            if isinstance(mixed_type_ref, str):
                klass = _AA_classer_via_type_string[mixed_type_ref]()
            else:
                xx("one day, maybe arbitrary loaders")

            args = k, *reversed(stack)

            if klass.defer_until_after_interactables_are_indexed:
                assert not klass.is_interactable
                deferred.append((k, klass, args))
                abstract_areas[k] = None  # maintain order even tho deferred
                continue

            add_to_index(k, klass(*args))

    def add_to_index(k, aa):  # aa = abstract area

        # Keep track of maximum minimum width and all responsible components
        min_w = aa.minimum_width
        if min_w is not None and self.maximum_minimum_width <= min_w:
            if self.maximum_minimum_width < min_w:
                self.maximum_minimum_width = min_w
                maximum_minimum_width_holders.clear()
            maximum_minimum_width_holders.append(k)

        # Track abstract areas that probably have FFSA's [#608.2.B]
        if aa.is_interactable:
            interactables.append(k)

        # Track things that want to or can vertically stretch
        if aa.can_fill_vertically:
            can_fill_vertically.append(k)

        abstract_areas[k] = aa

    def finish():
        kw = {}
        kw['interactables'] = tuple(interactables)
        kw['can_fill_vertically'] = tuple(can_fill_vertically)
        kw['maximum_minimum_width_holders'] = tuple(maximum_minimum_width_holders)  # noqa: E501
        kw['maximum_minimum_width'] = self.maximum_minimum_width
        return abstract_areas, _Index(**kw)

    interactables, can_fill_vertically = [], []
    maximum_minimum_width_holders = []
    self = _OpenStruct()
    self.maximum_minimum_width = 0

    deferred, abstract_areas = [], {}
    return main()


_Index = _nt('_Index', """interactables can_fill_vertically
    maximum_minimum_width maximum_minimum_width_holders""".split())


class _OpenStruct:
    pass


_AA_classer_via_type_string = {
    # we could make this more dynamic, but why. Also change #here7
    'buttons': lambda: _sibling_module('hotkey_via_character_and_label'),
    'checkbox': lambda: _simple('abstract_checkbox_via_directive_tail'),
    'flash_area': lambda: _sibling_module('_flash_area'),
    'horizontal_rule': lambda: _AbstractHorizontalRule,
    'nav_area': lambda: _simple('abstract_nav_area_via_directive_tail'),
    'text_field': lambda: _simple('abstract_text_field_via_directive_tail'),
    'vertical_filler': lambda: _AbstractVerticalFiller,
}


def _sibling_module(mod_name):
    if (x := (dct := _sibling_module.cache).get(mod_name)) is None:
        dct[mod_name] = (x := _load_sibling_module(mod_name))
    return x


_sibling_module.cache = {}


def _load_sibling_module(mod_name):
    use_mod_name = '.'.join(('script_lib.curses_yikes', mod_name))
    from importlib import import_module
    mod = import_module(use_mod_name)
    return mod.KLASS


def _this_buttons_module():
    from .hotkey_via_character_and_label import \
        experimental_deferential_button_AAer_ as klass
    return klass


def _simple(func_name):
    from script_lib.curses_yikes import simple_components as module
    return getattr(module, func_name)


class _AbstractVerticalFiller:

    def __init__(self, k, *wat):
        if wat:
            xx("wee, args for vertical filler")

    def concretize_via_available_height_and_width(self, h, w, listener=None):
        assert h  # #here5
        return _ConcreteVerticalFiller(h, w)

    def minimum_height_via_width(_, __):
        return 0

    two_pass_run_behavior = 'break'
    can_fill_vertically = True
    minimum_width = 1
    is_interactable = False
    defer_until_after_interactables_are_indexed = False


class _ConcreteVerticalFiller:

    def __init__(self, h, w):
        assert h
        assert w
        self._row = ' ' * w
        self._range = range(0, h)
        self.state = None  # #stateless

    def MAKE_A_COPY(self):
        return self

    def to_rows(self):
        for _ in self._range:
            yield self._row


class _AbstractHorizontalRule:

    def __init__(self, k, *wat):
        if wat:
            xx("wee, args for horizontal rule")

    def concretize_via_available_height_and_width(self, h, w, listener=None):
        assert 1 == h
        return _ConcreteHorizontalRule(w)

    def minimum_height_via_width(_, __):
        return 1

    two_pass_run_behavior = 'break'
    can_fill_vertically = False
    minimum_width = 1
    is_interactable = False
    defer_until_after_interactables_are_indexed = False


class _ConcreteHorizontalRule:

    def __init__(self, w):
        glyph = '-'
        assert 1 == len(glyph)
        self._row = glyph * w
        self.state = None  # #stateless

    def MAKE_A_COPY(self):
        return self

    def to_rows(self):
        yield self._row


def _children_initially(cx):
    # We don't know exactly how we want the syntax to work. The simplest thing
    # would be: first term is key, second term is type, and the rest is args.
    # keys must be unique (which we assert). But this leads to defintions that
    # feel overly verbose, requiring weirdness like giving your horizontal
    # rules and vertical fills unique names. So:

    children, anon_counts = {}, {}

    syntactic_experiments = {  # :#here7
        'buttons': 'first_term_is_both_key_and_type',
        'checkbox': 'SQL_ish_syntax',
        'flash_area': 'first_term_is_both_key_and_type',
        'horizontal_rule': 'auto_increment_key',
        'nav_area': 'first_term_is_both_key_and_type',
        'text_field': 'SQL_ish_syntax',
        'vertical_filler': 'auto_increment_key',
    }

    for x in cx:
        if isinstance(x, tuple):
            tup = x
        else:
            assert isinstance(x, str)
            tup = (x,)
        del x
        stack = list(reversed(tup))

        syntax_type = syntactic_experiments.get(stack[-1])

        if 'SQL_ish_syntax' == syntax_type:
            typ = stack.pop()
            k = stack.pop()

        elif 'first_term_is_both_key_and_type' == syntax_type:
            k = stack.pop()
            typ = k

        elif 'auto_increment_key' == syntax_type:
            typ = stack.pop()
            count = anon_counts.get(typ, 0) + 1
            anon_counts[typ] = count
            k = '_'.join((typ, str(count)))

        else:
            k = stack.pop()
            assert isinstance(k, str)
            typ = stack.pop()  # mixed, must be present for now

        if k in children:
            reason = f"Encountered duplicate child name: {k!r}"
            raise _my_exception_class()(reason)

        rest = typ, *reversed(stack)  # #here1 type is first element
        children[k] = rest
    return children


def _throwing_listener(*emi):
    sev, shape, *middle, payloader = emi
    if sev not in ('error', 'fatal'):
        return
    colon_us = [term.replace('_', ' ') for term in (sev, *middle)]
    if ('structure', 'expression').index(shape):
        msg_line = ' '.join(payloader())
    else:
        msg_line = '(structured emission)'
    colon_us.append(msg_line)
    reason = ': '.join(colon_us)
    raise _my_exception_class()(reason)


def _my_exception_class():
    from script_lib.curses_yikes import MyException_ as klass
    return klass


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
