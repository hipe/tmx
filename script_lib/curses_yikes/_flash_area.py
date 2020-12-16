import re


class __Abstract_Flash_Area__:

    def __init__(self, _magic_key_name_always_same, *optional_def_tail):
        kw = {'starting_height': 2}
        stack = list(optional_def_tail)  # not reversed because why
        while stack:
            v, k = stack.pop(), stack.pop()
            kw[k]  # assert it's a valid option
            kw[k] = v
        self._do_init(**kw)

    def _do_init(self, starting_height):
        assert 0 < starting_height
        self._starting_height = starting_height

    def concretize_via_available_height_and_width(self, h, w, listener):
        return _ConcreteFlashArea(h, w)

    def minimum_height_via_width(self, _):
        # it's a tiny bit ambiguous but we call our attribute "starting height"
        # rather than "minimum height" to emphasize that it might grow higher.
        # Although we word-wrap, we don't ever know our content up-front and
        # it changes at runtime, so we have no use for the argument width term.
        return self._starting_height

    minimum_width = 38  # 2 + len("Error: Unable to parse value for […]")
    two_pass_run_behavior = 'break'
    can_fill_vertically = True  # maybe hard-code this to off at first..
    is_interactable = False
    defer_until_after_interactables_are_indexed = False


KLASS = __Abstract_Flash_Area__


class _ConcreteFlashArea:

    def __init__(self, h, w):
        assert h
        assert w

        self._height, self._width = h, w

        def word_wrap(words_tuple):
            return func(w, words_tuple)
        from script_lib.curses_yikes.text_lib_ import \
            quick_and_dirty_word_wrap as func
        self._word_wrap = word_wrap

        self._blank_row = ' ' * w
        self._full_height_range = range(0, h)
        self._is_clear = True

    def receive_emissions(self, emis):
        self.clear_flash_area()  # imagine continuous scrolling NO
        emis = _only_the_most_severe_of_these_emissions(emis)
        if not len(emis):
            return

        # Flatten all our messages into a stream of words (sort of)
        words = _words_via_emissions_with_sentence_hack(emis)
        return self._receive_words(words)

    def receive_message(self, msg):
        self.clear_flash_area()
        words_itr = _words_via_msg_lol(msg)
        return self._receive_words(words_itr)

    def _receive_words(self, words_itr):
        words = _words_tuple_via_words_iterator_with_sanity_check(words_itr)

        # Get the "grid" that the word wrap came up with
        grid = tuple(self._word_wrap(words))
        grid_height = len(grid)

        # If the produced grid exceeds our available height, clip it to fit.
        # Doing so will likely mean cutting a message off mid-message at some
        # some circumstantial point between words.
        do_ellipsify = False
        if self._height < grid_height:
            grid = grid[0:self._height]
            do_ellipsify = True

        # Finalize the content rows (made fully wide, ellipsified)
        row_contents = (' '.join(words[i] for i in iz) for iz in grid)
        final_rows = [self._finalize_row(s) for s in row_contents]
        if do_ellipsify:
            final_rows[-1] = _ellipsifier(final_rows[-1])

        # (Conversely) if the grid doesn't fill avaliable height, fill it :/
        # (At one point we imagined that under such cases we would want to
        # be able to "communicate" this extra space and "give it back" up to
        # some layout controller that could then re-ditribute it to another
        # area that could use it (like a growable list). The problem there is,
        # then you could perhaps never get the space back if you needed it.)
        under_by = self._height - len(grid)
        if 0 < under_by:
            these = tuple(self._blank_row for _ in range(0, under_by))
            if True:  # for now, always float upwards. When we need it, option
                final_rows = (*these, *final_rows)
            else:
                final_rows = (*final_rows, *these)

        self._is_clear = False
        self._final_rows = final_rows

    def _finalize_row(self, content):
        assert '\n' not in content
        clen = len(content)
        under_by = self._width - clen
        if 0 < under_by:
            return ''.join((content, ' '*under_by))
        if 0 == under_by:
            return content
        assert under_by < 0

        # According to the intended behavior of our word wrap, the only time
        # a produced line exceeds the given width limit is when a single word
        # exceeds that limit. (Hyphenating or otherwise breaking "long" words
        # is way out of its scope, and way out of our scope is using an
        # external vendor library for word-wrapping.)
        #
        # What our OCD would *like* to do in these cases is fall back to an
        # entirely different wrapping strategy for this whole rasterization
        # instant: one where words are *always* broken mid-word when they
        # land jaggedly, an effect that would be both interesting-looking and
        # near unreadable. (Tiny bit of trivia: really old bibles were first
        # written this way?)
        #
        # But alas, that's too crazy a rabbit hole for even us to go down
        # right now. so instead, we punish the user (and/or content producer)
        # by just occluding the ends of long words arbitrarily, perhaps with
        # no fanfare or indication that we did this. That is, we "clip"

        clipped = content[0:self._width]

        ellipsifier = _ellipsifier

        # When ellipsifying the row would replace more than 1/3 of its content
        if self._width < (3 * ellipsifier.ellipsis_length):
            return clipped  # .. the it's just pure punishment

        final = ellipsifier(clipped)
        assert self._width == len(final)
        return final

    def clear_flash_area(self):
        if self._is_clear:
            return
        self._final_rows = None
        self._is_clear = True

    def to_rows(self):
        if self._is_clear:
            for _ in self._full_height_range:
                yield self._blank_row
            return
        for row in self._final_rows:
            yield row

    is_focusable = False


