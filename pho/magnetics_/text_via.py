"""(Generic text lib when we don't want to depend on text_lib)"""


def word_wrap_pieces_using_commas(pieces_without_commas, line_width):
    pieces = _pieces_with_commas_via_pieces(iter(pieces_without_commas))
    return _word_wrap_pieces(pieces, line_width)


def _word_wrap_pieces(pieces, line_width):
    # our own word-wrap again [#612.6], why always so long 😩

    assert 8 < line_width  # something sane

    tot, cache = 0, []
    for piece in pieces:
        leng = len(piece)
        is_first_piece_on_line = 0 == len(cache)
        next_tot = leng if is_first_piece_on_line else (tot + 1 + leng)

        # If we would still be under the limit by adding this content..
        if next_tot < line_width:
            if not is_first_piece_on_line:
                cache.append(' ')
            cache.append(piece)
            tot = next_tot
            continue

        # If adding this content puts us exactly at the limit..
        if next_tot == line_width:
            cache.extend((' ', piece))
            yield ''.join(cache)  # #here1
            cache.clear()
            tot = 0
            continue

        # Adding this content would put us over
        assert line_width < next_tot

        # If this is the first piece, output it anyway -
        # breaking long words is well outside our scope
        if is_first_piece_on_line:
            yield piece  # #here1
            continue

        # Flush the definitely existing content then start a new line
        yield ''.join(cache)  # #here1
        cache.clear()
        cache.append(piece)
        tot = leng

    if len(cache):
        yield ''.join(cache)  # #here1


def _pieces_with_commas_via_pieces(itr):
    # to be used in conjunction with word wrap pieces above
    # (avoiding using "scanner" as an exercise)

    prev = next(itr)  # ..
    for pc in itr:
        yield f"{prev},"
        prev = pc
    yield f"{prev}."  # or no period, or make in an option


def oxford_join(slugs, sep):  # rewrite something in text_lib
    leng = len(slugs := tuple(slugs))
    seps = '', *(', ' for _ in range(0, leng-2)), sep
    rows = tuple((seps[i], repr(slugs[i])) for i in range(0, leng))
    return ''.join(s for row in rows for s in row)


def our_repr(mixed):

    def do_repr():
        return ''.join((': ', repr(mixed)))

    if not isinstance(mixed, str):
        assert(isinstance(mixed, tuple))  # ..
        return do_repr()

    if len(mixed) <= _SOMEWHAT_LESS_THAN_A_LINES_WIDTH:  # meh
        return do_repr()

    return ''


_SOMEWHAT_LESS_THAN_A_LINES_WIDTH = 60

# #abstracted
