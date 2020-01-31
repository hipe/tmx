"""
Currently broken. See notes below.

install this with:

    pip install --editable .

NOTE about this file:

at #birth this file was created only to facilitate the creation of the
CLI entrypoint file for "kiss rdb".

(then at #history-A.2 we added an entry for the CLI for `pho`)
(Then at #history-A.3 we added a couple more.)

(At some point before #history-A.4 (probabably during the change to
"poetry") this broke; but for now our workaround is to invoke the
CLI scripts by name; which is fine for now. Part of #open [#008.13].)

ideally we will eventually know how we can have this file live in the
sub-project directory if possible.

also at #birth there is an #open [#008.13] issue :#here1, where we don't
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


setup(
        name='z_data_pipes',  # see #here1 above
        version='0.0',
        entry_points='''
            [console_scripts]
            dp-sync=data_pipes.cli.sync:cli_for_production
        ''')


setup(
        name='z_game_server',  # see #here1 above
        version='0.0',
        entry_points='''
            [console_scripts]
            DTF_game_server=game_server:cli_for_production
            DTF_game_server_adapter=game_server.cli.game_server_adapter:cli_for_production
            DTF_game_server_server=game_server.cli.game_server_server:cli_for_production
        ''')

# #history-A.4
# #history-A.3
# #history-A.2
# #birth
