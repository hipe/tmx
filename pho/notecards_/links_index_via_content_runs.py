"""
You can't know whether any given reference-style-link (RSL) needs a rename
until you've seen its definition (you need to compare all three components
(name, url and any title) to a document-global index) and you can't be sure
you've seen all definitions in the notecard until you're done with the last
line of the body. So you have to chunk your output stream at least at the
body-by-body level.

However, you don't need to see every notecard in the document before you can
rewrite the RSL identifiers: you can do it in a "rolling" manner,
notecard-by-notecard.
"""


import re as _re


def these_two():
    return _sections_w_reprovisioned_RSLs, _RSL_Definition_Index()


def _sections_w_reprovisioned_RSLs(rsl_def_index, special_itr):

    # Traverse the whole body before you do name replacements
    sections_future = next(special_itr)
    itr = _each_RSL_definition(special_itr)
    dct = {k: v for k, v in _traverse_body(rsl_def_index, itr)}

    # Now that we have traversed the body looking for defs, do replacements
    do = _build_replacer(dct)
    for header_sx, content_runs in sections_future():
        use_crs = content_runs and tuple(do(cr) for cr in content_runs)
        yield header_sx, use_crs


# == Build Replacer

def _build_replacer(new_name_via_old_name):
    def do(sx):
        typ, value = sx  # ..
        if _do_skip_replace[typ]:
            return sx
        new_value = tuple(replace_line(line) for line in value)
        return 'content_run', new_value
    replace_line = _build_line_replacer(new_name_via_old_name)
    return do


_do_skip_replace = {
    'content_run': False, 'blank_line_run': True, 'code_fence_run': True}


def _build_line_replacer(new_name_via_old_name):

    def func(line):
        return ''.join(pieces(line))

    def pieces(line):
        #  this would false match on "`[xx][yy]`" (backticks) #open [#882.F]
        cursor = 0
        for md in _RSL_rx.finditer(line):
            (match_begin, match_end), (name_begin, name_end) = md.regs
            yield line[cursor:name_begin]
            old_key = line[name_begin:name_end]
            new_name = new_name_via_old_name.get(old_key)
            if new_name is None:
                xx(f"RSL identifier used but not defined: {old_key!r} {line!r}")  # noqa: E501
            yield new_name
            yield line[name_end:match_end]  # always just ']'
            cursor = match_end
        leng = len(line)
        assert cursor < leng  # because newline
        yield line[cursor:leng]

    return func


_inside = r'''
    (?: [^\\\[\]]          # a char that is neither a backslash nor a bracket
        |                  # or
        (?: \\ [\[\]] )    # a backslash then a bracket
    )+                     # one or more of these
    '''

_RSL_rx = _re.compile(''.join((
    r'\[',  # a literal open bracket
    _inside,
    r'\]\[',  # a literal close brackent then open
    '(?P<RSL_identifier>', _inside, ')',
    r'\]',  # a literal close bracket
)), _re.VERBOSE)


# == Traverse Body

def _traverse_body(rsl_def_index, itr):
    # Traverse the whole body looking for defs before you do name replacements
    # At each def, decide whether you can use the current name name or not

    seen = set()
    for rsld in itr:

        # If we encounter multiple defs for same name *in one body*, idk
        old_key = rsld.link_identifier
        if old_key in seen:
            xx("cover me: multiple RSL defs in body for {old_key!r}")
        seen.add(old_key)

        # Did we already define an RSL with this same url?
        existing = rsl_def_index.any_def_via_url(rsld.link_url)
        if existing:
            exi_title = existing.unencoded_title
            this_title = rsld.unencoded_title
            if exi_title != this_title:
                xx("might be nice to fail here, insisting titles are same")

            # Then it's fungible. When you see old key, instead use exisiting
            yield old_key, existing.link_identifier

        # Otherwise, did we already define an RSL with this identifier?
        elif (existing := rsl_def_index.any_def_via_identifier(old_key)):

            # Auto-increment to find a different identifier
            md = _re.match(r'(.*[^0-9])?([0-9]+)?\Z', old_key)
            head, int_s = md.groups()  # should only fail on empty string
            num = 2 if int_s is None else int(int_s) + 1
            if head is None:
                head = ''
            while True:
                new_key = ''.join((head, str(num)))
                if rsl_def_index.any_def_via_identifier(new_key) is None:
                    break
                num += 1
            rsld = rsld.replace_identifier(new_key)
            rsl_def_index.add_definition(rsld)
            yield old_key, new_key

        # Otherwise (and no RSL def exists with this name yet)
        else:
            rsl_def_index.add_definition(rsld)
            yield old_key, old_key


