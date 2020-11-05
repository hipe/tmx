IS_CHAINABLE = True
MUST_BE_ENDPOINT_OF_PIPELINE = False


def TERMINAL_PARSE_ARGS(serr, bash_argv):
    prog_name = bash_argv.pop()
    from data_pipes.cli import formals_via_ as func
    foz = func(_formals(), lambda: prog_name)
    vals, rc = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return None, None, rc
    return vals, foz, None  # track [#459.O]


def _help_lines():
    # (at #history-B.3 got rid of file-reading hack)
    from data_pipes.magnetics import entities_via_filter_by_tags as mod
    return mod.__doc__


def _formals():
    yield '-h', '--help', 'this screen'
    yield '<collection>', 'usually a filesystem path to the collection', \
          "if it's '-' we expect etc"
    yield '<query> [<query> [..]]', 'elements of your tag query'


def BUILD_COLLECTION_MAPPER(serr, vals, foz, rscser):
    """Filter the collection by looking for hashtag-like markup in certain
    of its cels., E.g.: "#critical" or \\( "#open" and not "#cosmetic" \\)
    """

    def main():
        parse_args()
        resolve_query()
        func = _collection_mapper_via_query(self.query)
        return func, None

    def resolve_query():
        # tired of waiting 600 ms to parse a single-tag query 100x an hour
        if 1 < len(self.query_pieces):
            return resolve_query_complexly()
        pc, = self.query_pieces
        import re
        md = re.match('#([a-z]+(?:-[a-z]+)?)$', pc)
        if not md:
            return resolve_query_complexly()
        needle_stem = md[1]

        class hacked_tester:  # #class-as-namespace
            def yes_no_match_via_tag_subtree(subtree):
                if 0 == len(subtree):  # hi.
                    return False
                for tagging in subtree:
                    if 'shallow_tagging' != tagging._type:
                        xx("easy for you my friend, deep tagging. readme")
                        # this might work just taking this phrase out
                        # because that's what head_stem means

                    if needle_stem == tagging.head_stem:
                        return True
                return False
        self.query = hacked_tester

    def resolve_query_complexly():
        func = _work_module().prepare_query
        self.query = func(self.query_pieces, throwing_listener)

    def parse_args():
        if vals.get('help'):
            foz.write_help_into(serr, BUILD_COLLECTION_MAPPER.__doc__)
            raise stop(0)
        self.query_pieces = vals.pop('query')
        if vals:
            xx('ohai')  # #todo
        assert not vals

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop(6)

    mon = rscser().produce_monitor()
    listener = mon.listener

    self = main  # #watch-the-world-burn

    class stop(RuntimeError):
        def __init__(self, rc=None):
            self.returncode = rc
    try:
        return main()
    except stop as exc:
        (rc := exc.returncode) is None and (rc := mon.returncode)
        return None, rc


def _collection_mapper_via_query(query):
    def funky(same_schema, in_ents):
        func = _work_module().entities_and_statser_via_entities_and_query
        out_ents, statser = func(in_ents, query)

        class summary:  # #class-as-namespace
            def to_lines():
                return _summarize_search_stats(statser())
        return same_schema, out_ents, lambda: summary
    return funky


def _summarize_search_stats(o):  # (Case1735)

    did_not_match = o['count_of_items_that_did_not_match']
    matched = o['count_of_items_that_matched']
    no_taggings = o['count_of_items_that_did_not_have_taggings']
    taggings = o['count_of_items_that_had_taggings']
    # --
    total = no_taggings + taggings

    _noma = 'nothing matched'

    def o(msg):  # common format, but don't assume it's a given
        return f'({msg}.)\n'

    if 0 == total:
        yield o(f'{_noma} because collection was empty')
    elif 0 == matched:
        if 0 == taggings:
            yield o(f'{_noma}')
            yield o(f'of {total} seen item(s), none had taggings')
        elif 0 == no_taggings:
            yield o(f'{_noma} of {taggings} item(s) seen (all with taggings)')
        else:
            yield o(f'{_noma}')
            yield o(f'{taggings} item(s) with taggings and {no_taggings} without')  # noqa: E501
    elif 0 == did_not_match:
        yield o(f'all {total} item(s) matched')
    else:
        yield o(f'{matched} match(es) of {total} item(s) seen')


def _work_module():
    import data_pipes.magnetics.entities_via_filter_by_tags as module
    return module


def _nearby_lib():
    import data_pipes.cli as module
    return module


def xx(msg=None):
    raise RuntimeError(''.join(('write me', *((': ', msg) if msg else ()))))

# #history-B.3
# #re-housed #abstracted
