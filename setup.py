"""
install this with:

    pip install --editable .


(As a stowaway here, here's notes added #history-A.5:)


| this                   | needs these
|------------------------|-------------
|grep_dump_test          | (none)
|upload_bot_test         | (none)
|modality_agnostic_test  | (none)
|text_lib_test           | (none)
|microservice_lib_test   | (none)
|script_lib_test         | (none)
|tag_lyfe_test           | tatsu
|kiss_rdb_test           | enolib, toml, click
|^ google sheets (no cov)| google-api-python-client, google-auth-httplib2,
|                        | google-auth-oauthlib
|data_pipes_test         | bs4
|pho_test                | pelican


Current status (#history-C.1): Many endpoints are here.

(At #history-C.1 we deleted lengthy history explaining legacy historical points)
(At #history-A.7 we schlurped all endpoints into this one egg)

Issues/wishes:

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
            tmx-app-flow=app_flow.cli:cli_for_production
            pho=pho.cli:cli_for_production
            tmx-dot2cytoscape=pho.cli.dot2cytoscape:cli_for_production
            tmx-timestamp=pho.cli.timestamp:cli_for_production
            ''' \
            # NOTE if you take away `kst`, it's referenced in docs
            '''kst=kiss_rdb.storage_adapters.sqlite3.toolkit:cli_for_production
            kss=kiss_rdb.cli:cli_for_production
            dp=data_pipes.cli:cli_for_production
        ''')

# #history-C.1
# #history-A.7: schlurped all old endpoints into one egg
# #history-A.6
# #history-A.5
# #history-A.4
# #history-A.3
# #history-A.2
# #birth
