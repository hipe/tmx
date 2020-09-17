#!/usr/bin/env python3 -W default::Warning::0

import toml  # #[#867.K]
import re
from sys import stdout, stderr, argv


# (there is a known bug where if you do --help and --reverse it ignores --help)
# (we were playing with a nonstandard argument grammar but it's just a sketch)
# (note that this *does* work for its intended primary functions.)


def main():

    # consume arguments at head
    while there_are_more_arguments():
        if not the_head_argument_looks_like_an_option():
            break
        consume_option_at_head()

    # consume arguments after head
    if side_effects['run_in_the_dump_direction']:
        run_normally()
    else:
        run_alternatively()


def run_normally():

    while there_are_more_arguments():
        if the_head_argument_looks_like_an_option():
            consume_option_not_at_head()
        else:
            consume_a_name_value_pair()

    if yes_do_some_officious_thing():
        do_the_officious_thing()
    else:
        do_run_in_the_dump_direction()


def run_alternatively():

    def consume_options():
        while there_are_more_arguments():
            if not the_head_argument_looks_like_an_option():
                break
            consume_option_not_at_head()
            continue

    def whine():
        express_alternate_usage_line()
        express_invite_line()
        side_effects['exit_code'] = 3

    consume_options()

    if not there_are_more_arguments():
        serr('expecting SOMETHING')
        whine()
        return

    one_agument = arg_stream.shift()

    consume_options()

    if there_are_more_arguments():
        token = arg_stream.head_token()
        serr(f'unexpected argument: {repr(token)}')
        whine()
        return

    do_run_in_the_other_direction(the_worst(one_agument))


# == main business stuff

def do_run_in_the_dump_direction():

    dump = toml.dumps(side_effects['dict_for_dump'])

    serr('your key values, as toml:')

    if len(dump):
        stdout.write(dump)
    else:
        serr(f'(result was the empty string: {repr(dump)})')


def do_run_in_the_other_direction(big_s):
    _wat = toml.loads(big_s)

    serr('your toml, as a dictionary: ')

    stderr.write(repr(_wat))
    stderr.write('\n')


# == back to CLI parsing

def do_the_officious_thing():
    side_effects['the_officious_thing']()  # eek/meh


def yes_do_some_officious_thing():
    return side_effects['yes_do_some_officious_thing']


def consume_a_name_value_pair():

    key_token = arg_stream.shift()
    if arg_stream.is_empty():
        bork('input error: odd-number of non-option arguments')
        return

    if not name_rx.match(key_token):
        bork(f'name must be like "foo-bar". invalid name: {repr(key_token)}')
        return

    dct = side_effects['dict_for_dump']

    if key_token in dct:
        bork(f'name used multiple times: {repr(key_token)}')
        return

    value_token = arg_stream.shift()

    if '\\' in value_token:
        value_token = the_worst(value_token)

    dct[key_token] = value_token


name_rx = re.compile(r'^[a-z]+(?:-[a-z]+)*$')


def the_worst(value_token):  # do #[#867.W] again :(
    return value_token.encode('utf-8').decode('unicode_escape')


def consume_option_at_head():
    if '--reverse' == arg_stream.head_token():
        arg_stream.shift()
        side_effects['run_in_the_dump_direction'] = False

    elif head_token_matches_help_and_consume():
        plan_to_do_help()

    else:
        bork_about_not_an_option_at_head()


def consume_option_not_at_head():

    if head_token_matches_help_and_consume():
        plan_to_do_help()
    else:
        bork_about_not_an_option_at_non_head()


def bork_about_not_an_option_at_head():
    _bork_about_not_an_option('')


def bork_about_not_an_option_at_non_head():
    _bork_about_not_an_option(' here')


def _bork_about_not_an_option(tail):
    token = arg_stream.head_token()
    bork(f'not an option{tail}: {repr(token)}')


def head_token_matches_help_and_consume():
    if not re.match(r'^--?h(:?e(?:lp?)?)?$', arg_stream.head_token()):
        return False
    arg_stream.shift()
    return True


def plan_to_do_help():
    side_effects['yes_do_some_officious_thing'] = True
    side_effects['the_officious_thing'] = do_help


def the_head_argument_looks_like_an_option():
    return '-' == arg_stream.head_token()[0]


def there_are_more_arguments():
    return not arg_stream.is_empty()


# == common CLI UI stuff - lower-level, non-business


def do_help():
    serr('description: shows what a toml dump looks like for key-value pairs')
    serr('             (the --reverse option parses a big string as toml.)')
    serr('')
    express_main_usage_line()
    # rr(f'usage: {program_name()} xx..')
    serr(f'       {alternate_usage_line_tail()}')


def bork(msg):
    serr(msg)
    if side_effects['run_in_the_dump_direction']:
        express_main_usage_line()
    else:
        express_alternate_usage_line()

    express_invite_line()
    side_effects['exit_code'] = 3
    raise _StopEarly()


def express_main_usage_line():
    serr(f'usage: {program_name()} [name1 value1 [name2 value2 [..]]]')


def express_alternate_usage_line():
    serr(f'usage: {alternate_usage_line_tail()}')


def alternate_usage_line_tail():
    return f'{program_name()} --reverse SOMETHING'


def express_invite_line():
    serr(f"see '{program_name()} -h' for help.")


def program_name():
    return side_effects['program_name']


def _line_writer_for(io):
    def write(line_message):
        io.write(f'{line_message}\n')
    return write


sout = _line_writer_for(stdout)
serr = _line_writer_for(stderr)


class _ArgumentStream:

    def __init__(self, argv):
        self.cursor = 0
        self.length = len(argv)
        self.argv = argv

    def shift(self):
        res = self.head_token()
        self.cursor += 1
        return res

    def head_token(self):
        return self.argv[self.cursor]

    def is_empty(self):
        return self.cursor == self.length


class _StopEarly(Exception):
    pass


# == run

side_effects = {
        'run_in_the_dump_direction': True,
        'yes_do_some_officious_thing': False,
        'dict_for_dump': {},
        'exit_code': 0,
        }

arg_stream = _ArgumentStream(argv)

side_effects['program_name'] = arg_stream.shift()  # guaranteed

try:
    main()
except _StopEarly:
    pass

exit(side_effects['exit_code'])

# #born.
