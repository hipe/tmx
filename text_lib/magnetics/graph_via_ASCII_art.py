"""The main challenge in parsing our ASCII graphs is parsing vertical runs

We parse our ASCII graphs (a matrix of characters (multibyte?? maybe…))
line-by-line. Each next line is context-aware of only the line above it...
"""


def func(lines):
    grid_so_far = []
    seer = _build_seer(grid_so_far)
    tokens_via_line = _produce_line_tokenizer()
    for line in lines:
        grid_so_far.append(row_so_far := [])
        for token in tokens_via_line(line):
            row_so_far.append(token)
            seer.see_token()
        seer.see_end_of_line()
    return seer.see_end_of_lines()


def _build_seer(grid_so_far):

    export, exported_functions = _build_experimental_function_exporter()

    @export
    def see_token():  # void

        # Node? go
        token = current_token()
        if 'node_label' == token.symbol_type:
            return see_node()

        # Horizontal? go
        assert 'edge' == token.symbol_type
        horizontal_run.see_next_token_which_is_edge(token)
        if token.is_horizontal:
            return  # handled by the "horizontal run" guy above

        # Now, we are one of '\', '|' '/', '^' or 'v'. #here3
        # All of these imply a semantic collaborator above. Find exactly one:

        above = find_one_collision_above()

        def desc(): return token.symbol_subtype.replace('_', ' ')
        def above_desc(): return above.symbol_subtype.replace('_', ' ')

        # If we are up arrow, there is only 1 kind of thing we can point up to
        if token.is_up_arrowhead:
            if 'node_label' != above.symbol_type:
                xx(f"{desc()} must be below node label, not {above_desc()}")

        # Now, we are one of '\', '|' '/', or 'v'.
        # All of these are identical in terms of their upward constraints:

        # Whether a vertical piece is extending a vertical run or starting
        # a new one depends on what it collided with above

        # If above is a node, this marks the beginning of a vertical assoc
        if 'node_label' == above.symbol_type:
            return vertical_runs.open_vertical_run(above, token)

        # Now, above is an edge piece
        assert 'edge' == above.symbol_type
        if above.is_horizontal:
            xx(f"Can't have {desc()} below {above_desc()}")

        # Above: '\', '|', '/', '^', 'v'
        if above.is_down_arrowhead:
            xx(f"Can't have {desc()} below {above_desc()}")

        # Above: '\', '|', '/', '^'    Us: '\', '|' '/', or 'v'    All oh-kay
        vertical_runs.add_to_existing_vertical_run(above, token)

    # See node

    def see_node():
        token = current_token()
        horizontal_run.see_next_token_which_is_node(token)

        mr.accept_node(token)

        # It's valid to see nodes on first line (unlike edge pieces)
        colls = None
        if 1 < len(grid_so_far):
            colls = find_collisions_above()  # maybe one day multiple..

        if not colls:
            return

        # Each upward collision that a node makes must be with an (in-progress)
        # edge. Each time a node collides with an edge above, it means close it
        for coll in colls:
            if 'edge' != coll.symbol_type:
                xx(f"node {token.symbol_subtype!r} "
                   f" collided with {coll.symbol_subtype!r}")

            growable = vertical_runs.close_vertical_run(coll)
            growable.append(token)
            mr.accept_vertical_transition(tuple(growable))

    # See ending of things

    @export
    def see_end_of_line():
        horizontal_run.see_end_of_line()

    @export
    def see_end_of_lines():
        if not vertical_runs.empty:
            xx("vertical runs left unclosed..")
        return mr.finish()

    # Support

    def current_token():
        return grid_so_far[-1][-1]

    # These

    mr = _MutableResult()
    vertical_runs = _VerticalRuns()
    horizontal_run = _horizontal_run(mr)
    acd = _build_above_collision_detector(grid_so_far)
    find_one_collision_above = acd.find_one_collision_above
    find_collisions_above = acd.find_collisions_above

    # Interface for the outside world

    return exported_functions()


# == Vertical Runs (Linked List)

