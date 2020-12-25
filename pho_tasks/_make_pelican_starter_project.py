from os import mkdir as _mkdir
from os.path import join as _join, dirname as _dirname


def make_pelican_starter_project(c, path):
    _make_sure_path_not_exists_but_parent_directory_does(path)
    _make_a_bunch_of_empty_directories(path)

    # skipping Makefile for now

    src = _build_starter_dir_path()

    from shutil import copyfile

    # Copy over the config file (warnings without)
    this = 'pelicanconf.py'
    copyfile(_join(src, this), _join(path, this))

    # Copy the two pages over
    head = 'content', 'pages'
    for tail in 'my-one-page.md', 'my-other-page.md':
        this = (*head, tail)
        copyfile(_join(src, *this), _join(path, *this))


def _make_a_bunch_of_empty_directories(path):
    _mkdir(path)
    here = _join(path, 'content')
    _mkdir(here)
    _mkdir(_join(here, 'images'))  # just to avoid a warning
    _mkdir(_join(here, 'pages'))
    _mkdir(_join(path, 'output'))


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
