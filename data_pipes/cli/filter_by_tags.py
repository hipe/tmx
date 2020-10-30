def _help_lines():
    # (at #history-B.3 got rid of file-reading hack)
    from data_pipes.magnetics import entities_via_filter_by_tags as mod
    return mod.__doc__


def _formals():
    yield '-h', '--help', 'this screen'
    yield '<collection>', 'usually a filesystem path to the collection', \
          "if it's '-' we expect etc"
    yield '<query> [<query> [..]]', 'elements of your tag query'


def CLI_(sin, sout, serr, argv, rscser):
    """Filter the collection by looking for hashtag-like markup in certain
    of its cels., E.g.: "#critical" or \\( "#open" and not "#cosmetic" \\)
    """

    def main():
        parse_args()
        resolve_source_collection()
        resolve_query()
        return work()

    def work():
        funky = _build_funky(self.query)
        func = _nearby_lib().apply_function_commonly_
        return func(sout, serr, self.coll, funky, mon)

    def resolve_query():
        func = _work_module().prepare_query
        self.query = func(self.query_pieces, throwing_listener)

    def resolve_source_collection():
        func = _nearby_lib().resolve_input_collection_
        self.coll = func(sin, self.coll_path, throwing_listener)

    def parse_args():
        prog_name = (bash_argv := list(reversed(argv))).pop()
        from data_pipes.cli import formals_via_ as func
        foz = func(_formals(), lambda: prog_name)
        vals, rc = foz.terminal_parse(serr, bash_argv)
        if vals is None:
            raise stop(rc)
        if vals.get('help'):
            foz.write_help_into(serr, CLI_.__doc__)
            raise stop(0)
        self.coll_path = vals['collection']
        self.query_pieces = vals['query']

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop(6)

    mon = rscser().build_monitor()
    listener = mon.listener

    self = main  # #watch-the-world-burn

    class stop(RuntimeError):
        def __init__(self, rc=None):
            self.returncode = rc
    try:
        return main()
    except stop as exc:
        return mon.returncode if (rc := exc.returncode) is None else rc


def _build_funky(query):
    def funky(same_schema, in_ents):
        func = _work_module().entities_and_statser_via_entities_and_query
        out_ents, statser = func(in_ents, query)

        class summary:
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
