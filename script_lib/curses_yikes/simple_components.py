from script_lib.curses_yikes import \
        StateMachineBasedInteractableComponent_ as _StateBasedInteractable, \
        piece_via_has_focus_ as _piece_via_has_focus, \
        button_pages_via_FFSA_ as _button_pages_via_FFSA, \
        label_via_key_ as _label_via_key, \
        calm_name_via_key_ as _calm_name_via_key, \
        MultiPurposeResponse_ as _response, \
        WriteOnceMutableStruct_ as _MutableStruct


def text_field_state_machine():
    yield 'initial', 'cursor_enter', 'has_focus'
    yield 'has_focus', 'cursor_exit', 'initial'
    yield 'has_focus', '[enter] for edit', 'emacs_thing', 'call', '_enter_modal'  # noqa: E501
    yield 'emacs_thing', 'done_with_emacs_thing', 'has_focus'


def checkbox_state_machine():
    yield 'initial', 'cursor_enter', 'has_focus'
    yield 'has_focus', 'cursor_exit', 'initial'
    yield 'has_focus', '[enter] to toggle', 'has_focus', 'call', '_toggle'


def nav_area_state_machine():
    yield 'initial', 'cursor_enter', 'has_focus'
    yield 'has_focus', 'cursor_exit', 'initial'


def _one(_, __):
    return 1


def _build_to_button_pages_function(ffsa_defnf):
    def to_button_pages(_):
        return _button_pages_via_FFSA(_produce_FFSA(ffsa_defnf))
    return to_button_pages


# == Text Field

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
        state = _produce_FFSA(text_field_state_machine).to_state_machine()
        return _ConcreteTextField(self._key, state, memo, w, self._label)

    def write_to_memo(self, memo):
        _write_widest(memo, 'widest_text_field_label_width', len(self._label))

    to_button_pages = _build_to_button_pages_function(text_field_state_machine)
    component_type_key = __name__, '__text_field__'  # no see, just be unique
    minimum_height_via_width = _one
    two_pass_run_behavior = 'participate'
    can_fill_vertically = False
    is_interactable = True
    defer_until_after_interactables_are_indexed = False


class _ConcreteTextField(_StateBasedInteractable):

    def __init__(self, *five):
        if len(five):
            self._init_normally(*five)

    def _init_normally(self, k, state, memo, w, label):
        self._key = k
        self._state = state
        wlw = memo['widest_text_field_label_width']
        self._render = _bake_text_field_renderer(label, wlw, w)
        self._value_string = None  # will probably become an arg

    def MAKE_A_COPY(self):
        otr = self.__class__()
        otr._key = self._key
        otr._state = self._state.MAKE_A_COPY()
        otr._render = self._render
        otr._value_string = self._value_string
        return otr

    # == BEGIN oh boy

    def _enter_modal(self):
        changes = (('host_directive', 'enter_text_field_modal', self._key),)
        return _response(changes=changes)

    @property
    def value_span_x_and_width_for_modal_(self):
        return self._render._SPAN_X, self._render._SPAN_W

    def receive_new_value_from_modal_(self, mixed):
        if mixed is None:
            pass  # it means they cancelled out. keep old value
        else:
            self._value_string = mixed  # no validation for now lol
        self._state.move_to_state_via_transition_name('done_with_emacs_thing')

        # (probably not nec to tell the host we changed b.c it redraws anyway)
        return _response(changed_visually=(self._key,))

    # == END

    def to_rows(self):
        left_piece = _piece_via_has_focus(self._has_focus)
        return (self._render(left_piece, self._value_string),)


def _bake_text_field_renderer(label, widest_label_width, full_width):
    # To render a text field row, we need to know two numbers: the width of the
    # widest label, and the width of the whole thing (concrete compound area).
    # All the other pieces are hard-coded fixed widths, except the value span,
    # whose width is a function of these two variables and the constants.

    def render(left_pc, value_string):

        # Start by copying the values (and holes) in the prototype dictionary
        dct = {k: v for k, v in proto_d.items()}
        o = _MutableStruct(dct)

        # The left piece is fixed-width but variable value (focused-ness)
        o['left'] = left_pc

        # The value span is..
        if value_string is None:
            value_string = ''
        else:
            assert isinstance(value_string, str)  # #[#022]
        under_by = value_span_w - len(value_string)
        if under_by < 0:
            xx(f"Stop these too-wides from coming in ever ({value_string!r}")
        assert '\n' not in value_string
        o['value'] = value_span_format.format(value_string)

        o.done()
        final = ''.join(dct.values())
        assert full_width == len(final)
        return final

    # Start with a dict with all holes (this establishes constituency & order)
    proto_d = {k: None for k in ('left', 'label', 'colon', 'value', 'right')}
    o = _MutableStruct(proto_d)

    # Bake the full label span now, which is just a function of the widest labl
    under_by = widest_label_width - len(label)
    assert 0 <= under_by
    left_padding = ' ' * under_by
    o['label'] = ''.join((left_padding, label))

    # Add these two static strings now, used in the calculation next
    o['colon'] = ': ['
    o['right'] = ']'

    # We can render the value span the above way, but let's use a fmt str jst b
    # (yes this calculation happens redundantly for every field in the run..)
    width_so_far = sum(len(x) for x in proto_d.values() if x)
    value_span_w = full_width - (_sel_w + width_so_far)
    assert 9 < value_span_w  # we said 12 above, but now we have '[   ]'
    value_span_format = f'{{:<{value_span_w}}}'  # align left

    # == BEGIN experimental hackish flex: the host (not we) will render an
    #    editable text area. It will ask us what is the X and W of the span.
    #    (originally wrote `render` to be 💯 encapsulated. now, de-encapsul.)
    render._SPAN_X = _sel_w + len(proto_d['label']) + len(proto_d['colon'])
    render._SPAN_W = value_span_w
    # == END

    return render


