#!/usr/bin/env python3 -W error::Warning::0

# #[#410.1.2] this is a producer script.


class _CLI:

    def __init__(self, *four):
        self.stdin, self.stdout, self.stderr, self.ARGV = four

    def execute(self):
        def f():
            self.exitstatus = 5
        import script_lib as _
        self._listener = _.listener_via_error_listener_and_IO(f, self.stderr)

        a = self.ARGV
        if 2 != len(a) or '-' == a[1][0]:  # meh
            o = self.stderr.write
            o(f'usage: {a[0]} https://some-k8s-site.com/docs/foo-bar/\n')
            return 5
        _, url = a

        from kiss_rdb import dictionary_dumper_as_JSON_via_output_stream
        write = dictionary_dumper_as_JSON_via_output_stream(self.stdout)

        for obj in object_stream_via_url_(None, url, self._listener):
            write(obj)


def object_stream_via_url_(cached_path, url, listener):

    if not _validate_url(url, listener):
        return

    from script_lib import CACHED_DOCUMENT_VIA_TWO as _
    doc = _(cached_path, url, 'html document', listener)
    if doc is None:
        return

    from bs4 import BeautifulSoup
    with open(doc.cache_path) as fh:
        soup = BeautifulSoup(fh, 'html.parser')

    toc, = soup.select('#docsToc')
    div, = toc.select('> div')
    items = iter(div.select('> *'))

    yield _object_via_first_anchor_tag_ONCE_ONLY(next(items), url)

    for item in items:
        name = item.name
        if 'a' == name:
            for obj in _objects_via_anchor_tag_up_top(item):
                yield obj
        else:
            assert('div' == name)
            for obj in _objects_via_div_tag(item):
                yield obj
        item


def _validate_url(url, listener):
    f = None
    if _hardcoded_single_scheme != url[0:len(_hardcoded_single_scheme)]:  # meh
        def f():
            yield f"url scheme must be {_hardcoded_single_scheme} - {url}"
    elif '/' != url[-1]:
        def f():
            yield f"url must end in a slash meh - {url}"
    if f is None:
        return True
    listener('error', 'expression', 'abnormal_url', f)


_hardcoded_single_scheme = 'https://'


def _objects_via_div_tag(div):

    yield {
            _is_header_node: True,
            _header_level: 2,  # header level 2 is the headers before tables
            _label: div['data-title'],
            }

    container, = div.select('> *')
    for a in container.select('> *'):
        name = a.name
        if 'a' == name:
            yield _object_via_anchor_tag_not_top(a)
        else:
            assert('div' == name)
            for dct in _recurse(a):
                yield dct


def _recurse(div):  # note ugly redundancy with above

    yield {
            _is_header_node: True,
            _header_level: 3,  # ..
            _label: div['data-title'],
            }

    container, = div.select('> *')
    for a in container.select('> *'):
        name = a.name
        assert('a' == name)
        yield _object_via_anchor_tag_not_top(a)


def _objects_via_anchor_tag_up_top(a):
    """wat do if anchor tag (or "item-node") at toplevel of source document?

    one thing we tried it "promoting" it so that it gets rendered as a table
    with one element. but this had a feeling of being choppy with lots of
    orphans and redundancy (because we used the same label 2x, once to label
    the table and once to label the item in the table).

    this could be addressed at the consumer level by adding special metadata
    here to signal that this is a singleton, but still there's the noise
    problem.

    so rather, we emit a composite dictionary; one that is both header and
    item-node:
    """

    yield {
            _is_header_node: True,
            _header_level: 2,  # again, a would-be table label
            _label: a['data-title'],
            _url: a['href'],  # weird for a header, but not here
            '_is_composite_node': True,
            }


def _object_via_first_anchor_tag_ONCE_ONLY(a, url):
    return {
            _is_header_node: True,
            _header_level: 1,  # header level 1 is the title of a doc page
            _label: a['data-title'],
            _url: url,  # leap of faith that page url corresponds to this item
            }


def _object_via_anchor_tag_not_top(a):
    return {
            _label: a['data-title'],
            _url: a['href'],
            }


_header_level = 'header_level'
_is_header_node = '_is_branch_node'
_label = 'label'
_url = 'url'






if __name__ == '__main__':
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
