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
        sep_w = len(sep)
        ellipsis = '[…] > '
        ellipsis_w = len(ellipsis)
        pcs = []
        current_content_width = 0

        stack = list(reversed(self._breadcrumb_keys))

        if stack and current_content_width < max_content_width:
            leng = len(label := _calm_name_via_key(stack[-1]))
            if (current_content_width + leng) <= max_content_width:
                pcs.append(label)
                stack.pop()
                current_content_width += leng
            else:
                stack.clear()  # hack to skip next loop yikes

        while stack and current_content_width < max_content_width:
            leng = len(label := _calm_name_via_key(stack[-1]))
            leng += sep_w
            if max_content_width < current_content_width + leng:
                break
            pcs.append(sep)
            pcs.append(label)
            stack.pop()
            current_content_width += leng

        assert current_content_width <= max_content_width

        if stack and (current_content_width + ellipsis_w) < max_content_width:
            pcs.append(ellipsis)
            current_content_width += ellipsis_w

        width_left_over = max_content_width - current_content_width
        assert 0 <= width_left_over
        pcs.append(_piece_for_selection(self.state))
        pcs = list(reversed(pcs))
        pcs.append(' ' * width_left_over)
        row = ''.join(pcs)
        assert self._width == len(row)  # harness does this but meh
        yield row


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

def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
