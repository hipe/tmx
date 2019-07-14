"""
install this with:

    pip install --editable .

NOTE about this file:

at #birth this file was created only to facilitate the creation of the
CLI entrypoint file for "kiss rdb".

(then at #history-A.2 we added an entry for the CLI for `pho`)

ideally we will eventually know how we can have this file live in the
sub-project directory if possible.

also at #birth there is an #open [#867.N] issue :#here1, where we don't
know how to make it so the egg (directory) doesn't have to keep hanging
around directly inside our project directory.
"""


from setuptools import setup

setup(
        name='z_pho',  # see #here1 above
        version='0.0',
        install_requires=[
            'Click',
        ],
        entry_points='''
            [console_scripts]
            pho=pho.cli:cli_for_production
        ''')


setup(
        name='z_kiss_rdb',  # see #here1 above
        version='0.0',
        install_requires=[
            'Click',
        ],
        entry_points='''
            [console_scripts]
            kss=kiss_rdb.cli:cli_for_production
        ''')

# #history-A.2
# #birth
