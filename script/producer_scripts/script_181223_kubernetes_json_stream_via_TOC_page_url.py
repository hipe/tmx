#!/usr/bin/env python3 -W error::Warning::0


raise Exception("#not-covered - comment out if you're feelng lucky")

"""A sort of producer script sourced from kubernetes documentation.

At birth this scraped a url like:

{eg_url}

, turning it ☝️  into an entity stream presumably for use in generating
a punchlist somehow.
"""

_doc = __doc__

_example_url = 'https://kubernetes.io/docs/concepts/'


# (worked "visually" (mostly) at #history-A.2)


def _CLI(stdin, stdout, stderr, argv):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
        CLI_function=_do_CLI,
        stdin=stdin, stdout=stdout, stderr=stderr, argv=argv,
        formal_parameters=(
            ('url', 'example: https://some-k8s-site.com/docs/foo-bar/'),
            ),
        description_template_valueser=lambda: {'eg_url': _example_url})


def _do_CLI(monitor, stdin, stdout, stderr, url):

    from kiss_rdb import dictionary_dumper_as_JSON_via_output_stream
    write = dictionary_dumper_as_JSON_via_output_stream(stdout)

    for obj in object_stream_via_url_(None, url, monitor.listener):
        write(obj)

    stdout.write('\n')
    return _exitstatus_for_success


_do_CLI.__doc__ = _doc


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

    div, = _filter('div', toc)

    items = _direct_children(div)

    itr = iter(items)  # be explicit

    yield _object_via_first_anchor_tag_ONCE_ONLY(next(itr), url)

    for item in itr:
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

    container, = _direct_children(div)
    for a in _direct_children(container):
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

    container, = _direct_children(div)
    for a in _direct_children(container):
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


def _direct_children(node):  # #cp
    return _filter('*', node)  # omit strings


def _filter(sel, el):
    import soupsieve as sv
    return sv.filter(sel, el)


_header_level = 'header_level'
_is_header_node = '_is_branch_node'
_label = 'label'
_url = 'url'


_exitstatus_for_success = 0


if __name__ == '__main__':
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #history-A.2
# #history-A.1
# #born.
