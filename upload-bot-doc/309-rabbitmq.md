# rabbitmq

## <a name=ssmq></a>synopsos - starting and stopping the rabbitmq server

To start the server:

    rabbitmq-server

(add `-detached` to run it in the background.)

don't kill the server with `kill`, instead use:

    rabbitmqctl stop

(details:
  - [celery][celery3] says to use sudo but we apparently don't need to.
  - this assumes you have [installed](#install) rabbitmq.
)




## objective & scope

we might or might not end up using rabbitmq EDIT but these were our notes
from when we thought we were going to.




## installation - setting up the rabbitmq user

(per [celery][celery4].)




## <a name=install></a>installation - rabbitmq

things in this section need to be installed once per server/development
workstation (this is perhaps obvious, perhaps not); hence this section
is near the end of the document as a sort of appendix.

we cover only OS X now with the intention that we can expand this section
as appropriate later to annotate how we installed this lyfe on servers.



### installing rabbitmq on OS X

the norm on OS X broadly is (of course) to install "pre-compiled binaries".
indeed, the [installation page][rabbit1] for rabbitmq offers a tarball for
presumably this.

but both that page and the [celery one][celery1] suggest the same thing
(the former saying it's "[p]ossibly the easiest way to use this package"):
to install rabbitmq using homebrew.

(homebrew is mac's would-be package manager, like `apt-get`. how to install
`brew` (homebrew) itself is out our scope but it's a trivial one-liner as
offered by celery there.)

so that's what we'll do:

    brew install rabbitmq

(at writing this installs rabbitmq version
3.7.4.
we'll probably want whatever is the latest stable, and we should update
this document to reflect that as we bump our version to track with what's
stable.)

and:

  - according to the celery suggestion, we added `/usr/local/sbin` to our
    `PATH` (in our `~/.zshrc`). it's necessary to have that in your PATH
    to be able to start and stop the broker from the terminal.



### configuring the system host name for rabbitmq on OS X

this is all from the [relevant section][celery2] of the celery docs,
with some superficial modifications:

we did:

    scutil --set HostName pennys_computer_book.local

(and then at the prompt we enter our password). this is how our way
differed:

  - we used the name `pennys_computer_book` instead of `myhost` just
    to make it our own. this should probably be its own name per server
    ETC..

  - we did _not_ use `sudo` in the command, just to see what happend.
    (what happened was it popped up the dialog, which is interesting.)


and this to `/etc/hosts`:

    127.0.0.1       localhost pennys_computer_book pennys_computer_book.local


we're ignoring the fact that that's not taking. but we already had
localhost in there so ETC




[celery4]: http://docs.celeryproject.org/en/latest/getting-started/brokers/rabbitmq.html#setting-up-rabbitmq
[celery3]: http://docs.celeryproject.org/en/latest/getting-started/brokers/rabbitmq.html#starting-stopping-the-rabbitmq-server
[celery2]: http://docs.celeryproject.org/en/latest/getting-started/brokers/rabbitmq.html#configuring-the-system-host-name
[celery1]: http://docs.celeryproject.org/en/latest/getting-started/brokers/rabbitmq.html#installing-rabbitmq-on-macos
[rabbit1]: https://www.rabbitmq.com/install-standalone-mac.html




## (document-meta)

  - #born.
