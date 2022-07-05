"""Pseudocode:

(Terms in ALL_CAPS are key concepts that should have some sort of semi-formal
definition somewhere. Not all of these terms are formally defined here.
A lot of these terms are used circularly without being formally defined.
Note that the actual names may change; but we should make such changes
eventually consistent with this documentation.)

The collection of routes is expressed by the user as an ordered, "flat"
list of ROUTE_DECLARATIONs (using a particular, formal markup and some
structured options).

Internally the collection of routes is conceived of as a TREE, where each
node is either a BRANCH node or a LEAF node (each of these being a kind of.
NODE).

The REQUEST_URL is classified by parsing it one ENTRY at a time (with a
REQUEST_URL_SCANNER, which can fail (it won't parse all strings)) starting
from the beginning of the url and the ROOT of the TREE.

Given the CURRENT_ENTRY (informally "token") from the REQUEST_URL and
CURRENT_NODE of the tree, the node can either ACCEPT or REJECT the token.

Conceptually the BRANCH can be seen internally as having a dictionary
holding the N literal entries it can match, and an ordered list of M
non-literal matchers for pattern-based matchers; where N+M adds up to
greater than zero. (That is, the branch node matches *something*. We haven't
defined yet how to match nothing explicitly, nor have we explained what we
do on the "edge case" of reading the end of the REQUEST_URL (which happens
immediately in the case of the request for the root index "/").

The CURRENT_NODE receives the CURRENT_ENTRY and results in an iterable
of zero or more of its child NODES that match the token.

The ENGINE receives this response and:
- In the case of zero matches, the token cannot be matched and the ENGINE
  probably emits a 404-type response, possibly SPLAYing the SURFACE_EXPRESSIONs
  of the child nodes.
- To achieve a case of more than one match, the "grammar" (the routes) would
  have to have some in-built ambiguity in it. TODO
- For the most common case of the token matching exactly one child node;
  it's important to know that the child node will frequently be a BRANCH itself.
  (The filesystem analog of this is that the ENTRY matched a directory,
  not a file.)

(Ignoring the ambiguity case), either we failed to match and we are done or
we resolved exactly one NODE. For the commonmost case of more tokens to parse,
let this one node be the CURRENT_NODE and repeat the above for this next token.

Precisely how we handle the end of input is experimental: Experimentally,
the CURRENT_NODE will receive the special END_OF_INPUT_TOKEN; which will
probably just be not a literal token but an event, signified by the calling
of a dedicated receiver function that takes zero arguments. Internally this
will probably be a third type of matcher, which is really just a boolean
indicating whether this BRANCH can match the END_OF_INPUT_TOKEN.

A url is parsed successfully when the CURRENT_NODE receives the
END_OF_INPUT_TOKEN and matches it, which it does by resulting in a
ROUTE_ASSOCIATED_VALUE (wrapped)
"""


import re


class matcher_via_routes:

    def __init__(self, route_definitions, PATTERN_DEFINITIONS=None):
        self._root_node_for_parameterless_GET_request = None
        self._route_definitions = route_definitions
        self._PATTERN_DEFINITIONS = PATTERN_DEFINITIONS

    def match(self, url_tail, http_method, GET_params):
        if self._root_node_for_parameterless_GET_request is None:
            self._construct_index()

        if 'GET' != http_method:
            assert 'POST' == http_method
            rn = self._root_node_for_POST_request
            if not rn:
                xx()
                return _routing_failure(f"404 - no POSTs at all: {url_tail!r}")
            return _match_url(url_tail, rn)

        if GET_params:
            return _crazy_GET_params_thing(
                url_tail, GET_params,
                self._extraordinary_offsets_via_GET_parameter_name,
                self._root_nodes_with_associated_GET_signatures,
                self._root_node_for_parameterless_GET_request)
        return _match_url(url_tail, self._root_node_for_parameterless_GET_request)

    def _construct_index(self):
        """As soon as it's time to parse an input url (which it should be by
        now), we must at least begin to parse *every* route
        """

        ordinarys = []
        extraordinaries = None
        posts = None

        defs = self._route_definitions
        del self._route_definitions
        for tup in defs:
            stack = list(reversed(tup))
            string = stack.pop()
            rav = stack.pop()  # rav = route-associated value (anything from user)
            GET_params_query = stack.pop() if stack else None
            method = stack.pop() if stack else None

            # If it's POST, do this
            if method:
                if 'POST' != method:
                    raise DefinitionError("method must be POST (default is "
                                          f"GET). Had: {method!r}")
                if GET_params_query:
                    raise DefinitionError("can't have both GET_params_query "
                                          "and POST method")
                if posts is None:
                    posts = []
                posts.append(_route_string_scanner(string, rav))
                continue

            # If it's "ordinary", do this:
            if not GET_params_query:
                ordinarys.append(_route_string_scanner(string, rav))
                continue

            # Since it's associated with a GET params query, do this:
            if extraordinaries is None:
                extraordinaries = []
                extraordinary_offset_via_GET_param_key = {}
            offset = len(extraordinaries)
            scn = _route_string_scanner(string, rav)
            extraordinaries.append((scn, GET_params_query))
            # (this will get expensive for CLI's lol)
            for k in GET_params_query.keys():
                if k not in extraordinary_offset_via_GET_param_key:
                    extraordinary_offset_via_GET_param_key[k] = []
                extraordinary_offset_via_GET_param_key[k].append(offset)

        if self._PATTERN_DEFINITIONS:
            gpf = _general_pattern_factory(self._PATTERN_DEFINITIONS)
        else:
            gpf = None

        self._root_node_for_parameterless_GET_request = \
                _RoutesNode(ordinarys, gpf)

        this = None
        if posts:
            this = _RoutesNode(posts, gpf)
        self._root_node_for_POST_request = this

        these = None
        if extraordinaries:  # see #here6
            def these():
                for scn, params_query in extraordinaries:
                    yield _RoutesNode((scn,), gpf, params_query)
            these = tuple(these())
            self._extraordinary_offsets_via_GET_parameter_name = \
                    extraordinary_offset_via_GET_param_key
        self._root_nodes_with_associated_GET_signatures = these


