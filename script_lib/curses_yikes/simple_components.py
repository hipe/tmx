def text_field_state_machine():
    yield 'initial', 'cursor_enter', 'has_focus'
    yield 'has_focus', 'cursor_exit', 'initial'
    yield 'has_focus', '[enter] for edit', 'emacs_thing'
    yield 'emacs_thing', 'somehow', 'has_focus'


def checkbox_state_machine():
    yield 'initial', 'cursor_enter', 'has_focus'
    yield 'has_focus', 'cursor_exit', 'initial'
    yield 'has_focus', '[enter] to toggle', 'has_focus', 'call', '_toggle'


def nav_area_state_machine():
    yield 'initial', 'cursor_enter', 'has_focus'
    yield 'has_focus', 'cursor_exit', 'initial'


def _one(_, __):
    return 1


def _lazy_load_FFSA(fsa_def):
    def load_FFSA(_=None):
        return _produce_FFSA(fsa_def)
    return load_FFSA


class abstract_text_field_via_directive_tail:

    def __init__(self, k, *more):
        self._key = k
        kw = {k: None for k in ('label', 'minimum_width')}
        stack = list(reversed(more))
        while stack:
            kw[(k := stack.pop())]  # validate name
            kw[k] = stack.pop()
        self._do_init(**kw)

    def _do_init(self, label, minimum_width):

        self._label = label or _label_via_key(self._key)

        if minimum_width is None:
            # '👉 Foo bar: ____________'  # 12 plus 4
            minimum_width = len(self._label) + 16
        self.minimum_width = minimum_width

    def concretize_via_memo_and(self, memo, h, w, li):
        state = self.FFSAer().to_state_machine()
        return _ConcreteTextField(memo, w, self._label, state)

    def write_to_memo(self, memo):
        _write_widest(memo, 'widest_field_label', len(self._label))

    FFSAer = _lazy_load_FFSA(text_field_state_machine)

    minimum_height_via_width = _one
    two_pass_run_behavior = 'participate'
    can_fill_vertically = False
    is_interactable = True
    defer_until_after_interactables_are_indexed = False


class _ConcreteTextField:

    def __init__(self, memo, w, label, state=None):
        self._memo = memo
        self._width = w
        self._label = label
        self.state = state

    def MAKE_A_COPY(self):
        otr = self.__class__(self._memo, self._width, self._label)
        otr.state = self.state.MAKE_A_COPY()
        return otr

    def to_rows(self):
        yield ('F' * self._width)


class abstract_checkbox_via_directive_tail:

    def __init__(self, k, *more):
        self._key = k
        kw = {k: None for k in ('label', 'minimum_width')}
        stack = list(reversed(more))
        while stack:
            kw[(k := stack.pop())]  # validate name
            kw[k] = stack.pop()
        self._do_init(**kw)

    def _do_init(self, label, minimum_width):

        self._label = label or _label_via_key(self._key)

        if minimum_width is None:
            # '👉 [ ] Foo bar'  # label plus 6
            minimum_width = len(self._label) + 6
        self.minimum_width = minimum_width

    def concretize_via_memo_and(self, memo, h, w, li):
        state = self.FFSAer().to_state_machine()
        return _ConcreteCheckbox(memo, w, self._label, state)

    def write_to_memo(self, memo):
        _write_widest(memo, 'widest_checkbox_label', len(self._label))

    FFSAer = _lazy_load_FFSA(checkbox_state_machine)

    minimum_height_via_width = _one
    two_pass_run_behavior = 'participate'
    can_fill_vertically = False
    is_interactable = True
    defer_until_after_interactables_are_indexed = False


class _ConcreteCheckbox:

    def __init__(self, memo, w, label, state=None):
        self._memo = memo
        self._width = w
        self._label = label

        self._is_checked = False
        self.state = state

    def MAKE_A_COPY(self):
        otr = self.__class__(self._memo, self._width, self._label)
        otr._is_checked = self._is_checked
        otr.state = self.state.MAKE_A_COPY()
        return otr

    def _toggle(self):
        self._is_checked = not self._is_checked

    def to_rows(self):
        yield ('C' * self._width)


class abstract_nav_area_via_directive_tail:

    def __init__(self, k, breadcrumb_keys):
        self._breadcrumb_keys = breadcrumb_keys

    def concretize_via_available_height_and_width(self, h, w, li=None):
        state = self.FFSAer().to_state_machine()
        return _ConcreteNavBar(w, self._breadcrumb_keys, state)

    FFSAer = _lazy_load_FFSA(nav_area_state_machine)

    minimum_height_via_width = _one
    minimum_width = 11  # len("👉 […]foo[…]")
    two_pass_run_behavior = 'break'
    can_fill_vertically = False
    is_interactable = True
    defer_until_after_interactables_are_indexed = False


