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
        self._root_node = None
        self._route_definitions = route_definitions

    def match(self, url_tail, http_method, GET_params):
        if self._root_node is None:
            rd = self._route_definitions
            del self._route_definitions
            self._root_node = _build_lazy_root_node(rd)
        pass


def _build_lazy_root_node(route_definitions):
    """As soon as it's time to parse an input url (which it should be by now),
    we're gonna want *every* route to be under a scanner (because we won't
    know if we need the route for the current url unless we at least ²
    """

    xx()


class _RoutesNode:

    def match_request_url_entry(self, entry):
        xx()

    def match_end_of_url(self):
        xx()


def _request_url_scanner(url_tail, http_method, GET_params=None):
    xx()
    more
    peek
    advance()


class _route_string_scanner:

    def __init__(self, string):
        self._len = len(string)
        assert self._len
        assert '/' == string[0]
        if 1 == self._len:
            self.more = False
            return
        self.more = True
        self._pos = 1
        self._string = string
        self._end_has_been_peeked = False
        self._advance()

    def next(self):
        res = self.peek
        self._advance()
        return res

    def _advance(self):
        if self._end_has_been_peeked:
            del self.peek
            del self._end_has_been_peeked
            del self._pos
            del self._len
            del self._string
            self.more = False
            return
        md = _rx_one_or_more_not_slash_then_slash.match(self._string, self._pos)
        if not md:
            xx()
        end = md.end()
        if end == self._len:
            self._end_has_been_peeked = True
        self.peek = md[1]


_rx_one_or_more_not_slash_then_slash  = re.compile(r'([^/]+)/')


# #born