class _VerticalRuns:

    def __init__(self):
        from modality_agnostic.magnetics.doubly_linked_list_via_nothing \
            import func
        self._DLL = func()

    def open_vertical_run(self, node, token):
        # Maintain horizontal order of the lowest piece when inserting growable
        def find():
            for iid, growable in dll.items():
                if (start := growable[-1].start) < needle:   # #here4
                    continue
                assert needle < start
                return iid
        needle, dll = node.start, self._DLL
        growable_item = [node, token]  # #here4
        if (iid := find()) is None:
            dll.append_item(growable_item)
        else:
            dll.insert_item_before_item(growable_item, iid)

    def add_to_existing_vertical_run(self, reference, new):
        iid, growable, itr = self._find(reference)

        # Assert that the growable you found by column offset is the right one
        assert id(growable[-1]) == id(reference)  # #here4

        # Assert that we aren't gonna mess up the order (growable to the right)
        next_growable = None
        for iid, next_growable in itr:
            break
        if next_growable:
            assert new.start < next_growable[-1].start

        # Finally, extend the growable
        growable.append(new)

    def close_vertical_run(self, reference):
        iid, growable, _ = self._find(reference)
        same = self._DLL.delete_item(iid)
        assert id(growable) == id(same)
        return growable

    def _find(self, reference):
        def find():
            for iid, growable in itr:
                if needle == growable[-1][0]:
                    return iid, growable
            xx("not found")
        itr = self._DLL.items()
        needle = reference.start
        iid, growable = find()
        return iid, growable, itr

    @property
    def empty(self):
        return self._DLL.head_IID is None


# == Horizontal Run (State Machine)

def _horizontal_run(mutable_result):

    export, exported_functions = _build_experimental_function_exporter()

    @export
    def see_next_token_which_is_edge(token):
        self.current_token = token
        find_transition()

    @export
    def see_next_token_which_is_node(token):
        self.current_token = token
        find_transition()

    @export
    def see_end_of_line():
        self.current_token = None
        find_transition()

    def find_transition():
        action = find()
        if action:
            action()
            return
        from_here = self.state.__name__.replace('_', ' ')
        xx(f"{from_here}, wasn't expecting this {self.current_token[2]}")

    def find():
        for cond, action in self.state():  # #[#008.2] this one popular state m
            if cond():
                return action

    # == States

    def from_beginning_of_line():
        yield if_node, accept_node_for_left_side
        yield if_vertical_edge, when_vertical_edge

    def from_vertical_edge():
        yield if_vertical_edge, do_nothing
        yield if_end_of_line, when_end_of_line_and_nothing_to_do
        yield if_node, accept_node_for_left_side

    def from_node():
        yield if_horizontal_edge, when_connecting_horizontal_edge
        yield if_vertical_edge, when_vertical_edge
        yield if_node, accept_node_for_left_side
        yield if_end_of_line, when_end_of_line_and_nothing_to_do

    def from_connecting_horizontal_edge():
        yield if_node, close_growable

    # == Actions

    def when_connecting_horizontal_edge():
        left_node = release('node_for_left_side')
        self.growable = [left_node, self.current_token]
        self.state = from_connecting_horizontal_edge

    def close_growable():
        growable = release_growable()
        growable.append(self.current_token)
        mutable_result.accept_horizontal_transition(tuple(growable))
        accept_node_for_left_side()  # 👀 🧠

    def when_vertical_edge():
        clear_any_node_for_left_side()
        self.state = from_vertical_edge

    def accept_node_for_left_side():
        self.node_for_left_side = self.current_token
        self.state = from_node

    def when_end_of_line_and_nothing_to_do():
        clear_any_node_for_left_side()
        self.state = from_beginning_of_line

    def release_growable():
        return release('growable')

    def release(attr):
        res = getattr(self, attr)
        delattr(self, attr)
        return res

    def clear_any_node_for_left_side():
        self.node_for_left_side = None  # whether there was or wasn't one
        del self.node_for_left_side

    def do_nothing():
        pass

    # == Conditionals

    def same(orig_f):
        def use_f():
            if self.current_token is None:
                return False
            return orig_f()
        return use_f

    @same
    def if_node():
        return 'node_label' == self.which

    @same
    def if_vertical_edge():
        return 'edge' == self.which and self.current_token.is_verticalesque

    @same
    def if_horizontal_edge():
        return 'edge' == self.which and self.current_token.is_horizontal

    def if_end_of_line():
        return self.current_token is None

    class state:
        @property
        def which(self):
            return self.current_token.symbol_type
        pass
    self = state()
    self.state = from_beginning_of_line

    return exported_functions()


# == Support for horizontal & vertical

