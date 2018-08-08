#!/usr/bin/env python3 -W error::Warning::0

"""description: filter the input rows by looking for hashtag-like markup in
certain of its cels.

  - <collection-identifier> is exactly as in [#415] sibling script `stream`

  - the collection's schema row must indicate the participating fields
    with a property `tag_lyfe_field_names` (a tuple of field names)

every feature of the query grammar:

  - search for rows containing the tag by expressing the tag name, eg. `#red`
  - taggings can look like name-value pairs: `#priority:urgent`
  - but taggings can be arbitrarily deep: `#priority:urgent:right-now`
  - co-join matcher-expressions with `and` or `or: `#red and #blue`
  - nest with parentheses: `#red or #blue or ( #pink and #brown )`
  - negate with `not`: `#red and not #blue`
  - example of "values" plus boolean conjuction: `#code:red or #code:pink`
  - shorthand for above: `#code in ( red pink )`
  - regex: `#full-name in /^Kim Jong-/`
  - range: `#age in 33..44` (experiment, not very useful yet because no ∞)
  - find tags of a certain name with no value-ish: `#age without value`
  - find tags of a certain name that do have a value-ish: `#urgent with value`

important usage notes:

  - the above examples do not illustrate formally one important dimension:
    the query as entered into the shell must be broken up into "shell words"
    in the correct way.

  - it is mostly intuitive, and mostly follows from our use of spaces in the
    above examples. for example `#red and #blue` must be three arguments,
    not one.

  - however, regexp expressions must be one word, even (especially when)
    they contain spaces (like `/^Kim Jong-/` above).

  - '(' and ')' must be their own "words" (tokens), so use a space after and
    before them (this is exactly as the use of parenthesis in unix `find`.)

  - so, because most shells give special expansion to parenthesis and use
    `#` as a comment marker (in certain contexts), we escape these with
    backslashes or put them in quotes when entering via our shell.
"""

"""(this description does not appear in the help screen)

.#covered-by: tag_lyfe #coverpoint1.8 (for CLI-integration-related)
.#covered-by: tag_lyfe #coverpoint1.5 (for lower-level, API-endpoint-like)
"""


def _my_parameters(o, param):

    if False:
        _ = param(
                description='hi you rhule',
                argument_arity='DOCUMENTATIVE_PSEUDO_ARGUMENT',
                )
        o['zub_zub'] = _

    import script.stream as siblib2
    siblib2.parameters_for_the_script_called_stream_(o, param)


def _the_function_called_required(self, prp, x):
    if x is None:
        self._become_not_OK()
    else:
        setattr(self, prp, x)


def _CLI(sin, sout, serr, argv):  # #testpoint

    import script.json_stream_via_url_and_selector as siblib

    listener, exitstatuser = siblib.listener_and_exitstatuser_for_CLI(serr)

    res = _query_and_collection_id_via_ARGV(sin, serr, argv, listener)
    if not res.OK:
        return res.exitstatus
    query = res.query
    coll_id = res.collection_identifier
    del(res)

    visit = siblib.JSON_object_writer_via_IO_downstream(sout)

    _ = _filtered_items_via_query_and_collection_id(query, coll_id, listener)

    for dct in _:
        visit(dct)

    return exitstatuser()


def _query_and_collection_id_via_ARGV(sin, serr, argv, listener):

    hack_after = _hack_before(argv)

    program_name, *args = argv

    rs1 = _parse_query(args, listener).execute()
    if not rs1.OK:
        return rs1
    query = rs1.query
    args_after_query = rs1.args_after_query
    del(rs1)

    rs2 = _parse_args(sin, serr, [program_name, *args_after_query])
    if not rs2.OK:
        return rs2
    coll_id = getattr(rs2.namespace, 'collection-identifier')  # #open [#601]
    del(rs2)

    if hack_after is not None:
        coll_id = hack_after(coll_id)

    return _TheseTwo(query, coll_id)


class _TheseTwo:
    def __init__(self, query, coll_id):
        self.query = query
        self.collection_identifier = coll_id
    OK = True


def _filtered_items_via_query_and_collection_id(query, coll_id, listener):  # noqa: E501 #testpoint
    import script.stream as siblib2
    with siblib2.open_dictionary_stream(coll_id, listener) as dcts:

        ks = _tag_lyfe_field_names_via(dcts, listener)
        if ks is not None:
            tf = _tallying_filter(query, ks)
            for dct in dcts:
                _yes = tf.yes_no(dct)
                if _yes:
                    yield dct

            _express_summary_at_finish_into(listener, tf)


