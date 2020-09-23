#!/usr/bin/env python3 -W error::Warning::0

"""generate a stream of JSON from the TOC of Dr. K Hong's tutorals:
{domain}

(this is the content-producer of the producer/consumer pair)
"""
# This producer script is covered by (Case0810DP)


import soupsieve as sv


_domain = 'http://www.bogotobogo.com'
domain = _domain  # expose it
_url = _domain + '/python/pytut.php'  # ..
_my_doc_string = __doc__


def _my_CLI(sin, sout, serr, is_for_sync, rscer):
    mon = rscer().monitor
    with open_traversal_stream(mon.listener) as dcts:
        if is_for_sync:
            dcts = stream_for_sync_via_stream(dcts)
        _ps_lib().flush_JSON_stream_into(sout, serr, dcts)
    return 0 if mon.OK else 456


_use_key = 'href'  # internally (in function) which component to use for ID


stream_for_sync_is_alphabetized_by_key_for_sync = False


def stream_for_sync_via_stream(dcts):

    from kiss_rdb.storage_adapters.markdown import (
            markdown_link_via,
            url_via_href_via_domain as url_via_href,
            label_via_string_via_max_width)

    label_via_string = label_via_string_via_max_width(70)

    for dct in dcts:
        if _use_key not in dct:
            assert('header_content' in dct)
            continue
        href = dct['href']
        _use_label = label_via_string(dct['text'])
        _url = url_via_href(href)
        _lesson = markdown_link_via(_use_label, _url)
        yield (href, {'lesson': _lesson})


near_keyerer = None  # #open [#458.N] producer script shouldn't have knowledge


def open_traversal_stream(listener, html_document_path=None):
    return _ps_lib().open_dictionary_stream_via(
        url=_url,
        first_selector=None,
        second_selector=_second_selector,
        html_document_path=html_document_path,
        listener=listener)


def _second_selector(soup, listener):
    """
    The typical script like this consists of two parts: one, a selector that
    selects a single node of interest in the document, and two, a
    straightforward mapping of each immediate child element of that node
    to a label and a url. But this KHong page is not straightforward:

      - `<br>` elements are intermixed alongside `<a>` (anchor) elements.
        (ok, no problem. reduce them out.)

      - there are several sections (divs) in the page with the links of
        interest. (still, not that bad. there's that recursive function,
        and `find_all` too.)

      - of the br's, some look like `<br/>`, others look like `<br>`, making
        the parser make over-deep parse trees (thinking the latter is a
        parent element).
        (still not really a problem - vendor lib has that recursive traverser)

    but finally, the most obonoxious of all:

      - REDUNDANCY! some same-links appear in multiple locations in the
        page.


    ## the specifics of the weird structure in the page [and all pages?]:

    theres:
      - "Python Tutorial" (occurrence 1 of 2)
      - "Python Tutorial" (occurrence 2 of 2)
      - "OpenCV Image and Video Processing with Python"
      - "Machine Learning with scikit-learn"
      - "Machine learning algorithms and concepts"
      - "Artificial Neural Networks (ANN)"

    body/div#main/div.container/div.[..]/div.row/[HERE]

    HERE: the second of two divs has EVERYTHING
    the first of two divs UM
    """

    main_div, = soup.select('#main')
    cont_div, = _filter('div.container', main_div)
    top_div, = _filter('div.topspace', cont_div)
    row_div, = _filter('div.row', top_div)
    one_div, two_div = _filter('div', row_div)

    """
    thus far:
      - each above selector is unambiguously specific: it specifies a
        particular class or ID and expects exactly one element to be selected.

      - if this provision is not met at any line, an exception is raised
        because of how we've written the tuple assignments.

      - perhaps we would write this as a ghastly onelineer but then we lose
        the granularity of that debuggability.

    next:
      - we have "one div" and "two div". what we HOPE is that "two div"
        has everything that "one div" has and the reverse is false.

      - that is, in the jargon of set theory ISH, it is our HOPE that the
        items in div one are a subset of the items in div two.

      - how we will do this is traverse div two *first* and div one *second*.

      - when we traverse div two we will memo (into a native set) the memo.

      - when we traverse div one we will check our assumption, and output any
        unexpected elements.
   """

    o = _all_these_functions(listener)

    # first, populate `seen_set` while traversing the SECOND collection

    seen_set = set()
    stack = [
        ('Machine Learning with scikit-learn', False),
        ('OpenCV 3 image and video processing with Python', False),
        ('Python tutorial', True),
        ]
    do_thing = False

    for dct in o.special_doo_hah_for_two_div(two_div):
        if 'header_level' in dct:
            expected, yes_no = stack.pop()
            actual = dct['header_content']
            if expected != actual:
                _tmpl = "new section or order change? expected '%s' (had '%s')"
                xx(_tmpl % (expected, actual))
            do_thing = yes_no
        elif do_thing:  # counter to OCD
            seen_set.update({dct[_use_key]})
        yield dct

    # then, etc while traversing the FIRST

    itr = o.special_doo_hah_for_one_div(one_div)
    hdr = next(itr)
    hdr['header_level']  # assert t's in in
    if 'Python tutorial' != hdr['header_content']:
        xx()

    count = 0
    for dct in itr:
        key = dct[_use_key]
        if key in seen_set:
            count += 1
        else:
            xx('yikes - div one was not a subset')

    def f():
        yield f'(first was subset of second ({count:d} were same))'
    listener('info', 'expression', 'subset', f)


