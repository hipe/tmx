"""
install this with:

    pip install --editable .


(As a stowaway here, here's notes added #history-A.5:)


| this                   | needs these
|------------------------|-------------
|game_server_test        | (none)
|grep_dump_test          | (none)
|upload_bot_test         | (none)
|modality_agnostic_test  | (none)
|script_lib_test         | (none)
|tag_lyfe_test           | tatsu
|kiss_rdb_test           | toml, enolib, click
|^ google sheets         | google-api-python-client, google-auth-httplib2,
|                        | google-auth-oauthlib
|data_pipes_test         | soupsieve, bs4
|sakin_agac_test         | (none)
|pho_test                | (none)



Current status (#history-A.6):

The objective is only to get the pho endpoint installed (which we achieve).

Some time between now and before the changeover to poetry, things changed such
this setupfile "broke" because it specifies multiple egg (names). This might
be a blessing in disguise because it fortells the need for one of these files
fore each sub-project.

We would like to know how to make uninstallers, if that's a thing.



Historical notes:

At #birth this file was created only to facilitate the creation of the
CLI entrypoint file for "kiss rdb"

At #history-A.2 we added an entry for the CLI for `pho`

At #history-A.3 we added a couple more

At #history-A.4 this stopped working, probably coinciding with the change
to "poetry", but the workaround was to invoke the CLI scripts by name;
which is fine for now. Part of #open [#008.13]

At #history-A.5 we reinstated pip/virtualenv over poetry

Ideally we will eventually know how we can have this file live in the
sub-project directory if possible

Also at #birth there is an #open [#008.13] issue :#here1, where we don't
know how to make it so the egg (directory) doesn't have to keep hanging
around directly inside our project directory
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
            tmx-dot2cytoscape=pho.cli.dot2cytoscape:cli_for_production
            tmx-timestamp=pho.cli.timestamp:cli_for_production
            kss=kiss_rdb.cli:cli_for_production
            dp=data_pipes.cli:cli_for_production
        ''')

# #history-A.7: schlurped all old endpoints into one egg
# #history-A.6
# #history-A.5
# #history-A.4
# #history-A.3
# #history-A.2
# #birth
