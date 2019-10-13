"""DISCUSSION/EXPERIMENTAL: 👉 we originally thought that we (as the modality

client) would tend towards writing one custom case expressor per emission
case. But this approach is neither scale-friendly nor necessary. Rather, what
has emerged is a semi-generalized approach to surface expression of emissions:

    (slot A) (slot B) (slot C) (slot D)
    multiline line 1
    multiline line 2..

Where:

👉 "slot A" is a surface expression derived from the third and any fourth
channel component ("error category" and "error case" when error), for example:
('cannot_load_config', 'parse_error') as "cannot load config: parse error: ".

👉 "slot B" is sort of a grandfather provision for specialized expression of
issues with setting an entity attribute value (CREATE or UPDATE).

👉 "slot C" takes the 'reason' or similar.

👉 "slot D" is specialized for expressing a path/filename *when* it will not
already be expressed in the below multiple lines.

👉 "multiple lines" slot is specialzied for rendering "parse error context"


History:

👉 At #history-A.2 changed from being case-oriented to pattern-oriented.
A simple case as a regression-point: (Case5918)
"""
# this is the most apotheotic extant implementation (at writing) of #[#008.11]


def WHINE_ABOUT(echo, channel_tail, dim_pool):
    # dim_pool = "diminishing pool"
    for line in __lines(channel_tail, dim_pool):
        echo(line)


def __lines(channel_tail, dim_pool):  # dim_pool = "diminishing pool"
    slots = _Slots()
    channel_tail = list(channel_tail)
    __fix_this_one_smell(channel_tail, dim_pool)
    __occupy_slot_A(slots, channel_tail)
    present = set(dim_pool.keys()) & set(_func_via_key)
    funcs_present = {_func_via_key[k]: None for k in present}.keys()
    funcs_present = sorted(funcs_present)  # necessary for #here1
    for func_name in funcs_present:
        _functions[func_name](slots, dim_pool)
    __we_are_explicitly_ignoring_these_components(dim_pool)
    assert(not len(dim_pool))
    if slots.do_reduce_redundancy:
        __reduce_redundancy(slots)
    return __lines_via_prepared(slots)


# forward-declare functions we define below

def _():
    i = 0
    while True:
        i += 1
        yield i


o = _().__next__
_attr_value_thing = o()
_reason_stuff = o()
_context_for_parse_error = o()  # before next (#here1)
_pathish_stuff = o()  # after above (#here1)


# associate each payload component with ONE expresser function

_func_via_key = {
        'attribute_name': _attr_value_thing,
        'expecting': _reason_stuff,
        'filename': _pathish_stuff,
        'line': _context_for_parse_error,
        'lineno': _context_for_parse_error,
        'path': _pathish_stuff,
        'position': _context_for_parse_error,
        'reason': _reason_stuff,
        'reason_tail': _reason_stuff,
        'unsanitized_attribute_value': _attr_value_thing,
        }


# implement the slot thing

class _Slots:

    def __init__(self):
        self._mutexes = set(_slots)
        self._values = {k: None for k in _slots}
        self.do_reduce_redundancy = False
        self.did_express_path_on_multi_lines = False
        self.do_use_final_period = False

    def occupy_slot(self, which, s):
        self._mutexes.remove(which)
        self._values[which] = s

    def slot_is_occupied(self, which):
        return self._values[which] is not None

    def __getitem__(self, which):
        return self._values[which]  # should raise when None but meh


_slots = ('A', 'B', 'C', 'D', 'multiple_lines')


def __lines_via_prepared(slots):
    _first_line = ''.join(__pieces_for_first_line(slots))
    yield _first_line
    if slots.slot_is_occupied('multiple_lines'):
        for line in slots['multiple_lines']:
            yield line


def __pieces_for_first_line(slots):

    class _IsFirst:
        def __init__(self):
            self._is_first = True

        def clear(self):
            self._is_first = True

        def __call__(self):
            if self._is_first:
                self._is_first = False
                return False
            return True

    y = _IsFirst()

    for human in slots['A']:
        if y():
            yield ': '
        yield ' '.join(human)

    if slots.slot_is_occupied('B'):
        if y():
            yield ': '
        yield slots['B']
        y.clear()  # (Case6258)

    if slots.slot_is_occupied('C'):
        if y():
            yield ': '
        yield slots['C']

    if slots.slot_is_occupied('D'):
        assert(not slots.did_express_path_on_multi_lines)
        o = slots['D']
        if y():
            yield o.separator_before_path
        yield o.filename_or_path

    if slots.do_use_final_period:
        yield '.'  # (Case6258) (again)


