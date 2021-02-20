"""
This is a cluster of functions written very ad-hoc-ly for one client,
but it's one we have generalized because it's such a well-known, isolated
concern, it's one we thought we would draw the well-defined boundary around
that is probably expected of libraries like it.

(Likewise we needed to have it isolated as its own thing for the boring
task of testing it in all its perumations)
"""

from datetime import datetime


def given(context_stack):  # here just to make doctests read prettier 🙃
    ws = prepositional_phrase_words_via_context_stack(context_stack)
    return ' '.join(ws)


def prepositional_phrase_words_via_context_stack(context_stack):
    r"""Slot Theory: here's a full-ish formal example:

    >>> given((('year', 2021), ('month', 3), ('day', 21), ('hour', 16), ('minute', 59)))  # noqa: E501
    'on March 21st, 2021 at 4:59pm'

    We see this as a stacking/nesting of two prepositional phrases:

        "On March 21st, 2021 at 4:59pm"
        \__________________/ \_______/

    We can build those two sub-phrases (when both needed) independently.
    They may be produced both, or just the first one or just the second one
    (but there should be at least one of these formal slots occupied).

    Note it's a natural-enough to produce them in the other order
    ("at 4:49pm on March 21st, 2021"), but we don't produce this other
    way, just because we find that our way sounds a bit more natural.

    (But yes in general this whole topic tickles the OCD because of how
    jaggedly one jumps up and down and back up again on the denomination
    sizes for all formats except those like "YYYY-MM-DD HH:MM:SS" etc)

    Different denominations use different prepositions:

    Year uses "in":
    >>> given((('year', 2021),))
    'in 2021'

    Month uses "in":
    >>> given((('month', 3),))
    'in March'

    Day uses "on":
    >>> given((('day', 21),))
    'on the 21st'

    Hour AND minute use "at":
    >>> given((('hour', 16), ('minute', 59)))
    'at 4:59pm'

    Just hour (cutely) uses "in":
    >>> given((('hour', 16),))
    'in the 4pm hour'

    Just minutes (cutely) uses "at":
    >>> given((('minute', 59),))
    'at 59 minutes past the hour'

    And there is something like precedence-rules taking place, where we need
    exactly one preposition per sub-phrase, and when there are the different
    active denominations that want different prepositions, they duke it out
    somewhow.

    It's not simply a matter of proximity. Month wants "in" and day wants
    "on"; when there's both month and day; day always wins regardless of the
    order: "on the 21st of March" BUT ALSO "on March 21st"

    There is perhaps the vector of "avoid the sound of redundancy", where
    we might say "the 21st of March" and we say "March of 2021", but it
    sounds somewhat awkward to produce say "the 21st of March of 2021",
    perhaps because that "of" repeating can be seen as superfluous.

    (Perhaps this is the same vector that led to the "oxford comma"
    production, where a would-be repeated "and" or "or" is reduced to a comma
    (pre-emptively even!))

    One way to distill this theory is to say that subsequnt would-be
    "of"s become commas, so:

    "on the 21st of March, 2021" not "the 21st of March of 2021"

    Whether or not we code for this form of produciton by generalizing it or
    by hard-coding it is left undefined in this comment.

    But actually, it looks like we're never using this "of" form, because
    maybe we always say "March 21st" and not "the 21st of March". So:

    >>> given((('year', 2021), ('month', 3)))
    'in March of 2021'

    We don't handle the larger or smaller denominations (e.g. "seconds")
    only for lack of use-case yet.
    """

    assert len(context_stack)
    big, little = _partition_into_big_and_little(context_stack)

    words_for_bigger = _words_for_bigger(big)
    words_for_smaller = _words_for_smaller(little)

    return (*words_for_bigger, *words_for_smaller)


