class _line_stream_via_big_string:  # #testpoint
    """convert any string into a stream of "lines" (isomorphically)..

    ## objective & scope

    intended for for "consuming agents" that want to parse a "big string"
    one "line" at at time.

    in practice this is useful for implementing a parser for line-centric
    grammars. i.e, this produces a tokenizer (scanner) whose tokens are
    lines.


    ## implementation notes (and possible counter-justification)

    in ruby and perhaps python, the spirit of this could be achieved with
    a oneliner something like `big_s.split(/(?<=\n)/)`. but in the current
    stable version of python, they disallow this "zero-width regex" (even
    though it does not cause the kind of problems they are trying to prevent.
    this sounds like it's getting some attention there.)

    regardless, the iterator approach we take here is more memory efficient,
    scaling to larger strings if necessary.

    amusingly, it appears that perhaps all our work here can be achieved
    with the python oneliner

        (match[0] for match in re.finditer('[^\n]*\n|[^\n]+', big_s)

    .. which is something we didn't discover until the completion of this
    work, and something we'll explore in a near future refactoring of this
    work after we commit all this hullabaloo for posterity.


    ## theory & details

    in the unix world, lines are terminated by the the newline character
    ("\n"). but it would be trivial to extend this work to other formats
    (MS-DOS/ windows "\r\n", ancient mac "\r") if (in our language if not
    our code) we broaden the conception of this "newline character" into
    the more abstract-sounding "line terminator sequence" ("LTS").

    it's now worth considering the difference between "separator semantics"
    and "terminator semantics"; a distinction discussed in the manpage for
    `git-log` near those terms. the question basically amounts to whether
    the last line (of a file, e.g) should itself end with the LTS or not.

    fortunately there's a strong convention, as is suggested by the manpage
    for the unix utility `wc`:

      > A line is defined as a string of characters delimited by a <newline> character

    this is to say, it appears that terminator (not separator) semantics
    are considered the norm.

    however, if we were to omit into oblivion any one-or-more non-LTS
    characters that trail the "big string" of input (as `wc` does), this
    would very likely effect unexpected behavior, with users wondering
    where the rest of their string went.

    as such, the subject does not act as a "normalizer" in this regard -
    it's garbage-in, garbage-out if you like. if your "big string"'s final
    "line" does *not* have an LTS, this "line" will still come back out as-
    is (i.e without an LTS). (tests cover this).
    """

    def __init__(self, big_s):
        if len(big_s) is 0:
            self._next = '_close_and_stop_iteration'
        else:
            import re
            self._iter = re.finditer('[^\n]*\n|[^\n]+', big_s)  # NEWLINE
            self.__big_string_length = len(big_s)
            self._next = '_main'

        self.__life_is_easier_if_you_only_need_to_iterate_once = None

    def __iter__(self):
        del self.__life_is_easier_if_you_only_need_to_iterate_once
        return self

    def __next__(self):
        return getattr(self.__class__, self._next)(self)

    def _main(self):
        # assume you have a nonempty iter

        match = next(self._iter)
        _end = match.span()[1]

        if _end is self.__big_string_length:
            del self._iter
            self._next = '_close_and_stop_iteration'
        return match[0]

    def _close_and_stop_iteration(self):
        del self._next
        raise StopIteration

# born.