class _ConcreteNavBar:

    def __init__(self, w, bc_keys, state=None):
        self._breadcrumb_keys = bc_keys
        self._width = w
        self.state = state

    def MAKE_A_COPY(self):
        otr = self.__class__(self._width, self._breadcrumb_keys)
        otr.state = self.state.MAKE_A_COPY()
        return otr

    def to_rows(self):
        # When you can't fit all of a long breadcrumb trail in the available
        # content run of the row, the leftmost part of the content string
        # will get an ellipsis expression like "[…] > foo > bar"

        # Start from the end of the breadcrumb trail (as a stack). Keep popping
        # pieces off of it and adding separators as necesary until your content
        # would exceed the available width.

        max_content_width = self._width - _width_of_selection_stuff
        sep = ' > '
        ellipsis = '[…] > '
        content = _render_breadcrumb_trail(
                max_content_width, self._breadcrumb_keys, ellipsis, sep)
        head = _piece_for_selection(self.state)
        return (''.join((head, content)),)


def _render_breadcrumb_trail(w, slug_keys, ellipsis, sep):
    assert 0 < w

    # Grow from the right: pop the rightmost items first
    def slug_labels():
        stack = list(slug_keys)
        while stack:
            yield _calm_name_via_key(stack.pop())
    label_scn = _scanner_via_iterator(slug_labels())

    # Group your pieces into non-breaking chunks
    def nonbreaking_chunks():
        if label_scn.empty:
            return

        # Rightmost piece will have no separator to the right of it
        yield (label_scn.next(),)

        # Each subsequent piece must have separator, which must be part of it
        while label_scn.more:
            yield sep, label_scn.next()

    # Get as may chunks as you can into a chunkrow
    chunks, ww = _ellipsify_experiment(w, nonbreaking_chunks(), ellipsis)

    # We grew it from the right now is the time to flip it and rev it 2 levels
    chunks = [tuple(reversed(chunk)) for chunk in tuple(reversed(chunks))]

    # Pad the end if necessary
    if (under_by := (w - ww)) > 0:
        chunks.append((' '*under_by,))
    else:
        assert 0 == under_by

    final = ''.join(s for chunk in chunks for s in chunk)
    assert w == len(final)
    return final


def _ellipsify_experiment(w, nonbreaking_chunks, ellipsis):

    def classifed_chunks():
        for chunk in nonbreaking_chunks:
            chunk_w = sum(len(s) for s in chunk)
            yield cchunk_via(chunk, chunk_w)

    from collections import namedtuple as nt
    cchunk_via = nt('CC', ('chunk', 'width'))

    scn = _scanner_via_iterator(classifed_chunks())
    cchunks, ww = [], 0

    # Keep adding more chunks while you can
    while scn.more:
        hypothetical_next_width = ww + scn.peek.width

        # If this additional width would put it over, stop
        if w < hypothetical_next_width:
            break

        cchunks.append(scn.next())
        ww = hypothetical_next_width

        # If this additional width landed right on the money, stop
        if w == ww:
            break

    # If you managed to add all the chunks, you are done and happy
    def result():
        final_w = sum(cchunk.width for cchunk in cchunks)
        final_chunks = [cc.chunk for cc in cchunks]
        return final_chunks, final_w

    if scn.empty:
        return result()

    # Since there were some chunks you couldn't add, you've got to ellipsify
    ellicchunk = cchunk_via((ellipsis,), len(ellipsis))

    # Wouldn't it be nice if it was enough just to add the ellipsis and be done
    while True:

        # If adding the ellipse landed you right on the money or under, done
        hypothetical_next_width = ww + ellicchunk.width
        if hypothetical_next_width <= w:
            cchunks.append(ellicchunk)
            return result()

        # The current raster roster, even though under, is too long once we
        # add the ellipsis. So now we backtrack. Crazy if this loops > once

        # If you had to backtrack so far that we are out of content, nothing.
        # (it's tempting to display an ellipsis, but ours is an infix operator)
        if 0 == len(cchunks):
            return result()  # you get NOTHING

        removing = cchunks.pop()
        ww -= removing.width


# FROM MOVE

def _piece_for_selection(state):
    sn = state.state_name
    if 'initial' == sn:
        return '  '  # _width_of_selection_stuff
    assert 'has_focus' == sn  # yikes, needs some thought. might punt this chek
    return '👉 '


_width_of_selection_stuff = 2


def _calm_name_via_key(k):  # ..
    return k.replace('_', ' ')

# TO MOVE


# ==

def _write_widest(memo, k, leng):
    if k in memo:
        if memo[k] < leng:
            memo[k] = leng
    else:
        memo[k] = leng


def _label_via_key(key):
    s = key.replace('_', ' ')
    return ''.join((s[0].upper(), s[1:]))  # not title()


# == FSA support

def _common_init_state(aa):
    return aa.FFSAer().to_state_machine()


def _produce_FFSA(fsa_def):
    if not hasattr(fsa_def, '_FFSA_'):
        from ._formal_state_machine_collection import \
            build_formal_FSA_via_definition_function_ as func
        fsa_def._FFSA_ = func(__name__, fsa_def)
    return fsa_def._FFSA_


# ==

def _scanner_via_iterator(itr):
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func(itr)


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
