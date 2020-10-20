"""a minimal filesystem-based cache of documents requested through HTTP,

by which (normally) only a first request for a given URL will make the
network request, and subsequent retrievals of the document use the cached
document.

why?
  - during development it's impractical (wasteful, unreliable) to do the
    same HTTP GET over and over again for the same document, because of
    all of latency, network unreliability

  - during development it's often useful to have a "physical" copy of
    the document on the file system; e.g for working it into fixture
    data, visual inspection ..

how?
  - call the entrypoint function with a tmpdir path that is assumed to
    exist and be writable. the result is a reader function (not yet
    documented) that receives (url, listener) and results in a
    filesystem path.

  - as a side-effect of each request, an emission is emitted expressing
    which of the two means was used (real GET vs. retrieval from cache).

  - the cache can be "cleared" per-resource simply by removing the file
    from the filesystem. (note the filename name as expressed in the
    emission, or simply find the file intuitively).

  - in practice we would love for this facility to be our only means of
    interfacing with the `requests` library for most purposes, to the
    extent that we might want this feature for use case of the request.

anticipated issues:

  - no collision detection check is performed to see if two different URL's
    "simplify" into the same simplified name. (it seems certainly possible).

  - hackishly we want the cached file to have any same "extension" that
    is seen in the URL (to date: ".html" and ".md"). this feels sketchy
    but maybe it's OK..

  - this is supposed to bork for URLs that have GET parameters, because
    that's a whole thing we haven't yet needed and is something that should
    probably be approached with caution on a per-use-case basis.

  - HTTP errors (e.g 404), timeouts etc are not covered and should bork.
    this facility should be seen as a dog-ear towards an upgrade path
    to a more mature solution from out in the universe, if such fanciness
    is needed.
"""

import sys


def cached_doc_via_url_via_temporary_directory(tmpdir):

    def cached_doc(url, listener):
        from modality_agnostic import emitter_via_listener as func
        emit = func(listener)

        import re
        from os import path as p

        if '?' in url:
            raise Exception("cover me: meh use some url parsing lib")

        stem, ext = p.splitext(url)
        if 0 == len(ext):
            use_url = url
            use_ext = None
        else:
            use_url = stem
            use_ext = ext  # NOTE has period included in it

        working_entry = re.sub(r'[^a-zA-Z0-9]', '_', use_url)
        if use_ext is not None:
            working_entry = '%s%s' % (working_entry, use_ext)

        path = p.join(tmpdir, working_entry)

        if p.exists(path):
            _tmpl = '(using cached web page (remove file to clear cache) - {})'
            emit('info', 'expression', 'using_cached', _tmpl, path)
            return Cached_HTTP_Document(path)
        else:
            _tmpl = '(nothing cached for this url, caching - {})'
            emit('info', 'expression', 'http_get', _tmpl, path)
            return __make_cached_doc(path, url, emit)
    return cached_doc


def __make_cached_doc(cache_path, url, emit):

    import requests

    with open(cache_path, 'w') as fh:
        r = requests.get(url)
        status_code = r.status_code
        if status_code == 200:
            x = fh.write(r.text)
            _tmpl = 'wrote {} ({} bytes)'
            emit('info', 'expression', 'wrote', _tmpl, (cache_path, x))
            ok = True
        else:
            _tmpl = 'failed - got HTTP status {} from {}'
            emit('info', 'expression', 'error', _tmpl, (status_code, url))
            ok = False
    if ok:
        return Cached_HTTP_Document(cache_path)
    else:
        import os
        os.remove(cache_path)


class Cached_HTTP_Document:
    def __init__(self, path):
        self.cache_path = path


cached_doc_via_url_via_temporary_directory.Cached_HTTP_Document = Cached_HTTP_Document  # noqa: E501


sys.modules[__name__] = cached_doc_via_url_via_temporary_directory

# #abstracted.
