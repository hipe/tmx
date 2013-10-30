# the IO spy

## how to use it

objects of this class constitute the member of both the members (sic) of the
[#020] family - 'io spy triad' and 'io spy group'. for the 98% use case it is
expected that you can leverage this node via those nodes rather than needing
to interface with this node directly.

## what it is

A IO::Spy is a simple multiplexer that multiplexes out a subset of the
instance methods of the IO module out to an ordered hash of listeners. IO::Spy
is vital for automated testing, when you need to 'spy' on for e.g. an output
stream to ensure that certain data is being written to it.

typically it's used like this: in places where you are writing to e.g.
$s-tdout or $s-tderr, you should never be accessing these globals (or their
constant forms) directly, but rather they should be assigned e.g to ivars
somewhere and you should be sending messages to the ivars to send message
e.g to s-tdout or s-tdere:

    @out = $stdout
    # ..
    @out.puts "ohai"

in the part of your test where you build your client, assign those variables
instead to an IO::Spy that has as its only child member (listener) a :buffer
that is a (e.g) ::StringIO. then in your test assertion ensure that the data
in the buffer (::StringIO) is what you expect.

IO::Spy objects with such a configuration are so common that a convenience
method is provided that creates one such IO::Spy object: `IO::Spy.standard`

  #todo example here using doc-test

calling debug! on your IO::Spy is another convenience 'macro' that simply adds
$s-tderr to the list of child listeners. this is essential when you are
developing a new test or perhaps debugging a red one and you want to see
real-time output of what data the stream is receiving. not that because
the IO spy is at its core a multiplexer, whether or not you 'debug!' *should*
have no effect on the data written to the buffer that you will test against.

#todo - whether this is on the one hand a pure tee or on the other always
consisting of at least an IO buffer, it is confusing and showing strain.
survey if ever we do not make a s.s that is standard, and if not then bake it
in and if so then subclass.
