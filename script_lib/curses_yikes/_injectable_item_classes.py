from script_lib.curses_yikes import \
        piece_via_has_focus_ as _piece_via_has_focus, \
        StateButNoFSA_ as _StateButNoFSA, \
        MultiPurposeResponse_ as _response
from collections import namedtuple as _nt


def poly_option_state_machine():
    yield 'entered', '[a]dd', 'entering_name', 'call', '_EMACS', 'nn'
    yield 'entering_name', 'done_entering_name', 'entering_value', 'call', '_EMACS', 'vv'  # noqa: E501
    yield 'entering_value', 'done_entering_value', 'field_focus'
    yield 'field_focus', 'add-[a]fter', 'entering_name', 'call', '_EMACS', 'nn'  # noqa: E501# not-covered


def anonymous_text_field_state_machine():
    yield 'entered', '[a]dd', 'entering_val', 'call', '_EMACS'
    yield 'field_focus', 'add-[a]fter', 'entering_val', 'call', '_EMACS'
    yield 'entering_val', 'done_entering_val', 'field_focus'


def _same_where_to_insert():
    yield 'entered', '[a]dd', 'at_beginning'
    yield 'field_focus', 'add-[a]fter', 'insert_before', '[x]delete'


poly_option_state_machine.where_to_insert = _same_where_to_insert
anonymous_text_field_state_machine.where_to_insert = _same_where_to_insert


# == Poly-Option (abstract)

def poly_option_constructor_constructor_():

    class constructorConstructor:

        def abstract_area_via_value(_, val):

            name_s, val_s = val
            assert isinstance(name_s, str)  # #[#022]
            assert isinstance(val_s, str)  # #[#022]

            name_w = len(name_s)
            val_w = len(val_s)

            min_w = _hand_w + _lb_w + name_w + _spine_w + val_w + _rb_w
            return _min_width_and_value(min_w, val)

        def constructor_taking_mixed_value_via_width(_, w):
            return _poly_option(w)  # hi.

        @property
        def FFSA_for_injection(_):
            return _FFSA(poly_option_state_machine)

    return constructorConstructor()


# == Anoynmous field (abstract)

def anonymous_text_field_constructor_constructor_():

    class ConstructorConstructor:

        def abstract_area_via_value(_, val):
            assert isinstance(val, str)  # #[#022]
            min_w = _hand_w + _lb_w + len(val) + _rb_w  # #here1
            return _min_width_and_value(min_w, val)

        def constructor_taking_mixed_value_via_width(_, w):
            return _anonymous_text_field(w)  # hi.

        @property
        def FFSA_for_injection(_):
            return _FFSA(anonymous_text_field_state_machine)

    return ConstructorConstructor()


# == Poly-Option (concrete)

def _poly_option(w):

    class MutablePolyOption(_StateButNoFSA):

        def __init__(self, name_s, val_s):
            self._name_string = name_s
            self._value_string = val_s
            self._has_focus = False

        def receive_new_value_from_parent_(self, parent, text, which, item_k):
            if text is None or 0 == len(text):
                xx("feature buried at #history-B.4 during arch. changes")
            if 'nn' == which:
                return self._recv_name(parent, text, item_k)
            assert 'vv' == which
            return self._recv_value(parent, text, item_k)

        def _recv_name(self, parent, text, item_k):

            if 0 != len(self._name_string):
                xx('have fun deciding UX for editing')

            text = text.strip()
            if available_name_w < len(text):
                xx(f"strange: how did UI let this too-wide name thru: {text!r}")  # noqa: E501

            self._name_string = text
            return parent.experiment_transition('done_entering_name', item_k)

        def _recv_value(self, parent, text, item_k):

            if 0 != len(self._value_string):
                xx('have fun deciding UX for editing')

            text = text.strip()
            if available_val_w < len(text):
                xx(f"strange: how did UI let this too-wide value thru: {text!r}")  # noqa: E501

            self._value_string = text
            return parent.experiment_transition('done_entering_value')

        def to_row(self):
            return ''.join(self._to_row_pieces())

        def _to_row_pieces(self):
            yield _piece_via_has_focus(self._has_focus)
            yield left_bracket_blanks
            yield name_slot_format % self._name_string
            yield spine_blanks
            yield value_slot_format % self._value_string
            yield right_bracket_blanks

        def to_form_value(self):
            return self._name_string, self._value_string

        @property
        def component_buttons_page_key_when_has_focus(_):
            return 'field_focus'

        # == all CLASS METHODS below! (might do etc)

        def emacs(parent, which, *more):
            if 'nn' == which:
                return emacs_for_name(parent)
            assert 'vv' == which
            return emacs_for_value(parent, *more)

        def create_WIP_item_component():
            return MutablePolyOption('', '')

        is_focusable = True

    # == Our Story About Adding

    def emacs_for_name(parent):
        new_k = parent.item_key_of_eventual_item
        x, w = x_and_width_for_name()
        change1 = parent.build_change_for_insert_WIP_row(new_k)
        change2 = parent.build_change_for_show_EMACS_field(
                new_k, x, w, 'nn', new_k)
        return _response(changes=(change1, change2))

    def emacs_for_value(parent, item_k):
        x, w = x_and_width_for_value()
        change = parent.build_change_for_show_EMACS_field(
                item_k, x, w, 'vv', item_k)
        return _response(changes=(change,))

    def x_and_width_for_name():
        return _hand_w + lb_w, available_name_w

    def x_and_width_for_value():
        return _hand_w + lb_w + available_name_w + spine_w, available_val_w

    # Precalculate fixed terms:
    lb_w, spine_w, rb_w = _lb_w, _spine_w, _rb_w

    left_bracket_blanks = ' ' * lb_w
    right_bracket_blanks = ' ' * rb_w
    spine_blanks = ' : '
    assert spine_w == len(spine_blanks)

    my_content_available_w = w - _hand_w - lb_w - spine_w - rb_w
    assert 1 < my_content_available_w  # hypothetically 1 char wide fields

    # If the whole area is pretty narrow, we do roughly halfsies:
    #     len(" > [foo bar]:[biff bazz]") == 24 ; 24 - 8 = 16
    if my_content_available_w <= 16:

        half, plus = divmod(my_content_available_w, 2)
        available_name_w = half
        available_val_w = half + plus

        # Unless things are very narrow, for aesthetics we take one from the
        # name and give it to the value (even notwithstanding the above)
        if 9 < my_content_available_w:
            available_name_w -= 1
            available_val_w += 1

    # Otherwise (and things are of "normal" proportions)
    else:
        available_name_w = int(my_content_available_w / (1 + _this_ratio))
        available_val_w = my_content_available_w - available_name_w

    # Align-right the name piece
    name_slot_format = f"%{available_name_w}s"

    # Align-left the value piece
    value_slot_format = f"%-{available_val_w}s"

    return MutablePolyOption


