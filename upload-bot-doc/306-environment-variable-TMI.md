# environment variable TMI

## synopsis

    source _MY_TOP_SECRET_NOT_VERSIONED_TOKENS_.sh

then try to start the server as described at [the main README up top][here1].




## working with the environment variables

after understanding [what](#why) these tokens are and [why](#sensitivity)
they are environment variables, what you'll probably end up with (somehow)
is a NON-VERSIONED, SECRET file that's a shell script that exports them.

the file would have lines like:

    export SLACK_BOT_TOKEN='abc123etc'
    export SLACK_AUTH_DOO_DAH='cha-cha-cha'

if for some reason you have these values in your environment but not in
a file (in the form of a shell script), you can:

    py ./upload_bot/_magnetics/secrets_via_environment_variables.py > _SOURCE_ME_.sh

all that does is go thru the list of participating environment variable
names, and for those that are set it spits out the name value pair as a
shell `export` statement.

(by the way, knowing what environment variables are and how to set them is
beyond our scope but it is a prerequisite here. (but if you're here, you
probably already know etc.))




## <a name=why></a>why tokens

in order for the whole slack ecosystem to talk to _your_ ecosystem, private
tokens will be exchanged through ssl to be sure that you are who you say
you are (or whatever).

it is furthermore essential that you as the slack app ecosystem know which
slack app installation (team, whatever) is talking to you. like, you might
be like Scarlett Johansson in _Her_ maintaining parallel conversations with
tens of thousands of clients at once. for each incoming event (etc) to you,
you'll need to be able to resolve which client it's about.




## <a name=sensitivity></a>why environment variables

if a bad actor were to get their hands on our private tokens, they could
pretend to be us and access our slack data or worse. (doxxing, social
engineering, trade secrets, data destruction, russians, zuckerberg, ..)

first, basics:

  - we *DO NOT* send these values out into the internet generally
  - so *DO NOT* send these values out in email, or in an email attachment
  - so *DO NOT* write these values in code (code is often versioned.)
  - and *DO NOT* put these values in messages in ordinary slack channels
  - *ATTEMPT* to make any file with these values not publicly viewable

the bad thing we generally want to avoid is having these values in plain
text on disk (sort of). as such we design our software to try to avoid
some common pitfalls:

  - don't make it easy for these values to be passed in via a
    config file. (config files have a way of getting versioned.)
  - don't make it easy for these values to be hard-coded into
    the code. (code is usually versioned.)

(note the pattern of keeping these values away from version control.
versioned content is a bad place for sensitive data, generally.)

by designing this "poka yoke" into the software, we pass the buck of
security further up the stream, but only somewhat. environment variables
aren't magically foolproof against every attack vector, but they at least
avoid the low-hanging-fruit pitfalls discussed above.

ultimately, though, these values *will* have to be stored and transferred
electronically somehow, somewhere.

  - it's unreasonable to expect developers to keep these values not in
    plain text on their disks, but it's incumbent on the trusted developer
    to exercise the overarching precautions discussed here.
  - (maybe one day we could get fancy with that one thing EDIT)
  - we consider slack private messages to be an adequately secure means
    of sharing tokens from one developer to another.
  - however don't share tokens in ordinary slack channels. having an
    overlarge set of parties privy to the tokens would make eventual
    attribution overly complicated.




## origins

after following the instructions [here][here1], we ended up with a
NON-VERSIONED, SECRET file with these values:

    Client ID: [24 chars]
    Client Secret: [32 chars]
    Verification Token: [24 chars]
    OAuth Access Token: [74 chars]
    Bot User OAuth Access Token: [42 chars]

of these:
  - we may only need a subset of them, depending on what we are doing.
  - probably not all of these values need to be considered sensitive.




[here2]: https://www.fullstackpython.com/blog/build-first-slack-bot-python.html
[here1]: README.md#synopsis


## (document-meta)

  - #born.