def _crazy_GET_params_thing(
        url_tail, GET_params, offset_via_GET_key, extraordinaries, ordinary):

    """TRICKY: when working with routes associated with specific GET
    parameter keys-and-values, as a practical heuristic simplification,
    to resolve a matching url we employ a culling pass and a straight
    selection pass; rather than walking along our usual one giant hash-table-
    based tree. Nonetheless we employ the same "routes node" class and eat
    the cost of have one tall, 1-width tree for each participating route.

    We may change this is ever we find ourselves having many routes associated
    with the same GET params signature
    """  # :#here6

    # Find all the root nodes that have parameter keys intersecting with arg
    def offsets():
        for k in GET_params.keys():
            for i in offset_via_GET_key.get(k, ()):
                yield i

    offsets = sorted({k: None for k in offsets()}.keys())
    if 3 < len(offsets):
        xx('sanity: this is getting a little crazy. profile this, see how it degrades')

    # Of those, find ones whose GET params signature matches the actual params
    def offsets_matching_GET_params():
        for i in offsets:
            yn = does_match_GET_params(extraordinaries[i])
            if yn:
                yield i

    def does_match_GET_params(root_node):
        for formal_key, formal_value in root_node.GET_parameters_signature.items():
            yn = formal_value == GET_params.get(formal_key)  # formal None is meaningless
            if not yn:
                return False
        return True

    offsets_matching_GET_params = tuple(offsets_matching_GET_params())

    # Of those routes that match the GET params, do the routing EXPENSIVELY
    OKs = []
    not_OKs = []
    for i in offsets_matching_GET_params:
        resp = _match_url(url_tail, extraordinaries[i])
        (OKs if resp.OK else not_OKs).append(resp)

    if OKs:
        if 1 < len(OKs):
            xx("ambiguous routes grammar. never been covered")
        return OKs[0]

    if not_OKs:
        xx()

    return _routing_failure(f'404 - not found: {url_tail!r} (with GET params)')


# ==

def _match_url(url_tail, root_node):

    # The request url (tail) cannot be the empty string
    scn = _unsanitized_request_url_scanner(url_tail)
    if scn.empty:
        return _routing_failure("API argument error: url was empty string")

    # The request url (tail) must start with a slash (as an API requirement)
    if not scn.skip_any_slash():
        return _routing_failure("API argument error: url must start with '/'")
    had_trailing_slash = True
    matchdatas = None

    # the core algorithm: Start at the root node
    current_node = root_node
    while True:
        # If you reached the end of the input url, break out to go match end
        if scn.empty:
            break

        # Read the next token (might be "") off input stream. & any slash
        entry_string = scn.next_entry()
        had_trailing_slash = scn.skip_any_slash()
        # (advance the scanner past the any next slash now so that subsequently
        # if we generate expressions of the url, it will include the slash if
        # it was provided, to look more "normal" #here3)

        if not had_trailing_slash:
            # (sanity check: the only way there could be no slash is at the end)
            assert scn.empty

        # Attempt to match the current token against the node matchers
        pair = current_node.match_request_url_entry(entry_string)  # #here4

        # If you found one, keep partying
        if pair:
            next_node, md_kv = pair  # md_kv = matchdata key-value pair
            if md_kv:
                assert 2 == len(md_kv)
                if matchdatas is None:
                    matchdatas = []
                matchdatas.append(md_kv)
            current_node = next_node
            continue

        # Stop because you didn't find one this step
        url_head = url_tail[:scn.position]
        return _routing_failure(f"404 - not found: {url_tail!r}")

    wv = current_node.match_end_of_url()
    if wv:
        return _routing_success(wv[0], had_trailing_slash, matchdatas)  # #here2
    return _routing_failure(f"404 - not an endpoint: {url_tail!r}")


