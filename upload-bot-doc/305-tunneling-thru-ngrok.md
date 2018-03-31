# tunneling thru ngrok

## synopsis

  - [install](#installation) ngrok if necessary
  - [start][here2] your webserver (in development mode) if necessary

then (assuming our usual config choices for development server)

    ngrok http 5000

(per [here][here3].) you will see a countdown timer start for 8 hours.


then, from the "Event Subscriptions" page of your app, paste in
the url (change the goobeldegook):

    https://6fa7878c.ngrok.io/slack-action-endpoint

(we can start and stop our development server without needing to start
and stop the tunnel.)




## objective & scope

when you're developing a thing like a facebook app or a slack app,
tunneling is the way that you can be developing your work on your
local machine and still test it against their infrastructure on the
internet.

there is EDIT some reason why stuff on your laptop can't _just be_
on the internet as is. maybe it's because you don't have a stable
IP address. (or you're behind a NAT or something.) tunneling lets you
use an outside service to make it look like your thing is on the
internet proper.

here's how the stuff works normally, in production:

    +----------------+                             +------------+
    | your thing, on |    (request or response)    | the slack  |
    | (for example)  |          <--------          | mothership |
    | heroku         |          --------->         +------------+
    +----------------+    (response or request)


but in development, your laptop isn't _in_ the cloud, so:

    +----------------+     +-----------------+     +------------+
    | your laptop    | <-  | ngrok tunneling | <-  | the slack  |
    | or workstation |  -> |      service    |  -> | mothership |
    +----------------+     +-----------------+     +------------+

the tunneling is what lets you work locally but still have your thing
show up on the internet where others (like slack) can see it.




## objective of this document

there are passing mentions of `ngrok` in slack example code, but nothing
more than links to it. here, then, is our attempt at documenting exactly
how we use it for our slack app.




## <a name=installation></a>installation

(it appears we did not need to make even the free account to download
and run ngrok.)

follow the instructions as appropriate for your operating system from
[their site][here1]. it was straightforward for us.

for OS X, we:

  - downloaded the binary

then:
    cd ~/Downloads
    unzip ngrok-stable-darwin-amd64.zip
    mv ngrok ~/bin




[here3]: https://ngrok.com/docs
[here2]: README.md#synopsis
[here1]: https://ngrok.com/download




## (document-meta)

  - #born.
