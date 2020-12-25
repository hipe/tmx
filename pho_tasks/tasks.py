from invoke import task


@task
def copy_sphinx_CSS_over(c, do_base_file_too=False):
    from pho_tasks._copy_sphinx_CSS_over import copy_sphinx_CSS_over as func
    return func(c, do_base_file_too)


@task
def patch_pelican(c):
    from pho_tasks._patch_pelican import patch_pelican as func
    return func(c)

# #abstracted
