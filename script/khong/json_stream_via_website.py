#!/usr/bin/env python3 -W error::Warning::0

"""generate a stream of JSON from the TOC Dr. K Hong's excellent {domain}

(this is the content-producer of the producer/consumer pair)
(the first row (line) is metadata about syncing)
"""
# #[#410.1.2] this is a producer script.


_domain = 'http://www.bogotobogo.com'
domain = _domain  # expose it
_url = _domain + '/python/pytut.php'  # ..
_my_doc_string = __doc__


class open_dictionary_stream:
    """ordinarily such a scraping script is only about half a terminal screen

    of code. throughout the document we'll explain why this particular one
    is more complicated. but as an overview:

      - we are outuputting something like compound keys
      - aspects of the page structure (and 'soup pragmatics') make it tricky
      - something about tests

    here's the thing about compound keys:

    at a purely conceptual level, we are producing a collection of "items"
    where each "item" is a named tuple-ish of name-value pairs derived from
    particular anchor (`<a>`) tags in the the page. the name value pairs are:

      - a URL
      - a label

    the URL is derived from the anchor attribute's `href` attribute. the
    label is simply be the whole body (content string) of the anchor tag.

    (maybe maybe not we will include the section ..)

    now, if we wanted purity we would output dictionaries like this (one per
    row/line/item) and we would be done. (before #history-A.1 was like this.)

        {"label": "intro to numpy", "url": "http://xx.yy.zz/qq.html"}

    but: the target (near) markdown table we are generating/editing has
    something lke a compound value for its "human key" cel. you see, we want
    this cel to be a clickable link. this clickable link will have *both* the
    above components in it (as one human key):

        {"main_cel": "[intro to numpy](http://xx.yy.zz/qq.html)"}

    although this is something of a superficical design choice, it's a
    provision that for now is easier for us to implement on the producer end
    instead of the consumer end. (that is, if our synchronizer algorithm
    could accomodate the tranformation between the above two structures,
    that's a whole addition to the API we haven't yet considered or designed.)


    ## about tests:

    the #coverpoint8 series covers this document.
    it behooves us to derive things from real world use cases;
    early abstraction
    """

    def __init__(
            self,
            html_document_path,
            listener,
            ):

        self._html_document_path = html_document_path
        self._listener = listener
        self._enter_mutex = None
        self._exit_mutex = None

    def __enter__(self):
        """(produce one metadata row then the object rows)"""

        del(self._enter_mutex)
        _rc = self.__build_this_one_runtime_context()

        yield {
            '_is_sync_meta_data': True,
            'natural_key_field_name': 'lesson',
            }

        with _rc as json_objects:
            for json_obj in json_objects:
                yield json_obj

    def __build_this_one_runtime_context(self):

        _rc = _ad_hoc_lib().OPEN_DICTIONARY_STREAM_VIA(
            url=_url,
            first_selector=None,
            second_selector=_second_selector,
            html_document_path=self._html_document_path,
            listener=self._listener,
            )
        return _rc

    def __exit__(self, *_):
        # bs4 (beautiful soup) doesn't stream. does One Big Tree. dothing to do

        del(self._exit_mutex)


def _second_selector(soup, listener):
    """
    in the purest form of using this scraper script, one doo-hah serves as
    a straightforward selector and another doo-hah takes the element from
    the first and traverses its children yielding the desired of its
    components (something of a map-reduce).

    but this KHong page throws us several curve balls in terms of its structure

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
    cont_div, = main_div.select('> div.container')
    top_div, = cont_div.select('> div.topspace')
    row_div, = top_div.select('> div.row')
    one_div, two_div = row_div.select('> div')

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

    for json_obj in o.special_doo_hah_for_two_div(two_div):
        if 'header_level' in json_obj:
            expected, yes_no = stack.pop()
            actual = json_obj['header_content']
            if expected != actual:
                _tmpl = "new section or order change? expected '%s' (had '%s')"
                cover_me(_tmpl % (expected, actual))
            do_thing = yes_no
        elif do_thing:  # counter to OCD
            seen_set.update({json_obj['lesson']})
        yield json_obj

    # then, etc while traversing the FIRST

    itr = o.special_doo_hah_for_one_div(one_div)
    hdr = next(itr)
    hdr['header_level']  # assert t's in in
    if 'Python tutorial' != hdr['header_content']:
        cover_me()

    count = 0
    for json_obj in itr:
        key = json_obj['lesson']
        if key in seen_set:
            count += 1
        else:
            cover_me('yikes - div one was not a subset')

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
        _, _, yikes_br = one_div.select('> br')  # #TODO
        _1, _2 = yikes_br.select('> *')
        _ = shear(_2, 2, 1, 'br')
        _ = one_br(_)
        _ = one_br(_)
        _ = one_br(_)
        _ = shear(_, 3, 2, 'br')
        _ = shear(_, 3, 1, 'div')
        return json_objects_via(_)

    def special_doo_hah_for_two_div(two_div):
        # (shear off unadorned divs)
        side_div, = two_div.select('> div.side_menu')
        yikes_br, = side_div.select('> *')
        two_inner, = yikes_br.select('> *')

        return json_objects_via(two_inner)

    def one_br(el):
        return shear(el, 1, 0, 'br')

    def shear(el, how_many, which_one, name):
        these = el.select('> *')
        if len(these) != how_many:
            cover_me('more than %d (%d)' % (how_many, len(these)))
        this = these[which_one]
        if name != this.name:
            cover_me("name no '%s' (%s)" % (name, this.name))
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
                if 0 is len(uni):
                    cover_me('maybe check out this strange div')
            elif s in ignore_these:
                # oops there was lots of stuff #cover-me
                pass
            else:
                cover_me("page structured changed - wasn't expecting '%s'" % s)

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

        _href = el['href']
        _label = el.text
        # the old way:
        # return {'href': _href, 'text': _label}

        _use_label = label_via_string(_label)
        _url = url_via_href(_href)
        _lesson = markdown_link_via(_use_label, _url)
        return {'lesson': _lesson}

    o = _md_lib()
    markdown_link_via = o.markdown_link_via
    url_via_href = o.url_via_href_via_domain(_domain)
    label_via_string = o.label_via_string_via_max_width(70)
    del(o)

    class o:
        pass
    setattr(o, 'special_doo_hah_for_one_div', special_doo_hah_for_one_div)
    setattr(o, 'special_doo_hah_for_two_div', special_doo_hah_for_two_div)

    return o


def _this_lazy(f):  # experiment

    def g(*a):
        return f_pointer(*a)

    def f_pointer(*a):
        import importlib
        lib = importlib.import_module('sakin_agac')
        nonlocal f_pointer
        f_pointer = getattr(lib, f.__name__)
        return f_pointer(*a)

    return g


@_this_lazy
def pop_property(o, s):
    pass


@_this_lazy
def cover_me(msg=None):
    pass


@_this_lazy
def sanity(msg=None):
    pass


def _md_lib():
    import script.markdown_document_via_json_stream as _
    return _


def _ad_hoc_lib():
    import script.json_stream_via_url_and_selector as x
    return x


if __name__ == '__main__':
    import sys as _
    _.path.insert(0, '')
    import script.json_stream_via_url_and_selector as _
    _exitstatus = _.common_CLI_for_json_stream_(
            traversal_function=open_dictionary_stream,
            doc_string=_my_doc_string,
            help_values={'domain': _domain},
            )
    exit(_exitstatus)

# #history-A.2: sunsetted file of origin
# #history-A.1
# #born: abstracted from sibling
