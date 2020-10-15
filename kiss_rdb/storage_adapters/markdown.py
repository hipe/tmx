"""experiment.."""
# #[#874.9] file is LEGACY


# (COMMON_FAR_KEY_SIMPLIFIER gone a #history-A.2)


def simplified_key_via_markdown_link_er():  # #html2markdown
    """
    my hands look like this:
        [Foo Fa 123](bloo blah)
    so hers can look like this:
        foofa123

    (transplated & simplified from its first home to here at #history-A.1)
    """

    def simplified_key_via_markdown_link(markdown_link_string):
        md = markdown_link_rx.search(markdown_link_string)
        if md is None:
            assert(False)  # failed to parse markdown link
        norm_key = normal_via_str(md.group(1))
        norm_key = norm_key.lower()  # became necessary at #history-A.4
        return simple_key_via_normal_key(norm_key)

    import re
    markdown_link_rx = re.compile(r'^\[([^]]+)\]\([^\)]*\)$')

    from kiss_rdb import normal_field_name_via_string as normal_via_str

    return simplified_key_via_markdown_link


def simple_key_via_normal_key(normal_key):
    return normal_key.replace('_', '')


def label_via_string_via_max_width(max_width):  # (Case2867DP)
    def f(s):
        use_s = s[:(max_width-1)] + '…' if max_width < len(s) else s
        # (could also be accomplished by that one regex thing maybe)
        use_s = use_s.replace('*', '\\*')
        use_s = use_s.replace('_', '\\_')
        return use_s
    return f


def url_via_href_via_domain(domain):  # (Case2867DP)
    def f(href):
        _escaped_href = href.replace(' ', '%20')
        return url_head_format.format(_escaped_href)
    url_head_format = '{}{}'.format(domain, '{}')  # or just ''.join((a,b))
    return f


def _markdown_link_via_dictionary(dct):
    return markdown_link_via(dct['label'], dct['url'])  # (Case2760DP)


def markdown_link_via(label, url):
    return f'[{label}]({url})'  # (you could get bit)..


# #history-A.4
# #history-A.3: no more executable script
# #history-A.2: no more sync-side entity-mapping
# #history-A.1: MD table generation overhaul & becomes library when gets covg
# #born.