class _MutableResult:

    def __init__(self):
        self._full_edges, self._nodes = [], {}

    def accept_horizontal_transition(self, tup):
        self._full_edges.append(('horizontal_edge', tup))

    def accept_vertical_transition(self, tup):
        self._full_edges.append(('vertical_edge', tup))

    def accept_node(self, token):
        label = token.surface
        if label in self._nodes:
            xx(f"collision, node label is repeated: {label!r}")
        self._nodes[label] = token

    def finish(self):
        edges = tuple(self._full_edges)
        del self._full_edges
        nodes = self._nodes
        del self._nodes
        return _FinalResult(edges, nodes)


class _FinalResult:

    def __init__(self, edges, nodes):
        self.edges, self.nodes = edges, nodes

    def to_classified_edges(self):
        for (typ, growable) in self.edges:
            yield _classified_edge(typ, growable)


class _classified_edge:
    """Mainly, loose the dimensionality: munge horizontal & vertical (mostly)

    Nodes are represented with names reflecting the order in which they
    appear in the ASCII matrix when ready line-by-line top down, left-to-right
    in each line. So instead of "top"/"bottom" and "left"/"right" we say
    "first"/"second", agnostic of dimension. Arrowheads too.

    (Client can reconstruct the dimensionality if needed (it is) by asking
    `is_horizontal`/`verticalesque`.)
    """

    def __init__(self, typ, growable):
        self.points_to_first = self.points_to_second = None
        if 'vertical_edge' == typ:
            first_node_tok, second_node_tok = growable[0], growable[-1]
            self._init_vertical(growable[1:-1])
        else:
            first_node_tok, edge_tok, second_node_tok = growable
            assert 'horizontal_edge' == typ
            self._init_horizontal(edge_tok)

        self.first_node_label = first_node_tok.surface
        self.second_node_label = second_node_tok.surface

    def _init_vertical(self, tokens):
        self.is_horizontal = False

        # If only one token, handle specially if it's '^' or 'v'
        leng = len(tokens)
        if 1 == leng:
            token, = tokens
            if token.is_arrowhead:
                if token.is_up_arrowhead:
                    self.points_to_first = True
                else:
                    assert token.is_down_arrowhead
                    self.points_to_second = True
            return

        # Otherwise (and multiple tokens) it may be '-', '<-', or '->' or '<->'
        assert 2 <= leng
        topmost_token = tokens[0]
        bottommost_token = tokens[-1]
        filler_tokens = tokens[1:-1]

        # (we quietly allow "<->" on vertical edges but not horiztonal,
        # although this is not by design… it's quite a small detail right now)

        if topmost_token.is_arrowhead:
            assert topmost_token.is_up_arrowhead
            self.points_to_first = True
        if bottommost_token.is_arrowhead:
            assert bottommost_token.is_down_arrowhead
            self.points_to_second = True

        assert not any(tok.is_arrowhead for tok in filler_tokens)
        # (discard which of '\', '|', '/' the filler bars are)

    def _init_horizontal(self, token):
        typ = token.symbol_subtype
        if 'left_arrow' == typ:
            self.points_to_first = True
        elif 'right_arrow' == typ:
            self.points_to_second = True
        else:
            assert 'horizontal_edge' == typ
        self.is_horizontal = True

    @property
    def is_verticalesque(self):
        return not self.is_horizontal


# == Collision Detection