def _words_for_bigger(dct):
    if 0 == len(dct):
        return ()
    year = dct.pop('year', None)
    month = dct.pop('month', None)
    day = dct.pop('day', None)
    assert not dct

    use_preposition = None
    use_comma = False

    day_words, month_words, year_words = [], [], []

    if year is not None:
        use_preposition = 'in'
        year_words.append(str(year))

    if month is not None:
        use_preposition = 'in'
        month_words.append(_word_via_month_integer(month))
        if day is None and year is not None:
            month_words.append('of')

    if day is not None:
        use_preposition = 'on'
        if month is None:
            day_words.append('the')
        day_words.append(_ordinal_via_day_of_month_integer(day))

        if year is not None:
            use_comma = True

    result = [use_preposition, *month_words, *day_words]
    if use_comma:
        result[-1] = ''.join((result[-1], ','))

    result.extend(year_words)
    return result


def _words_for_smaller(tings):
    if 0 == len(tings):
        return ()
    hours = tings.pop('hour', None)
    minutes = tings.pop('minute', None)
    assert not tings

    if hours is None:
        assert minutes is not None
        return _words_for_minutes_alone(minutes)

    if minutes is None:
        return _words_for_hours_alone(hours)

    return _words_for_hours_and_minutes(hours, minutes)


def _words_for_hours_and_minutes(hours, minutes):
    dt = datetime(1, 1, 1, hour=hours, minute=minutes)  # assert range of minu
    hour_piece, am_pm_piece = _words_for_hour_and_AM_or_PM(dt)
    minute_piece = '%02d' % minutes  # (or the other way but why)

    hours_minutes = ':'.join((hour_piece, minute_piece))
    one_word_i_guess = ''.join((hours_minutes, am_pm_piece))

    return "at", one_word_i_guess


def _words_for_hours_alone(hours):
    dt = datetime(1, 1, 1, hour=hours)  # asserts that hour is in range
    hour_word, am_pm_word = _words_for_hour_and_AM_or_PM(dt)

    # "in the 5pm hour"
    return "in", "the", ''.join((hour_word, am_pm_word)), "hour"


def _words_for_minutes_alone(minutes):
    if 0 == minutes:
        return "on the hour".split()  # meh
    return f"at {minutes} minute{_s(minutes)} past the hour".split()


def _words_for_hour_and_AM_or_PM(dt):
    use_hour, use_AM_PM = dt.strftime('%I %p').split()

    # If the hour is one digit, no leading zero (no format opt for this 😮)

    h = dt.hour
    if 12 < h:
        h -= 12

    if 0 < h < 10:
        use_hour = str(h)

    # Ignore locale, we always want it the (de_DE) way (one day config)
    use_AM_PM = use_AM_PM.lower()

    return use_hour, use_AM_PM


# ==

def _partition_into_big_and_little(context_stack):
    which = {'big': {}, 'little': {}}
    for key, value in context_stack:
        dct = which[_big_or_little[key]]
        assert key not in dct  # not gigo here
        dct[key] = value
    return which.values()


_big_or_little = {
    'year': 'big', 'month': 'big', 'day': 'big',
    'hour': 'little', 'minute': 'little'}  # ..


# ==

def _word_via_month_integer(month):
    o = _word_via_month_integer
    if (s := o.x.get(month)) is None:
        s = datetime(year=1, month=month, day=1).strftime('%B')  # locale
        o.x[month] = s
    return s


_word_via_month_integer.x = {}  # #[#510.4] custom memoization


def _ordinal_via_day_of_month_integer(n):
    # (from Gareth on codegolf (via s/o).)
    # (We've written this at least 3 times before but never this golfy/goofy)

    start = (n//10 % 10 != 1) * (n % 10 < 4) * n % 10
    return "%d%s" % (n, "tsnrhtdd"[start::4])

# ==


def _s(d):
    assert isinstance(d, int)
    return '' if 1 == d else 's'


def xx(msg=None):
    raise RuntimeError(''.join(('not covered', *((': ', msg) if msg else ()))))


def _run_doctest():
    from doctest import testmod as func
    func()


if __name__ == '__main__':
    _run_doctest()

# #born
