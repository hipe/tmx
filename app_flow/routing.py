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

    def __init__(self, route_definitions):
        self._root_node_for_parameterless_GET_request = None
        self._route_definitions = route_definitions

    def match(self, url_tail, http_method, GET_params):
        if self._root_node_for_parameterless_GET_request is None:
            self._construct_index()
        if 'GET' != http_method:
            xx()
        if GET_params is not None:
            xx()
        return _match_url(url_tail, self._root_node_for_parameterless_GET_request)

    def _construct_index(self):
        """As soon as it's time to parse an input url (which it should be by
        now), we must at least begin to parse *every* route
        """

        ordinarys = []

        defs = self._route_definitions
        del self._route_definitions
        for tup in defs:
            if 2 == len(tup):
                string, rav = tup  # rav = route associated value
                ordinarys.append(_route_string_scanner(string, rav))
                continue
            xx()

        self._root_node_for_parameterless_GET_request = _RoutesNode(ordinarys)


def _match_url(url_tail, root_node):

    # The request url (tail) cannot be the empty string
    scn = _unsanitized_request_url_scanner(url_tail)
    if scn.empty:
        return _routing_failure("API argument error: url was empty string")

    # The request url (tail) must start with a slash (as an API requirement)
    if not scn.skip_any_slash():
        return _routing_failure("API argument error: url must start with '/'")
    had_trailing_slash = True

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
        next_node = current_node.match_request_url_entry(entry_string)

        # If you found one, keep partying
        if next_node:
            current_node = next_node
            continue

        # Stop because you didn't find one this step
        url_head = url_tail[:scn.position]
        return _routing_failure(f"404 - not found: {url_tail!r}")

    wv = current_node.match_end_of_url()
    if wv:
        return _routing_success(wv[0], had_trailing_slash)  # #here2
    return _routing_failure(f"404 - not an endpoint: {url_tail!r}")


class _routing_failure:

    def __init__(self, msg):
        self.message = msg

    OK = False


class _routing_success:

    def __init__(self, route_associated_value, had_trailing_slash):
        self.route_associated_value = route_associated_value
        self.had_trailing_slash = had_trailing_slash

    OK = True


# ==

class _RoutesNode:

    def __init__(self, hot_route_scanners_TEMP):
        rename_me = {}
        self._can_match_the_end = False
        for scn in hot_route_scanners_TEMP:
            # If the route scanner is at the end, this node can match the end
            if scn.empty:
                if self._can_match_the_end:
                    xx("ambiguous grammar: more than one identical route path")
                self._can_match_the_end = True
                self._route_value_for_matching_end = scn.ROUTE_ASSOCIATED_VALUE
                continue
            # Otherwise, in our contract, EVERY scanner in our "collar" must
            # advance by one
            literal = scn.next()
            if '{' in literal:
                xx()

            rec = rename_me.get(literal)
            if not rec:
                rec = (False, [])  # #here1
                rename_me[literal] = rec
            rec[1].append(scn)
        self._mixed_via_literal = rename_me

    def match_request_url_entry(self, entry):
        rec = self._mixed_via_literal.get(entry)
        if not rec:
            return
        is_cold, node_or_routes = rec
        if is_cold:
            return node_or_routes
        node = _RoutesNode(node_or_routes)
        self._mixed_via_literal[entry] = (True, node)  # #here1
        return node

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


class DefinitionError(RuntimeError):
    pass


# #history-C.1
# #born