def _words_tuple_via_words_iterator_with_sanity_check(words_itr):
    words, count = [], 0
    for word in words_itr:

        # Our first readme has 9 words on the first long line right now.
        # Our terminal currently has 33 visible rows. Enough "words" to
        # fill half a screen seems like "a lot" ~(9 * 33 / 2)

        if 150 == count:
            xx('sanity, many words, make wordwrap streaming')

        count += 1
        words.append(word)
    return words  # not tuple but it's okay


def _words_via_emissions_with_sentence_hack(emis):

    def handlers_defined_magically():
        def on_word_that_is_both_first_and_last_word_of_message(w):
            return add_trailing_punct_with_kinky_rules(w).capitalize()

        def on_word_that_is_first_but_not_last_word_of_message(w):
            return w.capitalize()

        def on_word_that_is_last_but_not_first_word_of_message(w):
            return add_trailing_punct_with_kinky_rules(w)

        return locals()

    kw = handlers_defined_magically()

    def add_trailing_punct_with_kinky_rules(w):
        if w.has_trailing_punctution_of_any_kind:
            return w

        if w.emission_severity_was_serious:
            return w.with_serious_trailing_punctuation()

        if w.has_message_following_it:
            return w.with_a_period()

        return w

    return _words_lol(emis, ** kw)


def _words_lol(
        emis, on_word_that_is_first_but_not_last_word_of_message,
        on_word_that_is_last_but_not_first_word_of_message,
        on_word_that_is_both_first_and_last_word_of_message):

    def wrap(word):
        has_msg_after = not(is_last_emission and is_last_message_in_this_emi)
        return _QualifiedWord(word, sev, has_msg_after)

    def unwrap(word):
        return word.to_string()

    emi_scn = _scanner_via_iterator(iter(emis))
    is_last_emission = False
    while emi_scn.more:
        emi = emi_scn.next()
        sev = emi.severity
        if emi_scn.empty:
            is_last_emission = True

        is_last_message_in_this_emi = False
        _ = _enhanced_messages_via_emission(emi)  # could become option
        msg_scn = _scanner_via_iterator(iter(_))
        while msg_scn.more:
            msg = msg_scn.next()
            if msg_scn.empty:
                is_last_message_in_this_emi = True

            word_scn = _word_scanner_lol(msg)

            word = word_scn.next()
            if word_scn.empty:
                yield unwrap(on_word_that_is_both_first_and_last_word_of_message(wrap(word)))  # noqa: E501
                continue
            yield unwrap(on_word_that_is_first_but_not_last_word_of_message(wrap(word)))  # noqa: E501
            while True:
                word = word_scn.next()
                if word_scn.more:
                    yield word  # 👀
                    continue
                break
            yield unwrap(on_word_that_is_last_but_not_first_word_of_message(wrap(word)))  # noqa: E501


