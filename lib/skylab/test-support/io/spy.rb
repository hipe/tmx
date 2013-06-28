module Skylab::TestSupport

  class IO::Spy < ::Skylab::Headless::IO::Interceptors::Tee

    # A IO::Spy is a simple multiplexer that multiplexes out a subset
    # of the instance methods of the IO module out to an ordered hash of
    # listeners. IO::Spy is vital for automated testing, when you need
    # to 'spy' on for e.g. an output stream to ensure that certain data is being
    # written to it.
    #
    # Typically it's used like this: In places where you are writing to
    # e.g. $s-tdout or $s-tderr, hopefully you have represented it as variable.
    # At the beginning of your test, point that variable
    # instead to a IO::Spy that has as its only child member (listener) a
    # :buffer that is a (e.g.) ::StringIO.  Then in your test assertion ensure
    # that the data in the buffer (::StringIO) is what you expect.
    #
    # (IO::Spy objects with such a configuration are so common that
    # a convenience method is provided that creates one such IO::Spy
    # object: `IO::Spy.standard`)
    #
    #   #todo example here using etc
    #
    # Calling debug! on your IO::Spy is another convenience 'macro'
    # that simply adds $s-tderr to the list of child listeners.  This can
    # be helpful when developing a test, when you want to spy on the spy
    # as it were, and have it output to $s-tderr what is being written to it,
    # in addition to writing to the buffer that you will later check.
    #
    # #todo - whether this is on the one hand a pure tee or on the other
    # always consisting of at least an IO buffer, it is confusing and showing
    # strain. survey if ever we do not make a s.s that is standard, and if not
    # then bake it in and if so then subclass.
    #

    def self.standard
      new( buffer: TestSupport_::Services::StringIO.new ).tty!
    end

    # --*--

    def clear_buffer
      self[:buffer].instance_exec do
        rewind
        truncate 0
      end
      nil
    end

    def debug! prepend=nil
      down_stream = Stderr_.call
      if prepend
        use_stream = Headless::IO::Interceptors::Filter.new down_stream
        if prepend.respond_to? :call
          use_stream.puts_filter! prepend
        else
          use_stream.line_begin_string = prepend
        end
      else
        use_stream = down_stream
      end
      self[:debug] = use_stream
      self
    end

    def string # just a convenience macro.  :buffer listener must obv. exist
      self[:buffer].string
    end
  end
end
