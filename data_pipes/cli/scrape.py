"""
quick-and-dirty visual testing of a beautiful soup scrape

do:
    curl http://example.com/some/site.html > foo.html

then:
    dp scrape foo.html SELECTOR_ONE SELECTOR_TWO SELECTOR_THREE


The first selector (a beautiful soup sieve selector) grabs the particular
element (usually a document section) you are focusing on.

The second selector (optional) defines the list-like elements you expect to
traverse over in the above section. If this selector is not provided, ..??

The third selector (optional) defines the label-like element you expect to
find in each item. This will be used to [..]. If not provided [..]

For posterity, here is the actual first thing we used it for:

    curl https://jamstack.org/generators/ > x.html
    dp scrape x.html section.cards div.generator-card \
            'a:nth-of-type(1)>div:nth-of-type(1)'

"""

# (the library module that we call, long ago that was an entrypoint script)


_doc = __doc__


IS_CHAINABLE = False


def _formals():
    yield '-h', '--help', 'this screen'
    yield '<local-html-file-on-your-hard-drive-lol>', 'lol'
    yield '<selector> [<selector> [..]]', '(see description ☝️)'


def CLI_(sin, sout, serr, argv, svcser):
    prog_name = (bash_argv := list(reversed(argv))).pop()
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    foz = func(_formals(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        return foz.write_help_into(serr, _doc)

    html_on_fs = vals.pop('local_html_file_on_your_hard_drive_lol')
    sels = vals.pop('selector')
    assert not vals

    stack = list(reversed(sels))
    first_selector = stack.pop()
    second_selector, third_selector = None, None
    if stack:
        second_selector = stack.pop()
    if stack:
        third_selector = stack.pop()
    if stack:
        leng = 3 + len(stack)
        serr.write(f"Max 3 selectors (had {leng})\n")
        serr.write(foz.invite_line)
        return 7

    def main():
        resolve_the_document_soup()
        resolve_the_first_selector()
        maybe_resolve_the_second_selector()
        maybe_resolve_the_third_selector()

    def maybe_resolve_the_third_selector():
        if not third_selector:
            return

        count, success_count, failure_count = 0, 0, 0

        for tag in self.tags:
            count += 1

            tags = tag.select(third_selector)
            leng = len(tags)

            # If we have 316 items, we don't wan to repeat the same error msg
            # 316 times. We do a relatively simple statistical analysis of the
            # number of failures to decide how much is too much failure.

            if 0 == leng:
                failure_count += 1
                serr.write(f"in item {count}, no match for '{third_selector}'\n")  # noqa: E501
                if 0 == success_count:
                    if 3 == failure_count:
                        serr.write("stopping because encountered 3 failures before any successes\n")  # noqa: E501
                        raise stop_exception()
                elif (3 * success_count) < failure_count:
                    serr.write("stoping because more than 3x as many failures as successes\n")  # noqa: E501
                    raise stop_exception()
                continue
            success_count += 1  # we will count match multiple as success

            if 1 < leng:
                serr.write(f"(item {count} matched third selector {leng} times ('{third_selector}'))\n")  # noqa: E501
                continue

            tag, = tags  # OVERWRITE PARENT TAG VARIABLE
            use_text = tag.text.strip()
            sout.write(use_text)
            sout.write('\n')

    def maybe_resolve_the_second_selector():
        if not second_selector:
            return

        tags = self.tag.select(second_selector)
        leng = len(tags)

        if 0 == leng:
            stop(f"didn't find any tags that matched '{second_selector}'")

        serr.write(f"(found {leng} tag(s) matching second selector ('{second_selector}'))\n")  # noqa: E501
        self.tags = tags

    def resolve_the_first_selector():
        tags = self.soup.select(first_selector)
        leng = len(tags)

        def nope(msg):
            serr.write(msg)
            serr.write('\n')
            return 1

        if 0 == leng:
            stop(f"didn't find any tags that matched '{first_selector}'")

        if 1 < leng:
            stop(f"expected 0 had {leng} tags matching that selector")

        serr.write(f"(found 1 tag matching first selector ('{first_selector}'))\n")  # noqa: E501
        self.tag, = tags

    def resolve_the_document_soup():
        from data_pipes.format_adapters.html.script_common import \
            soup_via_locators_ as func
        soup = func(
            url='<was some url>',
            html_document_path=html_on_fs,
            listener=listener)
        if not soup:
            raise stop()
        self.soup = soup

    self = main  # #watch-the-world-burn

    def stop(msg):
        serr.write(msg)  # meh
        serr.write('\n')
        raise stop_exception()

    class stop_exception(RuntimeError):
        pass

    mon = svcser().produce_monitor()
    listener = mon.listener
    try:
        main()
    except stop_exception:
        pass
    return mon.returncode


CLI_.__doc__ = _doc


def xx(msg=None):
    raise RuntimeError(''.join(('hello', * ((': ', msg) if msg else ()))))

# #born
