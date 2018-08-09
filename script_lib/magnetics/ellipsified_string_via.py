def complicated_join(left, sep, right, itr, max_width, string_via_item):
    """
    this is something like a width-sensitive `str.join` (and is experimental):

    result in a string whose width does not exceed `max_width` (provided your
    string arguments make sense in the expected way), whereby the items from
    `itr` are stringified using `string_via_item` and ellipsified as necessary;
    all nested in the `left` and `right` delimiter strings and joined with
    the `sep` string. whew!

        subject("wow: (", ", ", ")", iter(['a', 'b', c']), 13, lambda x: x)

    gets you:

        "wow: ('a', 'b'..)"


    Issues:
      - because we don't bother with lookahead, full traversals that
        would exactly fit (or come within one (maybe 2)) will be missed,
        because we always assume we will be adding the '..'. if your full
        traversal comes out to a width that is at or less than maxwidth
        minus ~2, ok.

    (#coverpointTL.1.5.1.1)
    (#[#007.2] wish for doctest)
    """

    tail_ellipsis = '..'
    current_width = len(left) + len(right) + len(tail_ellipsis)
    pieces = [left]

    def sep_stuff_at_this_step():  # don't use separator on the first step
        nonlocal sep_stuff_at_this_step
        real_tuple = (len(sep), sep)

        def sep_stuff_at_this_step():
            return real_tuple
        return (0, '')

    broke = False
    for x in itr:
        as_string = string_via_item(x)
        w, use_sep = sep_stuff_at_this_step()

        would_be_width = current_width + w + len(as_string)

        if would_be_width > max_width:
            broke = True
            break

        pieces.append(use_sep)
        pieces.append(as_string)
        current_width = would_be_width

        if would_be_width == max_width:
            broke = True
            break

    if broke:
        pieces.append(tail_ellipsis)

    pieces.append(right)
    return ''.join(pieces)


# #born.
