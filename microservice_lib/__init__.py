import re


def hack_print_via_listener_(listener):
    # Experimental hack: littering application code with `print` statements is
    # a didactic style familiar to everyone; the disadvantage is that it lacks
    # all the benefits of [#017.3] structured emissions. Here we hack it so
    # that the one is a layer on top of the other. The way we get structure
    # from no structure is by a hacky, hard-coded lookup of the key phrase at
    # the beginning of the message string. Again, experimental

    def print(*pcs):
        head = pcs[0]
        md = rx.match(head)
        if md is None:
            raise RuntimeError(f"easy for you my friend: {head!r}")
        key_phrase = md[1]
        sev = sev_via_key[key_phrase]
        these = [sev, 'expression']
        if 'info' == sev:
            these.append(key_phrase.replace(' ', '_'))  # whew

        def lineser():
            yield ' '.join(str(pc) for pc in pcs)

        return listener(*these, lineser)

    rx, sev_via_key = _lazy_crazy_index()

    return print


def _lazy_crazy_index():
    o = _lazy_crazy_index
    if o.x is None:
        o.x = _build_crazy_index()
    return o.x


_lazy_crazy_index.x = None


def _build_crazy_index():
    # fatal error warning info verbose debug trace :[#508.4]
    info_head_strings = 'waiting connection sending closing'.split()
    info_head_strings += ('got response', 'shutting down')
    verbose_head_strings = 'OK wahoo'.split()
    head_strings = info_head_strings + verbose_head_strings
    rxs = ''.join((r'\n?(', * _OCD_join('|', head_strings), ')', r'\b'))
    sev_via_key = {k: 'info' for k in info_head_strings}
    sev_via_key_ = {k: 'verbose' for k in verbose_head_strings}
    sev_via_key.update(sev_via_key_)
    return re.compile(rxs), sev_via_key


# == Headers

def read_headers_(conn, print):

    char = conn.recv(1)
    if 0 == len(char):
        print('closing because got zero length msg from client')
        return False, None

    result = [True, None]  # ick/meh

    for byteline in _bytelines(conn, char):
        if b'\n' == byteline:  # the all-important exit condition
            break
        line = decode_(byteline)
        md = re.match('([A-Za-z- ]+):[ ](.+)', line)
        if md is None:
            xx(f"malformed header line: {line!r}")
        n, v = md.groups()
        f = _headers.get(n, None)
        if f is None:
            xx(f"unrecognized header {n!r}")
        x = f(v)  # ..
        result[f.offset + 1] = x

    return result


def _bytelines(conn, byt):  # be careful, this doesn't check for the thing
    byts = [byt]
    while True:
        if b'\n' == byt:
            yield b''.join(byts)
            byts.clear()
        byt = conn.recv(1)
        if 0 == len(byt):
            xx("client or server closed connection mid-headers?")
        byts.append(byt)


def _header(n):
    def decorator(orig_f):
        orig_f.offset = len(_headers)
        _headers[n] = orig_f
        return None
    return decorator


_headers = {}


@_header('Content length')
def _parse_value(v):
    assert re.match(r'\d+\Z', v)  # ..
    return int(v)


def make_content_length_header_line_(leng):
    assert isinstance(leng, int)  # #[#022]
    return encode_(f'Content length: {leng}\n')


end_of_headers_header_line_ = b'\n'


# ==

def _OCD_join(sep, items):
    itr = iter(items)
    yield next(itr)
    for item in itr:
        yield sep
        yield item


def decode_(data):
    return str(data, 'utf-8')


def encode_(msg):
    return bytes(msg, 'utf-8')


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #history-B.4.2: spike from empty: shared assets btwn tcp/ip server and client
# #history-B.4.1: become empty because begin repurposing whole package
# #history-A.1: delete the entrypoint CLI file that did nothing but call us
# #born: what was once this file moved elsewhere, and took the DNA