def _hack_before(argv):
    """this is a hack to allow non-string collection identifiers to sneak in
    as a component in the ARGV.

      - non-string collection identifiers (tuples, probably) are compellingly
        convenient for testing because they free us from having to make a
        whole new file for every fixture collection.

      - we can't know where the query part of ARGV ends and the collection
        identifier part begins until we parse the ARGV as one big string.
        (this isn't true for all imaginable requirements, but we are
        pretending it is.)

      - the "grand bargain" for using our parser generator is that we parse
        the input as one big string (not a stream of tokens).
    """

    if 1 < len(argv) and not isinstance(argv[-1], str):
        mixed_collection_id = argv[-1]
        argv[-1] = 'not_a_keyword'
        do_hack = True
    else:
        do_hack = False

    if do_hack:
        def f(coll_id):
            None if coll_id == 'not_a_keyword' else sanity()
            return mixed_collection_id
        return f


def _parse_args(sin, serr, argv):
    from script_lib.magnetics import parse_stepper_via_argument_parser_index as _  # noqa: E501
    return _.SIMPLE_STEP(
            sin, serr, argv, _my_parameters,
            stdin_OK=False,  # would be a lot cooler if you did
            description=_desc,
            formatter_class=_CUSTOM_HELP_FORMATTER,
            )


class _CUSTOM_HELP_FORMATTER:

    def __init__(self, prog):
        self._YUCK_COUNTER = 0
        self._EXTRA_FELLO = _BESPOKE_HELP_ACTION()
        import argparse
        self._ = argparse.HelpFormatter(prog=prog)
        self.prog = prog

    def add_usage(self, usage, positionals, groups, prefix=None):
        help_opt, *rest = positionals
        _use_positionals = [self._EXTRA_FELLO, *rest]
        return self._.add_usage(usage, _use_positionals, groups, prefix)

    def add_arguments(self, actions):
        self._YUCK_COUNTER += 1
        num = self._YUCK_COUNTER
        if 1 == num:
            _use = [self._EXTRA_FELLO, *actions]
            self._.add_arguments(_use)
        elif 2 == num:
            None if 1 == len(actions) else sanity()
            # self._.add_arguments(actions)
        else:
            sanity('more than 2 sections?')

    def _format_args(self, action, default_metavar):
        return self._._format_args(action, default_metavar)

    def add_text(self, text):
        self._._add_item(self._MY_format_text, [text])

    def _MY_format_text(self, text):
        return text

    def start_section(self, title):
        self._.start_section(title)

    def end_section(self):
        self._.end_section()

    def format_help(self):
        return self._.format_help()


class _BESPOKE_HELP_ACTION:
    """the worst."""

    def __init__(self):
        self.choices = None
        self.default = None
        self.dest = 'qq-one'
        self.help = '(see explanation above)'
        self.nargs = None
        self.metavar = '«the query»'
        self.option_strings = None
        self.required = True
        self.type = None

    def __call__(self, parser, namespace, values, option_string):
        sanity('never')


def _express_summary_at_finish_into(listener, tf):
    def f():
        for msg in _do_express_summary(tf):
            yield msg
    listener('info', 'expression', 'summary', f)


def _do_express_summary(tf):
    """
    endeavor the enjoyable undertaking of explaining why nothing matched..
    """

    did_not_match = tf.count_of_items_that_did_not_match
    matched = tf.count_of_items_that_matched
    no_taggings = tf.count_of_items_that_did_not_have_taggings
    taggings = tf.count_of_items_that_had_taggings

    total = no_taggings + taggings

    def o(msg):  # common format, but don't assume it's a given
        return f'({msg}.)'

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
            yield o(f'{taggings} item(s) with taggings and {no_taggings} without')  # noqaz: E402
    elif 0 == did_not_match:
        yield o(f'all {total} item(s) matched')
    else:
        yield o(f'{matched} match(es) of {total} item(s) seen')


_noma = 'nothing matched'


def _tag_lyfe_field_names_via(dcts, listener):

    sync_params = next(dcts)  # ..
    tup = sync_params.tag_lyfe_field_names
    if tup is None:
        def f():
            _s_a = [x for x in sync_params.to_dictionary().keys()]
            _had = ', '.join(_s_a)
            yield f'schema row must have `tag_lyfe_field_names` (had: {_had})'
        listener('error', 'expression', 'schema_error', f)
        return
    return tuple(tup)  # ..


