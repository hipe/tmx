from shutil import copyfile as _copyfile
from os import mkdir as _mkdir
from os.path import join as _join, dirname as _dirname


def make_pelican_starter_project(c, path):
    _make_sure_path_not_exists_but_parent_directory_does(path)
    _make_empty_content_tree(_join(path, 'content'))
    _mkdir(_join(path, 'output'))

    # skipping Makefile for now

    src = _build_starter_dir_path()

    # Copy over the config file (warnings without)
    this = 'pelicanconf.py'
    _copyfile(_join(src, this), _join(path, this))

    # Copy the two pages over
    head = 'content', 'pages'
    for tail in 'my-one-page.md', 'my-other-page.md':
        this = (*head, tail)
        _copyfile(_join(src, *this), _join(path, *this))


def make_pelican_intermediate_directory(c, path, author, timezone):
    assert '"' not in author  # meh

    import re
    assert re.match(r'^[A-Z]+\Z', timezone)

    _make_sure_path_not_exists_but_parent_directory_does(path)
    _make_empty_content_tree(path)  # LOOK 👀 the dir itself

    conf_path = _join(path, 'pconf.py')
    with open(conf_path, 'x') as fh:
        fh.write("# File auto-generated. We did not intend for this to be edited.\n")  # noqa: E501
        fh.write("\n")
        fh.write(f"AUTHOR = \"{author}\"\n")
        fh.write(f"TIMEZONE = '{timezone}'\n")
        fh.write('\n')
        fh.write("# File auto-generated. do not commit. see [#409.2]\n")


def _make_empty_content_tree(here):
    _mkdir(here)
    _mkdir(_join(here, 'images'))  # just to avoid a warning
    _mkdir(_join(here, 'pages'))


def _make_sure_path_not_exists_but_parent_directory_does(path):
    from os.path import isdir, exists

    if exists(path):
        return _no(f"path already exists - {path!r}")

    parent_dir = _dirname(path)
    if parent_dir == path:  # e.g. '' or '/'
        return _no(f"weird parent dir of path ({parent_dir!r} of {path!r})")
    if '' == parent_dir:
        parent_dir = '.'

    if not isdir(parent_dir):
        details = "Parent directory must exist - {parent_dir!r}"
        return _no(f"won't create more than one directory. {details}")


def _build_starter_dir_path():
    from sys import modules
    here = modules[__name__].__file__
    return _join(_dirname(here), 'tasks-data', 'pelican-starter-project')


def _no(reason):
    raise RuntimeError(reason)

# #born
