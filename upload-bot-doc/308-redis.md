# redis

## <a name=syno></a>synopsis

(after having [installed](#inst) it), run redis with:

    cd Z/redis-stable && ./src/redis-server

if this succeeds, it will show the little graphic and be running in
that terminal.




## (objective & scope)

(we expect this document to be short)
(we use redis only for our use of celery; that is, for our task queue.)
(as a broker, we use redis for now because it's easier)
(our upgrade path leads to using rabbitmq if we wanted to scale)
(we use redis as a result store, which seems to be a popular choice)




## <a name=inst></a>installation

we downloaded the tarball from [their download page][redis1].
we downloaded and installed version
4.0.9.

combining instructions from the above page and [migel's][miguel1] stuff,

    curl -O http://download.redis.io/releases/redis-stable.tar.gz
    tar xvzf redis-stable.tar.gz
    rm redis-stable.tar.gz

we move it into our unversioned spot (but you could put it anywhere)

    mv redis-stable Z/
    cd Z/redis-stable
    make

this one takes a long time, but just for posterity: on OS X these tests
all passed:

    make test

to run our newly compiled redis server, see [synopsis](#syno) above.





[miguel1]: https://github.com/miguelgrinberg/flask-celery-example
[redis1]: https://redis.io/download




## (document-meta)

  - #born.
