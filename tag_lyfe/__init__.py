#!/usr/bin/env python3 -W error::Warning::0


from os import path as os_path


def grammar_path_(tail):
    return os_path.join(_grammars_dir, tail)


_grammars_dir = os_path.join(os_path.dirname(__file__), 'grammars')


NULL_BYTE_ = '\0'  # (used in next block)

if __name__ == '__main__':

    import sys
    sys.path.insert(0, '')

    these = ('query', 'tags')
    serr = sys.stderr
    argv = sys.argv
    length = len(argv)

    def main():
        if 1 == length:
            return when_no_arguments()
        else:
            return when_some_arguements()

    def when_no_arguments():
        whine(f'expecting {{{these_as_str()}}} for first argument.')

    def when_some_arguements():
        which = argv[1]
        if these[0] == which:
            return when_query()
        elif these[1] == which:
            return when_tags()
        else:
            whine(f'expecting {{{these_as_str()}}} (had {which!r}).')

    def when_query():
        query_s = NULL_BYTE_.join(argv[2:])
        serr_print(f'query joined with null bytes: {query_s!r}')
        from tag_lyfe.magnetics import query_via_token_stream as _
        return _.RUMSKALLA(serr, query_s)

    def when_tags():
        if 3 == length:
            print('tags!')
            return 0
        else:
            return whine(f'expecting {these[1]} string for second argument.')

    def these_as_str():
        return '|'.join(repr(x) for x in these)

    def whine(msg):
        serr_print(msg)
        return 1

    def serr_print(msg):
        serr.write(msg)
        serr.write('\n')
        serr.flush()

    sys.exit(main())


def pop_property(self, var):
    x = getattr(self, var)
    delattr(self, var)
    return x


def cover_me(s):
    raise _PlatformException('cover me: {}'.format(s))


_PlatformException = Exception


# #born.