def _build_above_collision_detector(grid_so_far):
    r"""You're seeing a backslash, pipe or stonks. They're all slight
    variations on the same kind of thing: They imply semantic projections
    on to cells *above* the current cel *and* below it.

        |*|*| |      | |*| |      | |*|*|
        | |\| |      | ||| |      | |/| |
        | |*|*|      | |*| |      |*|*| |

    If it's a pipe (i.e., totally vertical), it constitutes a continuity
    between exactly two other cells (the one above and the one below).

    Otherwise (and its one of the two slashes), there is uncertainty
    (range-itude) as to which cells they point two, but still it's a discrete
    two ranges that are pointed to, each of which must resolve to exactly
    one referent thing (and furthermore the thing must be of a set of allowed
    kinds; as far as we know the same set for all three subshapes).
    (We may or may not be strict about which kinds of things can occupy which
    of the two cells in each of the two ranges of uncertainty.)

    All three point to a particular something above *and* below them.

    We can (and must) resolve the above referent now. We must postpone
    the resolution of the referent below (and must do it later).
    """

    export, exported_functions = _build_experimental_function_exporter()

    @export
    def find_one_collision_above():
        colls = find_collisions_above()
        if 0 == len(colls):
            return _when_none(colls, current_token(), grid_so_far)
        coll, = colls
        return coll

    @export
    def find_collisions_above():
        if len(grid_so_far) < 2:
            xx("vertical-ish piece on first row, needs someting above it")
        look_at_range = range_to_look_at_in_above_row()
        above_row = grid_so_far[-2]
        colls = _detect_collision(look_at_range, above_row)
        if 1 < len(colls):
            _when_more_than_one(colls, current_token(), grid_so_far)
        return colls

    def range_to_look_at_in_above_row():
        r"""As for nodes, do we want to reach across diagonals?

        No nodes in checkerboard allowed:     Yes edges can connect to corners:
        No:                                   Yes:
               node_label_1      nod…                \            /
           …l_2            node_4                     node_label_3

        Detect the collisions in both cases, but react differently (#here5:?)
        """

        def wide_left(): return max(0, (start-1))

        token = current_token()
        start, stop = token.start, token.stop
        if 'node_label' == token.symbol_type:
            return wide_left(), stop+1  # stretch arms out

        assert 'edge' == token.symbol_type
        k = token.symbol_subtype

        # One of these 5 #here3:

        # Backslash looks up and also the cel to the left (if any)
        if 'backslash' == k:
            return wide_left(), stop

        # Pipe looks up to exactly one cel
        if 'pipe' == k:
            return start, stop

        # Stonks looks up and also the cel to the right (if any)
        if 'stonks_slash' == k:
            return start, stop+1  # spilling over to the right ok

        # Up arrow should only look directly up. (If you were to go wide,
        # the up arrow would fail when trying to make sense of why it's
        # pointing at another edge in cases like this (covered)):
        #
        #     A<--
        #     ^
        #     |

        if 'up_arrow_head' == k:
            return start, stop

        assert 'down_arrow_head' == k

        # To detect the mythic manifold arrows:
        # (not yet covered, attempted or needed)
        #
        #     \|/  and   ^
        #      v        /|\
        #
        # we want to go wide above the down arrow (only)

        return wide_left(), stop+1

    def current_token():
        return grid_so_far[-1][-1]

    return exported_functions()


def _detect_collision(look_at_range, row):
    """NOTE we expect that we may not want to be looking at plain old
    rows but rather "vertical edges in progress" or something..
    """

    return tuple(_do_detect_collision(look_at_range, row))


def _do_detect_collision(look_at_range, row):
    """There are certainly well-known algorithms for finding the intersections

    of a range with a series of ordered, non-overlapping ranges. Here's ours:
    (Reminder: perfection (b-trees) is the enemy of good)

    For every entity in the row,
      if it STARTs on or before needle START,
        if it STOPs on (sic) or before needle START, keep searching
        otherwise (and it starts on or before and stops after) yield match.
      Otherwise, if it STARTs before needle STOP, yield match
      Otherwise (and it start on or after needle stop) stop searching
    """

    needle_start, needle_stop = look_at_range

    for entity in row:
        this_start, this_stop = entity.start, entity.stop
        if this_start <= needle_start:
            if this_stop <= needle_start:
                continue
            assert needle_start < this_stop
            # This entity starts before or on needle start and stops
            # after needle start (sic). it intersects, but keep looking
            yield entity
            continue

        # This entity starts after needle start
        assert needle_start < this_start

        # If this entity starts after needle stop,
        if needle_stop <= this_start:
            break  # you're done looking, #assume-order

        # Otherwise this entity starts before needle stop, so intersects
        assert this_start < needle_stop
        yield entity


# == Line tokenizing

def _produce_line_tokenizer():
    o = _produce_line_tokenizer
    if o.x is None:
        o.x = _build_line_tokenizer()
    return o.x


_produce_line_tokenizer.x = None