class _routing_failure:

    def __init__(self, msg):
        self.message = msg

    OK = False


class _routing_success:  # dataclass

    def __init__(self, route_associated_value, had_trailing_slash, matchdatas):
        self.route_associated_value = route_associated_value
        self.had_trailing_slash = had_trailing_slash
        if matchdatas is None:
            self.parse_tree = None
            return
        self.parse_tree = _matchdatas_dict_via_pairs(matchdatas)

    OK = True


def _matchdatas_dict_via_pairs(matchdatas):
    """Planning for contingencies we probably won't ever encounter, given that
    our routing pattern language doesn't have "kleeny"-style operators (like
    regexes do), we know that every url that matches a given route will have
    exactly the same number of components (entries) the route has.

    For example, given this route:

        /foo/{BAR}/baz/

    all urls that match it will have exactly three components. And they will
    all have exactly one entry that corresponds to the one pattern placeholder.

    (We cannot write a pattern that "globs" multiple entires; not only is this
    a design choice, it's also a by-product of how we implemented route
    processing: forward slashes are parsed with a higher precedence than
    user-provided patterns; user-provided pattern "matchers" are only ever
    passed single entries at a time.)

    As such, we can leverage this fixed behavior to affect how we create
    "parse trees":

    Consider the contrived example:

        /member/{MEMBER_IDENTIFIER}/view-relationship-with/{MEMBER_IDENTIFIER}/

    Notice same pattern identifier (and so pattern) repeats once.
    As a sort of corollary to the axiom offered above, all urls that match
    this route will have exactly two components (entries) that correspond with
    those two placeholders in the route.

    Following the principle of least surprise, it's natural for the user
    to expect that those patterns whose placeholder only occurs once
    (the commonmost case by far) should have a component in the parse tree
    that is an ordinary, straighforward value (and not, for example, a list
    or tuple (unless the custom matcher function creates such a value for
    whatever reason)).

    Conversely, the user will expect (probably) that patterns with multiple
    occurrences in the route have a corresponding list-like component in the
    parse tree.

    As it works out, we can implement this complex-sounding "spec" here
    relatively straightforwardly, and do so lazily (at "match-time"), rather
    than needing to have some complicated pass when we parse the route.

    We need to take care that the user-provided function can result in any
    true-ish value for a matchata, and we should not assume that result is
    not list-like, so we maintain our own memory of what pattern names we've
    seen.
    """

    matchdatas_dct = {}
    field_state = {}
    for k, v in matchdatas:
        num = field_state.get(k, 1)

        # If this is the first time you've seen it, set it as a single
        # value and remember that you've seen it
        if 1 == num:
            matchdatas_dct[k] = v
            field_state[k] = 2

        # If this is the second time you've seen this, upgrade the
        # component to be a list, do the switcheroo, and remember etc
        elif 2 == num:
            matchdatas_dct[k] = [matchdatas_dct[k], v]
            field_state[k] = 3

        # If this is the third or more time you've seen this, LG
        else:
            assert 3 == num
            matchdatas_dct[k].append(v)
    return matchdatas_dct

# ==

class _RoutesNode:

    def __init__(self, hot_route_scanners, gpf, GET_params_signature=None):
        literals = {}
        matchers = None
        self._can_match_the_end = False
        for scn in hot_route_scanners:
            # If the route scanner is at the end, this node can match the end
            if scn.empty:
                if self._can_match_the_end:
                    xx("ambiguous grammar: more than one identical route path")
                self._can_match_the_end = True
                self._route_value_for_matching_end = scn.ROUTE_ASSOCIATED_VALUE
                continue
            # Otherwise, in our contract, EVERY scanner in our "collar" must
            # advance by one
            token = scn.next()

            # Determine which dictionary the scanners go in to
            if '{' in token:
                if matchers is None:
                    matchers = {}
                    self._SPECIFIC_PATTERN_FACTORY = gpf()
                dct = matchers
            else:
                dct = literals

            rec = dct.get(token)
            if not rec:
                rec = [True, []]  # #here1
                dct[token] = rec
            rec[1].append(scn)

        self._hot_or_cold_via_literal = literals
        self._hot_or_cold_via_matcher_placeholder = matchers
        self._general_pattern_factory = gpf
        self.GET_parameters_signature = GET_params_signature

    def match_request_url_entry(self, entry):
        rec = self._hot_or_cold_via_literal.get(entry)
        if rec:
            md_kv = None
        else:
            # (we considered making a separate class but probably not worth it)
            pair = self._match_using_patterns(entry)
            if not pair:
                return
            rec, md_kv = pair
        assert 2 == len(rec)
        if rec[0]:  # if it's hot, "collapse" the "superposition". all #here1
            rec[0] = None

            rec[1] = _RoutesNode(rec[1], self._general_pattern_factory)
            # recurse (pass scanners)

            rec[0] = False  # False means "is cold"
        return rec[1], md_kv  # #here4

    def _match_using_patterns(self, entry):
        if not self._hot_or_cold_via_matcher_placeholder:
            return

        for placeholder, rec in self._hot_or_cold_via_matcher_placeholder.items():
            matcher = self._SPECIFIC_PATTERN_FACTORY(placeholder)  # ..
            trueish = matcher(entry)
            if not trueish:
                continue
            return rec, (matcher.parse_tree_component_name, trueish)  # #here5

    def match_end_of_url(self):
        if self._can_match_the_end:
            return (self._route_value_for_matching_end,)  # #here2


