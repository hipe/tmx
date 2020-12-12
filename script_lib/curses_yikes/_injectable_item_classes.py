from script_lib.curses_yikes import \
        piece_via_has_focus_ as _piece_via_has_focus, \
        StateButNoFSA_ as _StateButNoFSA
from collections import namedtuple as _nt


def anonymous_text_field_state_machine():
    yield 'entered', '[a]dd', 'adding', 'call', '_EMACS'
    yield 'field_focus', 'add-[a]fter', 'adding', 'call', '_EMACS'


def _where_to_insert():  # experiment
    yield 'entered', '[a]dd', 'at_beginning'
    yield 'field_focus', 'add-[a]fter', 'insert_before', '[x]delete'


anonymous_text_field_state_machine.where_to_insert = _where_to_insert


# == Anoynmous field

def abstract_anonymous_text_field_():

    class Constructors:

        def abstract_area_via_value(_, val):
            assert isinstance(val, str)  # #[#022]
            min_w = left_w + 1 + len(val) + 1  # #here1
            return aa(min_w, val)

        def constructor_taking_mixed_value_via_width(_, w):
            return _anonymous_text_field(w)  # hi.

        @property
        def FFSA_for_injection(_):
            return _FFSA(anonymous_text_field_state_machine)

    aa = _nt('AA', ('minimum_width', 'value'))
    left_w = _piece_via_has_focus.width
    return Constructors()


def _anonymous_text_field(w):

    def build(x):
        leng = len(x)
        under_by = my_content_width - leng
        if under_by < 0:
            xx()
        filler = ' ' * under_by
        return AnonymousTextField(x, filler), None

    class AnonymousTextField(_StateButNoFSA):

        def __init__(self, x, filler):
            self.value_string = x
            self.rest = ''.join((' ', x, filler, ' '))  # #here1

        def to_row(self):
            pc = _piece_via_has_focus(self._has_focus)
            return ''.join((pc, self.rest))

        @property
        def component_buttons_page_key_when_has_focus(_):
            return 'field_focus'

        is_focusable = True

    my_width = w - _piece_via_has_focus.width
    my_content_width = my_width - 2  # #here1 "[value]" mebbe
    return build


def _FFSA(fsa_def):  # copy-paste-modify. memoize the FFSA into its own func
    if not hasattr(fsa_def, '_FFSA_'):
        from ._formal_state_machine_collection import \
            build_formal_FSA_via_definition_function_ as func
        wti = fsa_def.where_to_insert()
        fsa_def._FFSA_ = func(__name__, fsa_def, where_to_insert=wti)
    return fsa_def._FFSA_


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #broke-out
