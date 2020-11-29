from collections import namedtuple as _nt


def quick_and_dirty_word_wrap(max_w, words_tuple):  # #[#612.6]
    # We assume that your widest word is not wider than your constraint
    # otherwise the resulting plan will silently exceed your constraint.

    def next_line():
        o = scn.next()  # you have to accept at least one word off the scanner
        curr_offsets = [o.word_offset]
        curr_w = o.word_width

        # If there was only one word, or it's already equal or over, done
        if max_w <= curr_w:  # ..
            return tuple(curr_offsets)

        # Now you've got this one word on your rack
        # and you've gotta express it eventually..

        while scn.more:
            curr_w += 1  # for a space
            curr_w += scn.peek.word_width

            # Would adding the next word put you over?
            if max_w < curr_w:
                # ..then return the rack as-is without adding the next word
                return tuple(curr_offsets)

            # Would adding this one word land exactly on the limit?
            if max_w == curr_w:
                # ..then add the word to the rack and return it
                curr_offsets.append(scn.next().word_offset)
                return tuple(curr_offsets)

            # Since adding the next word will not put us on or over:
            assert curr_w < max_w
            curr_offsets.append(scn.next().word_offset)

        # Since you broke out of the above loop (or never entered it),
        # you have nonzero words racked that do not exceed the limit
        return tuple(curr_offsets)

    scn = _scanner_via_iterator(_word_offset_and_widths(words_tuple))

    while scn.more:
        yield next_line()


def _word_offset_and_widths(words_tuple):
    for i in range(0, len(words_tuple)):
        yield _Word(i, len(words_tuple[i]))


def _scanner_via_iterator(itr):
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func(itr)


_Word = _nt('Word', ('word_offset', 'word_width'))

# #broke-out
