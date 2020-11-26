def _one(_, __):
    return 1


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
        return _ConcreteTextField(memo, w, self._label)

    def write_to_memo(self, memo):
        _write_widest(memo, 'widest_field_label', len(self._label))

    minimum_height_via_width = _one
    two_pass_run_behavior = 'participate'
    can_fill_vertically = False


class _ConcreteTextField:

    def __init__(self, memo, w, label):
        self._width = w

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
        return _ConcreteCheckbox(memo, w, self._label)

    def write_to_memo(self, memo):
        _write_widest(memo, 'widest_checkbox_label', len(self._label))

    minimum_height_via_width = _one
    two_pass_run_behavior = 'participate'
    can_fill_vertically = False


class _ConcreteCheckbox:

    def __init__(self, memo, w, label):
        self._width = w

    def to_rows(self):
        yield ('C' * self._width)


class abstract_nav_bar_via_directive_tail:

    def __init__(self, k, breadcrumb_keys):
        self._breadcrumb_keys = breadcrumb_keys

    def concretize_via_available_height_and_width(self, h, w, li=None):
        return _ConcreteNavBar(w, self._breadcrumb_keys)

    minimum_height_via_width = _one
    minimum_width = 11  # len("👉 […]foo[…]")
    two_pass_run_behavior = 'break'
    can_fill_vertically = False


def _ConcreteNavBar(w, bc_keys):
    class concrete_nav_bar:
        def to_rows():
            yield ('~' * w)

    return concrete_nav_bar


def _write_widest(memo, k, leng):
    if k in memo:
        if memo[k] < leng:
            memo[k] = leng
    else:
        memo[k] = leng


def _label_via_key(key):
    s = key.replace('_', ' ')
    return ''.join((s[0].upper(), s[1:]))  # not title()


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