class _parse_query:  # #testpoint
    """
    do the hacky heavy lifting of separating out the query part of ARGV

    from the arguments that follow it.

    on success result in `query` and `args_after_query` as a struct.

    on failure result in a struct with `exitstatus`. success/failure is
    determined by the `OK` property of the resulted struct.
    """

    def __init__(self, args, listener):
        self._args = args
        self._listener = listener

    def execute(self):
        args = pop_property(self, '_args')
        self.OK = True
        if 1 == len(args):
            self.query = _THE_PASSTHRU_QUERY
            self.args_after_query = args
        else:
            self.__resolve_query(args)
            self.OK and self.__resolve_args_after_query()

        pop_property(self, '_listener')
        if not self.OK:
            self.exitstatus = _failure_exitstatus
        return self

    def __resolve_args_after_query(self):

        query_s = self.query.to_string()

        big_s = pop_property(self, '_big_string')
        big_len = len(big_s)
        short_len = len(query_s)

        if big_len < short_len:  # how could the `to_string()` be longer than
            sanity()
        elif big_len == short_len:
            args = []
        else:
            None if _NULL_BYTE == big_s[short_len] else sanity()
            _tail = big_s[(short_len + 1):]
            args = _tail.split(_NULL_BYTE)

        self.args_after_query = args

    def __resolve_query(self, args):

        # #coverpoint1.7.2 - it's strange and ugly if you pass an empty string
        if 0 == len(args):
            self.__when_about_no_query()
            return

        self._big_string = _NULL_BYTE.join(args)

        from tag_lyfe.magnetics import (
                query_via_token_stream as _,
                )
        itr = _.MAKE_CRAZY_ITERATOR_THING(self._big_string)
        next(itr)  # ingore the "model" (the AST)

        _unsani = next(itr)
        _query = _unsani.sanitize(self._listener)
        self._required('query', _query)

    def __when_about_no_query(self):
        def f():
            yield 'expecting query or <collection-identifier>'
        self._listener('error', 'expression', 'empty_query', f)
        self._become_not_OK()

    _required = _the_function_called_required

    def _become_not_OK(self):
        self.OK = False


class _THE_PASSTHRU_QUERY:  # #class-as-namespace

    def yes_no_match_via_tag_subtree(_):
        return True


class _tallying_filter:
    """implement the essential function of `filter_by`: calling a query
    against normal rows (dictionaries).

    """

    def __init__(self, query, tag_lyfe_field_names):

        from tag_lyfe.magnetics import (
                tagging_subtree_via_string as _
                )
        self._tagging_subtree_via_string = _.doc_pairs_via_string

        self.count_of_items_that_did_not_match = 0
        self.count_of_items_that_matched = 0
        self.count_of_items_that_did_not_have_taggings = 0
        self.count_of_items_that_had_taggings = 0
        self._query = query
        self._tag_lyfe_keys = tag_lyfe_field_names

    def yes_no(self, dct):

        taggings = None

        for k in self._tag_lyfe_keys:

            print('\n\n\nclean me up\n\n')
            pairs = self._tagging_subtree_via_string(dct[k])
            pairs = tuple(pairs)
            length = len(pairs)
            if 1 == length:
                cover_me('no taggings there')
            elif 1 < length:
                for i in range(0, length-1):
                    if taggings is None:
                        taggings = []
                    taggings.append(pairs[i].tagging)
            else:
                sanity()

        if taggings is None:
            self.count_of_items_that_did_not_have_taggings += 1
            taggings = _no_taggings
        else:
            self.count_of_items_that_had_taggings += 1

        yes = self._query.yes_no_match_via_tag_subtree(taggings)
        if yes:
            self.count_of_items_that_matched += 1
        else:
            self.count_of_items_that_did_not_match += 1
        return yes


_failure_exitstatus = 6
_no_taggings = ()
_NULL_BYTE = '\0'  # NULL_BYTE_


# the fact that we want these names defined module-wide ..

_is_entrypoint_file = __name__ == '__main__'

if _is_entrypoint_file:
    from json_stream_via_url_and_selector import normalize_sys_path_
    normalize_sys_path_()

from modality_agnostic import (  # noqa: E402
        cover_me,
        pop_property,
        sanity,
        )

_desc = __doc__

if _is_entrypoint_file:
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #born.