# == Checkbox

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

        # Calculate the necessary width implied by the label
        # (use the same formula as #here1..)
        calcd_min_width = _sel_w + _checkbox_w + 1 + len(self._label)

        # For whatever reason we allow you to set the minwidth but we check you
        self.minimum_width = max((calcd_min_width, (minimum_width or 0)))

    def concretize_via_memo_and(self, memo, h, w, li):
        state = _produce_FFSA(checkbox_state_machine).to_state_machine()
        return _ConcreteCheckbox(self._key, state, memo, w, self._label)

    def write_to_memo(self, memo):
        _write_widest(memo, 'widest_checkbox_label_width', len(self._label))

    to_button_pages = _build_to_button_pages_function(checkbox_state_machine)
    component_type_key = __name__, '__checkbox__'  # no see, just be unique
    minimum_height_via_width = _one
    two_pass_run_behavior = 'participate'
    can_fill_vertically = False
    is_interactable = True
    defer_until_after_interactables_are_indexed = False


class _ConcreteCheckbox(_StateBasedInteractable):

    def __init__(self, *five):
        if len(five):
            self._init_normally(*five)

    def _init_normally(self, k, state, memo, w, label):
        self._key = k
        self._state = state
        self._width = w
        wlw = memo['widest_checkbox_label_width']
        self._render = _bake_checkbox_renderer(label, wlw, w)
        self._is_checked = False

    def MAKE_A_COPY(self):
        otr = self.__class__()
        otr._key = self._key
        otr._state = self._state.MAKE_A_COPY()
        otr._width = self._width
        otr._render = self._render
        otr._is_checked = self._is_checked
        return otr

    def _toggle(self):
        self._is_checked = not self._is_checked
        return _response(changed_visually=(self._key,))

    def to_rows(self):
        left_piece = _piece_via_has_focus(self._has_focus)
        final = self._render(left_piece, self._is_checked)
        assert self._width == len(final)  # idk, magic
        return (final,)


def _bake_checkbox_renderer(label, widest_label_width, full_width):

    def render(left, is_checked):
        dct = {k: v for k, v in proto_d.items()}
        o = _MutableStruct(dct)
        o['left'] = left

        # Use whatever glyphs you want for the box itself but `_checkbox_w` 👀
        o['box'] = '[X]' if is_checked else '[ ]'

        o.done()
        final = ''.join(dct.values())
        assert full_width == len(final)
        return final

    # Establish the constituency and order of this mini-template
    proto_d = {k: None for k in ('left', 'filler', 'box', 'label_and_rest')}

    # Yes, filler is same for all checkboxes in a run. calc'd redundantly
    filler_w = full_width - _sel_w - _checkbox_w \
        - 1 - widest_label_width  # (use same formula as #here1)

    assert 0 <= filler_w
    proto_d['filler'] = ' ' * filler_w
    proto_d['label_and_rest'] = f' {{:<{widest_label_width}}}'.format(label)

    return render


_checkbox_w = 3


# == Nav Area

class abstract_nav_area_via_directive_tail:

    def __init__(self, k, breadcrumb_keys):
        self._breadcrumb_keys = breadcrumb_keys

    def concretize_via_available_height_and_width(self, h, w, li=None):
        state = _produce_FFSA(nav_area_state_machine).to_state_machine()
        return _ConcreteNavBar(w, self._breadcrumb_keys, state)

    to_button_pages = _build_to_button_pages_function(nav_area_state_machine)
    component_type_key = __name__, '__nav_area__'  # no see, just be unique
    minimum_height_via_width = _one
    minimum_width = 11  # len("👉 […]foo[…]")
    two_pass_run_behavior = 'break'
    can_fill_vertically = False
    is_interactable = True
    defer_until_after_interactables_are_indexed = False


class _ConcreteNavBar(_StateBasedInteractable):

    def __init__(self, w, bc_keys, state):
        self._breadcrumb_keys = bc_keys
        self._width = w
        self._state = state

    def MAKE_A_COPY(self):
        otr_state = self._state.MAKE_A_COPY()
        otr = self.__class__(self._width, self._breadcrumb_keys, otr_state)
        return otr

    def to_rows(self):
        # When you can't fit all of a long breadcrumb trail in the available
        # content run of the row, the leftmost part of the content string
        # will get an ellipsis expression like "[…] > foo > bar"

        # Start from the end of the breadcrumb trail (as a stack). Keep popping
        # pieces off of it and adding separators as necesary until your content
        # would exceed the available width.

        max_content_width = self._width - _sel_w
        sep = ' > '
        ellipsis = '[…] > '
        content = _render_breadcrumb_trail(
                max_content_width, self._breadcrumb_keys, ellipsis, sep)
        head = _piece_via_has_focus(self._has_focus)
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


# == Text Support

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


_sel_w = _piece_via_has_focus.width


# ==

def _write_widest(memo, k, leng):
    if k in memo:
        if memo[k] < leng:
            memo[k] = leng
    else:
        memo[k] = leng


# == FSA support

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
