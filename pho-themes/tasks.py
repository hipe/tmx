from invoke import task
from os.path import join


@task
def copy_sphinx_CSS_over(c):

    # Derive the path to the pho themes directory
    from sys import modules
    here = modules[__name__].__file__
    from os.path import dirname
    pho_themes_dir = dirname(here)

    # Create a temporary directory, set up an initial sphinx project
    from tempfile import TemporaryDirectory as tmpdir
    with tmpdir() as tmpdir_path:
        with c.cd(tmpdir_path):

            # Apply the patch
            _apply_patch(c, tmpdir_path, pho_themes_dir)

            # Ask sphinx to make the website
            res = c.run('make html')
            assert res.ok

            # Move the files out of the temporary directory
            _move_the_files(pho_themes_dir, tmpdir_path)


def _move_the_files(pho_themes_dir, tmpdir_path):

    # Resolve the destination directory
    dest = join(pho_themes_dir, 'for-pelican',
                'alabaster-for-pelican', 'static', 'css')

    # Move the two files you want to the destination
    head = join(tmpdir_path, '_build', 'html', '_static')
    from os import rename
    for tail in ('basic.css', 'alabaster.css'):
        source = join(head, tail)
        target = join(dest, f"sphinx-{tail}")
        rename(source, target)


def _apply_patch(c, tmpdir_path, pho_themes_dir):
    patch_path = join(pho_themes_dir, 'task-data', 'empty-sphinx-project.diff')
    res = c.run(f'patch -p2 -i {patch_path}')
    assert res.ok

# #born