class _QualifiedWord:

    def __init__(self, string, sev, has_msg_after):
        self._string, self._severity = string, sev
        self.has_message_following_it = has_msg_after

    def capitalize(self):
        current = self._string[0]
        use = current.upper()
        if current == use:
            return self
        return self._copy(''.join((use, self._string[1:])))

    def with_serious_trailing_punctuation(self):
        return self._with_trailing_punctuation('!')

    def with_a_period(self):
        return self._with_trailing_punctuation('.')

    def _with_trailing_punctuation(self, s):
        return self._copy(''.join((self._string, s)))

    def _copy(self, new_str):
        return self.__class__(new_str, self._severity, self.has_message_following_it)  # noqa: E501

    @property
    def has_trailing_punctution_of_any_kind(self):
        c = self._string[-1]

        # If the string ends in any of these, we are sure we don't want punct
        if c in '.?!)':
            return True

        # If the string ends in any of these, we are sure we do want punct
        if re.match(r'[a-zA-Z0-9]\Z', c):
            return False

        # #cover-me: (developed visually)
        # If the string ended in a sinqle or double quote, yes punct
        if c in ('"', "'", '®'):
            return False

        # Probably ok just to default to returning False but..
        xx(f"lol have fun with the potentially huge scope of this: {c!r}")

    @property
    def emission_severity_was_serious(self):
        return _is_serious[self._severity]

    def to_string(self):
        return self._string


def _only_the_most_severe_of_these_emissions(emis):
    """return only the most severe group from "group-by-severity" index

    Less-sever emissions can confuse the meaning of more severe ones,
    when they are displayed in a jumble.

      "The portion sizes were small. Then a fire started at the restaurant."

    ☝️ It makes you wonder if the one had something to do with the other
    (especially considering the jump in severity).

    However, we may want to make the grouping less granular; like,
    if there's error-then-fatal; seeing only the fatal might be less
    helpful than also seeing the error. But meh this is too much already
    """

    index = _group_emissions_by_severity(emis)
    if len(index):
        return tuple(index[next(iter(index.keys()))])
    return ()


def _group_emissions_by_severity(emis):

    # Group the emissions by priority integer
    index = {}
    for emi in emis:
        priority_integer = _priority_via_severity[emi.severity]
        if (arr := index.get(priority_integer)) is None:
            index[priority_integer] = (arr := [])
        arr.append(emi)

    # Order the participating integers with lowest (most severe) first
    participating_priorities_in_order = sorted(index.keys())

    # Result is the same structure, but keys are severities not priorities
    return {_FEWNIVDT[i]: index[i] for i in participating_priorities_in_order}


def _enhanced_messages_via_emission(emi):

    if _is_serious[emi.severity]:
        keyishes = (emi.severity, *emi.to_channel_tail())
    else:
        keyishes = tuple(emi.to_channel_tail())

    itr = iter(emi.to_messages())
    colon_me = (*(k.replace('_', ' ') for k in keyishes), next(itr))

    yield ': '.join(colon_me)
    for msg in itr:
        yield msg


# #[#508.4] FEWNIVDT:
_FEWNIVDT = 'fatal error warn notice info verbose debug trace'.split()
_priority_via_severity = {_FEWNIVDT[i]: i for i in range(0, len(_FEWNIVDT))}
(_is_serious := {k: False for k in _FEWNIVDT}).update(fatal=True, error=True)


# ==

def _build_ellipsifier(ellipsis):
    ellipsis_length = len(ellipsis)
    assert ellipsis_length < 6  # c'mon now

    def ellipsify(line):
        orig_leng = len(line)
        if orig_leng < ellipsis_length:
            return line
        final = ''.join((line[0:-ellipsis_length], ellipsis))
        assert orig_leng == len(final)
        return final

    ellipsify.ellipsis_length = len(ellipsis)
    return ellipsify


_ellipsifier = _build_ellipsifier('[…]')


# ==

def _word_scanner_lol(msg):
    return _scanner_via_iterator(_words_via_msg_lol(msg))


def _words_via_msg_lol(msg):
    # this would loose formatting on messages with leading indent but .. don't
    return (md[0] for md in re.finditer(r'[^ ]+', msg))


def _scanner_via_iterator(itr):
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func(itr)


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