def _all_these_functions(listener):
    """
    the end product functions that come of this, we expose them in this

    way (as the result of one big function that builds them all in the same
    scope) because:

      - one day we might want to accept a listener or similar to this
        one big function. (we do.)

      - currently the functions rely on what are effectively globals.
        they will be more portable if this assumption isn't built into
        the code. it's hard to explain exactly why, but giving ourselves
        this one extra level of indent leaves that path open to us.
    """

    def special_doo_hah_for_one_div(one_div):
        # (shear off unadorned divs)
        _, _, yikes_br = _filter('br', one_div)  # #TODO
        _1, _2 = _filter('*', yikes_br.children)  # no strings
        _ = shear(_2, 2, 1, 'br')
        _ = one_br(_)
        _ = one_br(_)
        _ = one_br(_)
        _ = shear(_, 3, 2, 'br')
        _ = shear(_, 3, 1, 'div')
        return json_objects_via(_)

    def special_doo_hah_for_two_div(two_div):
        # (shear off unadorned divs)
        side_div, = _filter('div.side_menu', two_div)
        yikes_br, = _filter('*', side_div)  # no strings
        two_inner, = tuple(yikes_br.children)
        return json_objects_via(two_inner)

    def one_br(el):
        return shear(el, 1, 0, 'br')

    def shear(el, how_many, which_one, name):
        these = _filter('*', el)  # no strings
        if len(these) != how_many:
            xx('more than %d (%d)' % (how_many, len(these)))
        this = these[which_one]
        if name != this.name:
            xx("name no '%s' (%s)" % (name, this.name))
        return this

    def json_objects_via(this_div):

        count = 0
        itr = elements_recursive(this_div)
        next(itr)  # ignore the root element (it's a div, ..)
        for el in itr:
            s = el.name
            if 'br' == s:
                count += 1
            elif 'a' == s:
                _d = dictionary_via_soup_element(el)
                yield _d
            elif 'h1' == s:
                html_encoded, = el.contents
                yield {'header_level': 1, 'header_content': html_encoded}
            elif 'div' == s:
                uni = these & {*el['class']}
                if not len(uni):
                    xx('maybe check out this strange div')
            elif s in ignore_these:
                # oops there was lots of stuff #cover-me
                pass
            else:
                xx("page structured changed - wasn't expecting '%s'" % s)

        def f():
            yield f"(number of <br>'s: {count})"
        listener('info', 'expression', 'brs_count', f)

    ignore_these = {'form', 'i', 'img', 'ins', 'input', 'p', 'script'}
    these = {'skyscraper', 'bogo-paypal'}

    def elements_recursive(bs_el):
        def yes(el):
            # (you have to ask the class itself, because xxx)
            return not hasattr(el.__class__, 'zfill')
        return (el for el in bs_el.recursiveChildGenerator() if yes(el))

    def dictionary_via_soup_element(el):
        return {'href': el['href'], 'text': el.text}

    class o:
        pass
    setattr(o, 'special_doo_hah_for_one_div', special_doo_hah_for_one_div)
    setattr(o, 'special_doo_hah_for_two_div', special_doo_hah_for_two_div)

    return o


def _filter(sel, el):
    return sv.filter(sel, el)


def _ps_lib():
    import data_pipes.format_adapters.html.script_common as x
    return x


def xx(s):
    raise Exception('cover me' if s is None else f'cover me: {s}')


if __name__ == '__main__':
    formals = (('-s', '--for-sync',
                'translate to a stream suitable for use in [#447] syncing'),
               ('-h', '--help', 'this screen'))
    kwargs = {'description_valueser': lambda: {'domain': _domain}}
    import sys as o
    from script_lib.cheap_arg_parse import cheap_arg_parse as func
    exit(func(_my_CLI, o.stdin, o.stdout, o.stderr, o.argv, formals, **kwargs))


# #history-A.4: no more sync-side stream mapping - removed a ton of doc
# #history-A.3: beaut. soup changed.
# #history-A.2: sunsetted file of origin
# #history-A.1
# #born: abstracted from sibling
