from modality_agnostic.memoization import lazy


class _BusinessSchema:
    """DISCUSSION this was born (#birth) to fill a need, but with

    only a nebulous sense for even primary requirements or interface..
    """

    def __init__(self):

        """
        "options" marked #here1 are:
        - not really options per se, just leashes attached to ideas
        - hard-coded such that the thing they suggest is effectively disallowed
        - ..*not* hidden options. setting them to true won't make them true.
        """

        self._allow_empty_strings = False  # ##here1
        # for now, enforce consistency and beauty with an iron fist.
        # eventually we'll write a thing about not-set vs. none (null) vs this

        self._allow_multi_line_strings_with_no_final_newline = False  # #here1
        # we don't want to support this unless we are sure we want to

    def BUILD_ENTITY_ENCODER(self, listener):
        return _EntityEncoder(listener, self)


class _EntityEncoder:
    """this is a very API-private ad-hoc class. it's like a "hot" version

    of the business schema "pre-compiled" around one listener. we're
    imagining an imaginary scenario of needing to batch import more than
    one entity in an invocation..
    """

    def __init__(self, listener, o):
        self.semi_encode = _build_semi_encoder(listener, o)


def _build_semi_encoder(listener, o):

    allow_empty_strings = o._allow_empty_strings
    allow_unclean_blocks = o._allow_multi_line_strings_with_no_final_newline

    def semi_encode(mixed, name):

        """
        👉 at #birth there is no such provision but one day we might use the
        business schema to validate each incoming name-value pair against
        the specified set of names, if opted-in to as a voluntary constraint
        for this collection.
        """

        typ = type(mixed)

        """
        👉 at #birth there is no such provision but one day we will very
        likely provision for voluntary per-field type-constraints
        ("strict typing"), a sort of thing provided by RDBMS's indirectly.

        for now, we just want to make contact with the type of the value
        for the various reasons you see below..
        """

        if str == typ:
            # (Case4234)
            _se = _default_string_encoder()
            ses = _se.encode(mixed, listener)  # ses = semi-encoded string
            if ses is None:
                return

            lines = ses.semi_encoded_lines
            length = len(lines)

            if 0 == length:
                # (Case4258KR)
                assert(not allow_empty_strings)  # ..
                _whine_about_empty_string(listener, name)
                return

            if 1 != length and '\n' != lines[-1][-1]:
                # (Case4261)
                assert(not allow_unclean_blocks)
                _whine_about_unclean_blocks(listener, mixed, name)
                return

            return 'semi-encoded string', ses

        if bool == typ:
            return _use_vendor_lib, None  # (Case4336)

        if int == typ:
            return _use_vendor_lib, None  # (Case4232)

        if float == typ:
            return _use_vendor_lib, None  # (Case4234)

        if hasattr(typ, 'utcfromtimestamp'):
            # wickedly infer type (class) without adding a dependency
            cover_me('datetime probably, no problem')

        if mixed is None:
            cover_me("we don't want None, under provision 1")

        cover_me(f'wat do about this type - {typ}')

    return semi_encode


@lazy
def _default_string_encoder():
    from kiss_rdb.storage_adapters_.toml import (
        string_encoder_via_definition as se_lib)
    return se_lib.string_encoder_via_definition(
            smaller_string_max_length=56,   # 79 - tmx longest subproject name
            paragraph_line_max_width=79,  # the 80th column is special idk
            max_paragraph_lines=22,  # half my current screen's height lol
            )


# == whiners

def _whine_about_unclean_blocks(listener, big_s, attr_name_s):
    def structurer():
        return {
                'reason': (
                    'for now, multi-line strings must have a newline '
                    'as their final character'
                    ),
                'attribute_name': attr_name_s,
                'unsanitized_attribute_value': big_s,
                'input_error_type': 'attribute_value_error',
                }
    _emit_input_error(listener, structurer)


def _whine_about_empty_string(listener, attr_name_s):
    def structurer():
        _suggestion = 'maybe delete the attribute instead'
        return {
                'reason': 'for now, empty strings are not allowed generally',
                'attribute_name': attr_name_s,
                'unsanitized_attribute_value': '',
                'suggestion_sentence_phrase': _suggestion,
                'input_error_type': 'attribute_value_error',
                }
    _emit_input_error(listener, structurer)


def _emit_input_error(listener, structurer):  # one of several
    listener('error', 'structure', 'input_error', structurer)


# ==
def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


DEFAULT_BUSINESS_SCHEMA = _BusinessSchema()


_use_vendor_lib = 'use vendor lib'


# #birth.
