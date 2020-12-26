from os.path import join as _join
from os import rename as _rename


def copy_sphinx_CSS_over(c, do_base_file_too=False, make_project=None):

    # Derive the path to the pho themes directory
    from sys import modules
    here = modules[__name__].__file__
    from os.path import dirname as dn
    pho_tasks_dir = dn(here)
    mono_repo_dir = dn(pho_tasks_dir)
    pho_themes_dir = _join(mono_repo_dir, 'pho-themes')

    # Create a temporary directory, set up an initial sphinx project
    with _directory(make_project) as tmpdir_path:
        with c.cd(tmpdir_path):

            # Apply the patch
            _apply_patch(c, tmpdir_path, pho_tasks_dir)

            if make_project:
                return

            # Ask sphinx to make the website
            res = c.run('make html')
            assert res.ok

            # Move the files out of the temporary directory

            pho_THEME_dir = _join(
                    pho_themes_dir, 'for-pelican', 'alabaster-for-pelican')

            genned_html_path = _join(tmpdir_path, '_build', 'html')

            if do_base_file_too:
                _move_the_base_file(pho_THEME_dir, genned_html_path)

            _move_the_CSS_files(pho_THEME_dir, genned_html_path)


def _move_the_base_file(pho_THEME_dir, genned_html_path):
    src = _join(genned_html_path, 'index.html')
    dst = _join(pho_THEME_dir, 'templates', 'base.html')  # one-off for dev
    _rename(src, dst)


def _move_the_CSS_files(pho_THEME_dir, genned_html_path):

    # Resolve the destination directory
    dest = _join(pho_THEME_dir, 'static', 'css')

    # Move the two files you want to the destination
    head = _join(genned_html_path, '_static')
    for tail in ('basic.css', 'alabaster.css'):
        src = _join(head, tail)
        dst = _join(dest, f"sphinx-{tail}")
        _rename(src, dst)


def _apply_patch(c, tmpdir_path, pho_tasks_dir):
    patch_path = _join(
            pho_tasks_dir, 'tasks-data', 'empty-sphinx-project.diff')
    res = c.run(f'patch -p2 -i {patch_path}')
    assert res.ok


def _directory(make_project):
    if make_project:
        return _make_project_directory(make_project)

    from tempfile import TemporaryDirectory as tmpdir
    return tmpdir()


def _make_project_directory(make_project):
    from os import mkdir
    mkdir(make_project)

    from contextlib import nullcontext as func
    return func(make_project)

# #born