def _build_line_tokenizer():

    def tokens_via_line(line):
        scn = StringScanner(line, None)
        while scn.more:
            if scn.skip(spaces):
                if scn.empty:
                    break
            start = scn.pos
            if (md := scn.match_of_scan(edge)):
                tup = md.groups()
                i = next(i for i in rang if tup[i])  # there has to be a better
                k = these[i]
                cls = token_class_via[k]
                kw = {'start': start, 'stop': scn.pos}
                if cls.surface_form_varies:
                    kw['surface'] = md[k]
                yield cls(**kw)
                continue
            if (s := scn.scan(node_label)):
                yield node_token_class(start, scn.pos, s)
                continue
            xx(f"Unrecognized line content: {scn.rest()!r}")

    token_class_via = {k: v for k, v in _build_token_classes()}
    node_token_class = token_class_via['node_label']

    from .string_scanner_via_string import \
        StringScanner, pattern_via_description_and_regex_string as o

    import re
    edge = o('edge part', r"""
           (?P<left_arrow> <-+ )
        |  (?P<right_arrow>  -+> )
        |  (?P<horizontal_edge> -+ )
        |  (?P<up_arrow_head> \^ )
        |  (?P<down_arrow_head> v )
        |  (?P<pipe> \| )
        |  (?P<stonks_slash> / )
        |  (?P<backslash> \\ )
    """, re.VERBOSE)
    these = (
        'left_arrow', 'right_arrow', 'horizontal_edge', 'up_arrow_head',
        'down_arrow_head', 'pipe', 'stonks_slash', 'backslash')
    rang = range(0, len(these))

    node_label = o('node label', '[A-Z0-9]+')  # KISS for now
    spaces = o('spaces', '[ ]+')

    return tokens_via_line


# == Define Nonterminal Symbol Properties

def _build_token_classes():
    empty_dict = {}
    for k, (base_class, defn_func) in _define_token_classes():  # #here6
        cls = type(k, (base_class,), empty_dict)
        defn_func(k, cls)
        yield k, cls


def _define_token_classes():  # EXPERIMENT: can you read it?

    # Base Bases

    from collections import namedtuple as nt

    token_with_surface_variation = nt('_T_w_SV', ('start', 'stop', 'surface'))
    token_with_surface_variation.surface_form_varies = True

    token_with_no_surface_variation = nt('_T_wo_SV', ('start', 'stop'))
    token_with_no_surface_variation.surface_form_varies = False

    # Node Label Class Stack

    class node_label(token_with_surface_variation):
        symbol_type = 'node_label'

    # Horizontal Edge Class Stack

    class horizontal_base(token_with_surface_variation):
        is_horizontal = True
        is_verticalesque = False
        symbol_type = 'edge'

    def horizontal(points_left=False, points_right=False):
        yield horizontal_base  # #here6

        def define(k, cls):
            cls.symbol_subtype = k
            cls.points_left, cls.points_right = points_left, points_right
        yield define

    # Vertical Edge Class Stack

    class vertical_base(token_with_no_surface_variation):
        is_up_arrowhead = is_down_arrowhead = is_arrowhead = False  # #default
        is_horizontal = False
        is_verticalesque = True
        symbol_type = 'edge'

    def verticalesque(** kw):
        (k, v), = kw.items()
        assert v is True
        yield vertical_base  # #here6

        def define(symbol_subtype, cls):
            cls.symbol_subtype = symbol_subtype
            modify_vertical_class[k](cls)

        yield define

    def modify_vertical_class():

        def points_up(o):
            o.is_up_arrowhead = o.is_arrowhead = True

        def points_down(o):
            o.is_down_arrowhead = o.is_arrowhead = True

        # == BEGIN nothing because #here3 done one-by-one

        def is_pipe(o):
            pass

        def positive_slope(o):
            pass

        def negative_slope(o):
            pass

        # == END

        return locals()

    modify_vertical_class = modify_vertical_class()

    yield 'node_label', (node_label, lambda k, cls: None)  # no metaprog. here
    yield 'left_arrow', horizontal(points_left=True)
    yield 'right_arrow', horizontal(points_right=True)
    yield 'horizontal_edge', horizontal()
    yield 'up_arrow_head', verticalesque(points_up=True)
    yield 'down_arrow_head', verticalesque(points_down=True)
    yield 'pipe', verticalesque(is_pipe=True)
    yield 'stonks_slash', verticalesque(positive_slope=True)
    yield 'backslash', verticalesque(negative_slope=True)


# ==

def _build_experimental_function_exporter():  # experiment

    class exported_functions:
        pass

    def export(orig_f):
        setattr(exported_functions, orig_f.__name__, staticmethod(orig_f))
        return orig_f

    return export, exported_functions


# ==

def _when_more_than_one(colls, token, grid_so_far):
    xx("amazing - we need to resolve multiple collisions")
    #                /      //
    # imagining: FOO/   or //  but yuck
    #              /      //


def _when_none(colls, token, grid_so_far):
    start, subshape = token.start, token.symbol_subtype
    lineno = len(grid_so_far)
    xx(f"{subshape!r} on line {lineno} column {start+1} needs to connect"
        "to a referent above it but connects to nothing")


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
