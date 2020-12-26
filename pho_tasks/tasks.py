from invoke import task


@task
def make_pelican_starter_project(c, path):
    from pho_tasks._make_pelican_starter_project import \
            make_pelican_starter_project as func
    return func(c, path)


@task
def copy_sphinx_CSS_over(c, do_base_file_too=False, make_project=None):
    from pho_tasks._copy_sphinx_CSS_over import copy_sphinx_CSS_over as func
    return func(c, do_base_file_too, make_project)


@task
def patch_pelican(c):
    from pho_tasks._patch_pelican import patch_pelican as func
    return func(c)

# #abstracted