# each expresser function will register under its identifier (integer)

_functions = {}


def _define(i):
    def decorate(f):
        _functions[i] = f
        return f
    return decorate


# define the functions

def __occupy_slot_A(slots, channel_tail):
    slots.occupy_slot('A', [s.split('_') for s in channel_tail])


@_define(_attr_value_thing)
def _attr_value_thing(slots, dim_pool):
    o = dim_pool.pop
    an = o('attribute_name')
    av = o('unsanitized_attribute_value')
    slots.occupy_slot('B', f"Could not set '{an}' to {repr(av)} because ")
    slots.do_use_final_period = True


@_define(_reason_stuff)
def _reason_stuff(slots, dim_pool):
    k, = [k for k in ('expecting', 'reason_tail', 'reason') if k in dim_pool]
    content_s = dim_pool.pop(k)
    if 'reason' == k:
        s = content_s
        y = True
    elif 'reason_tail' == k:
        s = content_s
        y = False
    else:
        assert('expecting' == k)
        s = f'expecting {content_s}'
        y = False
    slots.occupy_slot('C', s)
    slots.do_reduce_redundancy = y


@_define(_pathish_stuff)
def _pathish_stuff(slots, dim_pool):

    if slots.did_express_path_on_multi_lines:  # #here1
        assert('filename' not in dim_pool)
        return

    k, = tuple(k for k in ('filename', 'path') if k in dim_pool)  # assertion

    class struct:  # #as-namespace-only
        separator_before_path = ' - '
        filename_or_path = dim_pool.pop(k)

    slots.occupy_slot('D', struct)


@_define(_context_for_parse_error)
def _context_for_parse_error(slots, dim_pool):
    slots.did_express_path_on_multi_lines = True  # (Case6248)
    _ = tuple(__lines_for_context_for_parse_error(dim_pool))
    slots.occupy_slot('multiple_lines', _)


def __lines_for_context_for_parse_error(dim_pool):
    # we fold "filename" in because even though it is not used as part of
    # parse error context metadata, its surface format is the same

    # this will fail eventually, not all PE's provide all these (right?)
    o = dim_pool.pop
    path = o('path', None)
    line = o('line')
    lineno = o('lineno', None)
    position = o('position')
    # --
    from kiss_rdb.magnetics.string_scanner_via_string import (
            two_lines_of_ascii_art_via_position_and_line)
    _2 = tuple(two_lines_of_ascii_art_via_position_and_line(position, line))

    if lineno is None:
        num_as_s = ' '
        spacer = ''
    else:
        num_as_s = f'{lineno}:'  # (Case6248)
        spacer = ' ' * len(num_as_s)

    if path is not None:
        yield f"in {path}"

    yield f'  {num_as_s}{_2[0]}'
    yield f'  {spacer} {_2[1]}'


# mishmash

def __we_are_explicitly_ignoring_these_components(dim_pool):
    # (Case6064)
    dim_pool.pop('did_traverse_whole_file', None)
    dim_pool.pop('identifier_string', None)


def __reduce_redundancy(slots):
    import re
    _first_word = re.match('[^ :]+', slots['C'])[0]
    _first_word_of_last_human = slots['A'][-1][0]
    if _first_word_of_last_human == _first_word.lower():
        # covered at: ('collection_not_found', 'no_such_file_or_directory')
        slots['A'].pop()


def __fix_this_one_smell(channel_tail, dim_pool):  # #point-1
    # we went thru a phase where we weirdly wanted every emission be one of
    # a very small set of error categories. It was wrong to put a
    # sub-categorization *in* the payload. #wish [#873.B]

    if 'input_error_type' in dim_pool:
        channel_tail.append(dim_pool.pop('input_error_type'))

# #pending-rename: to script-lib somewhere
# #history-A.2
# #history-A.1
# #abstracted.
