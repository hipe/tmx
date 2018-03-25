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




## appendix: our general setup

we use these <a name='aliases'>aliases</a>
(these lines are in our `~/.zshrc`, basically):

    alias py='python3 -W error::Warning::0'




[here]: https://www.fullstackpython.com/blog/build-first-slack-bot-python.html




## (document-meta)

  - #born.
