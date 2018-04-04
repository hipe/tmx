# celery

## synopsis

(be sure redis is running per [the sibling redis doc][redis_mine], then:)

this is what it is FOR NOW (ETC):

    celery -A upload_bot._magnetics.webserver_via_behavior.celery worker




## why message queueing

[this section][slack1] of the slack API documentation encourages this
thrilling complication:

> Respond to events with a HTTP 200 OK as soon as you can.
> Avoid actually processing and reacting to events within the same process.
> Implement a queue to handle inbound events after they are received.




## which message queue solution?

for now, the clear path for us on flask seems to be to use rabbitmq
and celery ETC.

as far as we know, "rabbitmq" is the main thing we're after, and "celery"
is the like wrapper/adapter thing to make rabbitmq work with things like
our sebserver (flask).

(the name "celery" is presumably because rabbits eat celery; that is, it's
a derivative product not a standalone product.)




## installation

(this is something that needs to be done only once per system, typically.)

from the installation instructions on celery's [introduction page][celery5],
we decided to try to install celery and the dependencies for our target
features all in one go using "bundles":

    pipenv install "celery[redis]"

(keeping this here for future use:)

    pipenv install "celery[rabbitmq]"





[celery5]: http://docs.celeryproject.org/en/latest/getting-started/introduction.html#installation
[redis_mine]: 308-redis.md#syno
[slack1]: https://api.slack.com/events-api#responding_to_events




# (document-meta)

  - #born.
