# the 'upload' bot

## objective & scope:

when someone uploads a file to any channel, give them the option of
deleting the file off slack's storage and instead uploading it to an
s3 instance.

(a more detailed user story will be provided.)




## what we did:

what we did to get to a "hello world" state (at the `#born` state) was
we followed the example code [here][here].

(hereafter we'll refer to these as "the instructions".)

we ended up with a NON VERSIONED, SECRET file with these values:

    Client ID: [24 chars]
    Client Secret: [32 chars]
    Verification Token: [24 chars]
    OAuth Access Token: [74 chars]
    Bot User OAuth Access Token: [42 chars]

(ask someone for the file. these values MUST NOT be distributed with
this code.)

it turns out, we only need the last one to get our bot to Just Work.

as suggested in the instructions: from your terminal, export the thing
like so (replace `[42 chars]` with the actual OAuth access token):

    export SLACK_BOT_TOKEN='[42 chars]'

then simply run the bot:

    py upload_bot/run

(we use [these aliases](#aliases) as described below.)




## <a name='running-backend-tests'></a>running backend tests

have [the particular version][018_pyver] of python installed.

have activated our virtualenv as described in a [cousin document][here2].

we use these <a name='aliases'>aliases</a>
(these lines are in our `~/.zshrc`, basically):

    alias py='python3 -W error::Warning::0'
    alias pud='py -m unittest discover'

to run one test file:

    py upload_bot_test/test_200_magnetics/test_100_etc.py -vvvf

(the options are optional)

to run the whole test suite:

    pud upload_bot_test -vvvf




## appendix: our general setup

we use these <a name='aliases'>aliases</a>
(these lines are in our `~/.zshrc`, basically):

    alias py='python3 -W error::Warning::0'




[018_pyver]: ../doc/118-installing-and-deploying-python.md#python-version
[here]: https://www.fullstackpython.com/blog/build-first-slack-bot-python.html
[here2]: ../grep-dump-doc.md#venv-etc




## (document-meta)

  - #born.
