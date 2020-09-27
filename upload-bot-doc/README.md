# the 'upload' bot

## <a name=synopsis></a>synopsis

    python3 -W 'default::::' upload_bot/run.py

(NOTE: at the commit of #history-A.1 we explain why this is currently
a moutful above. work in progress to make this not as ugly..)

given:

  - [\[#306\]] the necessary environment variables
  - the [below](#aliases) aliases.




## objective & scope:

when someone uploads a file to any channel, give them the option of
deleting the file off slack's storage and instead uploading it to an
s3 instance.

(a more detailed user story will be provided.)




## <a name='running-backend-tests'></a>running backend tests

have [the particular version][018_pyver] of python installed.

have activated our virtualenv as described in a [cousin document][here2].

we use the aliases described [below](#aliases).

to run one test file:

    py upload_bot_test/test_200_magnetics/test_100_etc.py -vvvf

(the options are optional)

to run the whole test suite:

    pud upload_bot_test -vvvf




## running tests for our app API webserver

this is an area heavily in flux that belongs to [\[#306\]] this document.




## our general setup

we use these <a name='aliases'>aliases</a>
(these lines are in our `~/.zshrc`, basically):

    alias py='python3 -W error::Warning::0'
    alias pud='py -m unittest discover'




## <a name="node-table"></a>the node table

(this table is explained at [\[#002\]] using the node table.)

| Id                        | Main Tag | Content |
|---------------------------|:-----:|-
|                   [#309.B]| #edit | edit documentation
|              [\[#309\]]   |       | rabbitmq
|              [\[#308\]]   |       | redis
|              [\[#307\]]   |       | celery
|                   [#306.B]| #edit | edit documentation
|              [\[#306\]]   |       | environment variables TMI
|                   [#305.B]| #edit | edit documentation
|              [\[#305\]]   |       | tunneling thru ngrok
|                [#304]     |       | "kicker"
|              [\[#303\]]   |       | testing our webserver
|              [\[#302\]]   |       | reading notes: slack event types




[\[#309\]]: 309-rabbitmq.md
[\[#308\]]: 308-redis.md
[\[#307\]]: 307-celery.md
[\[#306\]]: 306-environment-variable-TMI.md
[\[#305\]]: 305-tunneling-thru-ngrok.md
[\[#303\]]: 303-testing-our-webserver-with-postman.md
[\[#302\]]: 302-slack-event-types.txt
[\[#002\]]: ../README.md#002
[018_pyver]: ../doc/118-installing-and-deploying-python.md#python-version
[here2]: ../grep-dump-doc.md#venv-etc




## (document-meta)

  - #history-A.1 (as referenced)
  - #born.