def _unsanitized_request_url_scanner(string):

    class Request_URL_Scanner:
        def __init__(self):
            self.position = 0

        def next_entry(self):
            md = _rx_zero_or_more_not_slashes.match(string, self.position)
            self.position = md.end()
            return md[1]

        def skip_any_slash(self):
            md = _rx_slash.match(string, self.position)
            if not md:
                return
            self.position = md.end()
            return True

        @property
        def more(self):
            return self.position != length

        @property
        def empty(self):
            return self.position == length

    length = len(string)
    return Request_URL_Scanner()


def _route_string_scanner(string, rav):
    """(at #history-C.1 we rewrote this to be in our "weird" way, despite
    initially having attempted to write it the normal, class-based way.
    See commit message for justification.)
    """

    length = len(string)
    assert length
    assert '/' == string[0]

    def advance():
        if state.end_has_been_peeked:
            scn.empty = True
            del scn.peek
            return
        md = _rx_one_or_more_not_slash_then_slash.match(string, state.pos)
        if not md:
            tail = string[state.pos:]
            raise DefinitionError(f'need non-slashes followed by slash: {tail!r}')
        scn.peek = md[1]
        state.pos = md.end()
        if state.pos == length:
            state.end_has_been_peeked = True

    class RouteScanner:

        def next(self):
            res = self.peek
            advance()
            return res

        ROUTE_ASSOCIATED_VALUE = rav

    scn = RouteScanner()
    scn.empty = False
    scn.peek = None  # be careful
    state = advance  # #watch-the-world-burn
    state.pos = 1
    state.end_has_been_peeked = state.pos == length
    advance()
    return scn


_rx_one_or_more_not_slash_then_slash  = re.compile('([^/]+)/')
_rx_zero_or_more_not_slashes = re.compile('([^/]*)')
_rx_slash = re.compile('/')


# ==

def _general_pattern_factory(pattern_definitions):
    """In our frontier imagined practical use case, there will probably
    be only one pattern, and we will re-use it within several routes.

    The distinction seen here between "general" and "specific" pattern
    factories is that the specific pattern factory is built for a single
    branch node. As we write, we're discovering it may an unnecessary
    accomodation, and one that we don't utilize, but one we'll leave in
    (for now) nonetheless.

    We don't want the client to worry about caching and re-using the same
    matcher for multiple instances of the same placeholder; we do that.
    """

    def build_specific_pattern_factory():
        def build_matcher_for(placeholder):
            if placeholder not in matcher_cache:
                matcher_cache[placeholder] = _resolve_matcher(placeholder, pattern_definitions)
            return matcher_cache[placeholder]
        return build_matcher_for
    matcher_cache = {}
    return build_specific_pattern_factory


def _resolve_matcher(placeholder, pattern_definitions):
    pattern_identifier = _validate_and_strip_surface_placeholder(placeholder)
    matcher_func = pattern_definitions(pattern_identifier)
    if not matcher_func:
        raise DefinitionError(f'no: {pattern_identifier!r}')

    if isinstance(matcher_func, str):
        matcher_func = re.compile(matcher_func)

    if hasattr(matcher_func, 'match'):
        rx = matcher_func
        def matcher_func(entry):
            md = rx.match(entry)
            if not md:
                return
            return md[0]  # EXPERIMENTAL #here5
    matcher_func.parse_tree_component_name = pattern_identifier  # ick/meh
    return matcher_func


def _validate_and_strip_surface_placeholder(placeholder):
    md = re.match(r'^\{([^{}]+)\}$', placeholder)
    if not md:
        raise DefinitionError(f"Placeholder must look like '{{FOO_BAR_123}}' - {placeholder!r}")
    return md[1]


# ==

class DefinitionError(RuntimeError):
    pass


# #history-C.1
# #born