# == RSL Definition Index

class _RSL_Definition_Index:

    def __init__(self):
        self._identifier_via_url = {}
        self._def_via_identifier = {}

    def add_definition(self, rsld):
        key = rsld.link_identifier
        url = rsld.link_url

        assert url not in self._identifier_via_url
        assert key not in self._def_via_identifier

        self._identifier_via_url[url] = key
        self._def_via_identifier[key] = rsld

    def any_def_via_url(self, url):
        if (key := self._identifier_via_url.get(url)):
            return self._def_via_identifier[key]

    def any_def_via_identifier(self, key):
        return self._def_via_identifier.get(key)

    def finish(self):
        del self._identifier_via_url
        res = self._def_via_identifier
        del self._def_via_identifier
        return res


# == Each RSL Definition

def _each_RSL_definition(rsl_def_runs):

    # See every definition. Munge different runs together because no matter
    for rsl_def_run in rsl_def_runs:
        typ, mds = rsl_def_run
        assert 'link_definition_run' == typ
        for md in mds:
            kw = {k: md[k] for k in _RSL_def_rx_keys}
            yield _RSL_definition_via_matchdata_as_dictionary(kw)


def _RSL_definition_via_matchdata_as_dictionary(kw):
    dqi = kw.pop('double_quoted_insides')
    sqi = kw.pop('single_quoted_insides')
    pi = kw.pop('parenthesized_insides')

    sig = tuple((x is not None) for x in (dqi, sqi, pi))
    kw['quote_type'] = _quote_type_via_signature[sig]
    kw['encoded_quoted_value'] = dqi or sqi or pi
    return _RSL_definition_via_keywords(**kw)


_quote_type_via_signature = {
    (False, False, False): 'no_title',
    (True, False, False): 'double',
    (False, True, False): 'single',
    (False, False, True): 'paren'
}


def _RSL_definition_via_keywords(
        margin, link_identifier, second_whitespace, link_url,
        third_whitespace, quote_type, encoded_quoted_value):
    use = _unencoded_title(quote_type, encoded_quoted_value)
    return _RSL_Definition(
            margin, link_identifier, second_whitespace, link_url,
            third_whitespace, quote_type, encoded_quoted_value, use)


class _RSL_Definition:
    # maintain cosmetic whitespace but allow `_replace`

    def __init__(
            self, margin, link_identifier, second_whitespace, link_url,
            third_whitespace, quote_type,
            encoded_quoted_value, unencoded_title):

        self._margin, self.link_identifier = margin, link_identifier
        self._second_whitespace, self.link_url = second_whitespace, link_url
        self._third_whitespace, self._quote_type = third_whitespace, quote_type
        self._encoded_quoted_value = encoded_quoted_value
        self.unencoded_title = unencoded_title

    def replace_identifier(self, use):
        return self.__class__(
                self._margin, use, self._second_whitespace, self.link_url,
                self._third_whitespace, self._quote_type,
                self._encoded_quoted_value, self.unencoded_title)

    def to_line(self):
        return ''.join(s for row in self._to_line_pieces() for s in row)

    def _to_line_pieces(o):
        yield o._margin, '[', o.link_identifier, ']:'
        yield o._second_whitespace, o.link_url
        if o._third_whitespace:
            yield o._third_whitespace
        typ = o._quote_type
        if 'no_title' != typ:
            if 'double' == typ:
                left, right = '"', '"'
            elif 'single' == typ:
                left, right = "'", "'"
            else:
                assert 'parens' == typ
                left, right = '(', ')'
            yield left, o._encoded_quoted_value, right
        yield '\n'


def _unencoded_title(quote_type, encoded_quoted_value):
    if 'no_title' == quote_type:
        return

    if 'double' == quote_type:
        if _re.search(r'[\\"]', encoded_quoted_value):
            # (if it has a backslash OR a double quote anywhere)
            xx('have fun. easy. cover it')
        return encoded_quoted_value

    if 'single' == quote_type:
        if _re.search(r"[\\']", encoded_quoted_value):
            # (if it has a backslash OR a single quote anywhere)
            xx('have fun. easy. cover it')
        return encoded_quoted_value

    assert 'paren' == quote_type
    return encoded_quoted_value


_RSL_def_rx_keys = tuple((  # #testpoint
        'margin link_identifier second_whitespace link_url third_whitespace '
        ' double_quoted_insides single_quoted_insides parenthesized_insides'
).split())


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-B.4: blind rewrite
# #abstracted.
