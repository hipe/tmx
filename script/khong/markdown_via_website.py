#!/usr/bin/env python3 -W error::Warning::0

"""
generate a markdown table from the table of contents (TOC) of a web page.

broadly this has these objectives and considerations:

    - currently this is a one-off hard-coded to work for a particular
      site, but it could be abstracted into something more usable if
      any of this proves useful.

    - currently hard-coded to assist in note-taking from Dr. K Hong's
      excellent site ({domain}) by generating a markdown
      table from the TOC of his exhaustive expanse of lessons there.

    - this can assist in detecting *some* changes to the constituency
      of the lessons: if you save the output of this one-off in version
      control and run the one-off again at a later date, you can see what
      (if any) items have been added, removed, re-ordered etc since the
      last time you looked.

    - as stated, if this technique proves useful for traversing other
      large, organized didactic taxonomies, we would split this file into
      a python module (file) and a short script file and distill a small
      API for this somehow (needs real use cases; i.e "incubation").

    - consider the structure of the markdown table totally experimental.
"""

# TODO (we don't yet want these in a versionsed Pipfile because it would
# be a very weak development dependency, and we want to hold off on any
# dependencies for now..)

"""
dependencies (TODO):
    - beautifulsoup4-4.6.0
    - requests 2.18.4
"""


domain = 'http://www.bogotobogo.com'
url = domain + '/python/pytut.php'  # ..


def _execute_CLI(sin, sout, serr, argv):

    def __main():
        ok = True
        if ok: ok = __parse_arguments()
        if ok: ok = __resolve_html()
        if ok: ok = __resolve_iterator()
        if ok: ok = __use_iterator()
        return exitstatus

    def __use_iterator():

        def o(s):
            sout.write(s) ; sout.write('\n')

        o('| Lesson | Read | Emoji | Notes |')
        o('|----|:---|:---|---:|')
        for (url, name) in the_iterator:
            _escaped_url = url.replace(' ', '%20')  # for one probably erroneous guy
            _long_url = domain + _escaped_url
            _use_name = __markdownify_name(name)
            o('|[{}]({})|◻️|◻️||'.format(_use_name, _long_url))

        serr.write('done.\n')
        nonlocal exitstatus ; exitstatus = 0 ; return True

    def __markdownify_name(name):
        if max_name_width < len(name):
            short_name = name[:(max_name_width-3)] + '...'
        else:
            short_name = name
        _ = short_name.replace('*','\\*')
        _ = _.replace('_', '\\_')
        return _

    # -- scrape html

    def __resolve_iterator():
        from bs4 import BeautifulSoup
        with open(tmp_html_file) as fp:
            soup = BeautifulSoup(fp, 'html.parser')

        these = soup.find_all(* first_selector)
        ln = len(these)
        if ln is not 1:
            return _fail('needed 1 had {}: {}'.format(ln, repr(first_selector)))

        def f():
            for el in these[0].find_all('a'):
                yield (el['href'], el.text)

        nonlocal the_iterator ; the_iterator = f()
        return True

    # -- resolve html

    def __resolve_html():
        if __path_exists():
            return __use_existing_path()
        else:
            return __download_html()

    def __download_html():
        import requests
        with open(tmp_html_file, 'w') as file:
            r = requests.get(url)
            status_code = r.status_code
            if status_code is 200:
                x = file.write(r.text)
                _info('wrote {} ({} bytes)'.format(tmp_html_file, x))
                ok = True
            else:
                ok = _fail('bad status code: {}'.format(status_code))
        if not ok:
            import os
            os.remove(tmp_html_file)
        return ok

    def __use_existing_path():
        _info('(using {})'.format(tmp_html_file))
        return True

    def __path_exists():
        import os
        return os.path.exists(tmp_html_file)

    # -- parse arguments

    def __parse_arguments():
        from collections import deque
        d = deque(argv)
        nonlocal program_name ; program_name = d.popleft()
        if len(d) is 0:
            return True
        else:
            import re
            md = re.search('^--?h(?:e(:?lp?)?)?$', d[-1])
            if md is None:
                _express_usage()
                return _fail()
            else:
                return __express_help()

    def __express_help():
        io = serr
        _express_usage()
        io.write('\n')
        io.write('description:\n\n')
        _big_string = __doc__.format(domain=domain)
        import re
        _reg = re.compile('^(.*\n)', re.MULTILINE)
        _itr = _reg.finditer(_big_string)
        itr = ( __deinident(md) for md in _itr )
        next(itr)  # YIKES
        io.write(next(itr))
        next(itr)  # YIKES
        for line in itr:
            io.write(line)
        _succeeded()
        return stop

    def __deinident(md):
        import re
        line = md[1]
        md2 = re.search('^[ ]{8}(.*\n)', line)
        if md2 is None:
            return line
        else:
            return md2[1]

    def _express_usage():
        _info('usage: {}'.format(program_name))

    def _fail(msg=None):
        if msg is not None:
            _info(msg)
        return False

    def _info(msg):
        serr.write(msg)
        serr.write('\n')

    def _succeeded():
        nonlocal exitstatus ; exitstatus = 0

    the_iterator = None

    first_selector = (None, 'side_menu')
    tmp_html_file = 'tmp.html'

    max_name_width = 70

    program_name = None
    exitstatus = 1
    stop = False

    return __main()

if __name__ == '__main__':
    import sys
    exit(_execute_CLI(sys.stdin, sys.stdout, sys.stderr, sys.argv))

# #born.