# == Anonymous field (concrete)

def _anonymous_text_field(w):

    class ItemContructors:  # #not-necessary-as-class

        def emacs(_, parent):
            return emacs(parent)

        def unserialize(_, s):
            return unserialize(s)

        def create_WIP_item_component(_):
            return create_WIP_item_component()

    def emacs(parent):
        new_k = parent.item_key_of_eventual_item
        x = _hand_w + _lb_w
        change1 = parent.build_change_for_insert_WIP_row(new_k)
        change2 = parent.build_change_for_show_EMACS_field(
                new_k, x, slot_w, new_k)
        return _response(changes=(change1, change2))

    def unserialize(s):
        under_by = slot_w - len(s)
        if under_by < 0:
            xx("return an emission")
        return AnonymousTextField(s, ' ' * under_by), None

    def create_WIP_item_component():
        return AnonymousTextField('', ' ' * slot_w)

    class AnonymousTextField(_StateButNoFSA):

        def __init__(self, x, filler):
            self.value_string = x
            self.rest = ''.join((' ', x, filler, ' '))  # #here1

        def receive_new_value_from_parent_(self, parent, text, my_key):
            text = text.strip()
            under_by = slot_w - len(text)
            assert 0 <= under_by
            filler = ' ' * under_by
            self.__init__(text, filler)  # WHAT
            return parent.experiment_transition('done_entering_val', my_key)

        def to_row(self):
            pc = _piece_via_has_focus(self._has_focus)
            return ''.join((pc, self.rest))

        def to_form_value(self):
            return self.value_string

        @property
        def component_buttons_page_key_when_has_focus(_):
            return 'field_focus'

        is_focusable = True

    slot_w = w - _hand_w - _lb_w - _rb_w  # #here1
    assert 0 < slot_w  # assume concretization negotiated fairly
    return ItemContructors()


def _FFSA(fsa_def):  # copy-paste-modify. memoize the FFSA into its own func
    if not hasattr(fsa_def, '_FFSA_'):
        from ._formal_state_machine_collection import \
            build_formal_FSA_via_definition_function_ as func
        wti = fsa_def.where_to_insert()
        fsa_def._FFSA_ = func(__name__, fsa_def, where_to_insert=wti)
    return fsa_def._FFSA_


_min_width_and_value = _nt('_min_w_and_val', ('minimum_width', 'value'))
_hand_w = _piece_via_has_focus.width
_this_ratio = 2.75  # keymashing this looked fine: 8 chars : 22 chars


# Imagining:
'  👉  [  chamoochie]:[fachoochie  ]'
'  👉     chamoochie : fachoochie   '
# such that:  [hand][left bracket][name slot][spine][value slot][right bracket]
_lb_w = 1  # left bracket width
_rb_w = _lb_w
_spine_w = _rb_w + len(':') + _lb_w


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #history-B.4
# #broke-out
