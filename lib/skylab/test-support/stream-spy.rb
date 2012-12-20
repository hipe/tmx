module Skylab::TestSupport
  class StreamSpy < ::Skylab::Headless::IO::Interceptors::Tee
    # A StreamSpy is a simple multiplexer that multiplexes out a subset
    # of the instance methods of the IO module out to an ordered hash of
    # listeners. StreamSpy is vital for automated testing, when you need
    # to 'spy' on for e.g. an output stream to ensure that certain data is being
    # written to it.
    #
    # Typically it's used like this: In places where you are writing to
    # e.g. $stdout or $stderr, hopefully you have represented it as variable.
    # At the beginning of your test, point that variable
    # instead to a StreamSpy that has as its only child member (listener) a
    # :buffer that is a (e.g.) StringIO.  Then in your test assertion ensure
    # that the data in the buffer (StringIO) is what you expect.
    #
    # (StreamSpy objects with such a configuration are so common that
    # a convenience method is provided that creates one such StreamSpy
    # object: `StreamSpy.standard`)
    #
    #   #todo example here using etc
    #
    # Calling debug! on your StreamSpy is another convenience 'macro'
    # that simply adds $stderr to the list of child listeners.  This can
    # be helpful when developing a test, when you want to spy on the spy
    # as it were, and have it output to $stderr what is being written to it,
    # in addition to writing to the buffer that you will later check.
    #

    # (omg wtf somebody somewhere is defining ::Struct::Group wtf [#sl-124])
    require_relative 'stream-spy/group'

    def self.standard
      new( buffer: TestSupport_::Services::StringIO.new ).tty!
    end

    def debug! prepend=nil
      down_stream = $stderr
      if prepend
        use_stream = Headless::IO::Interceptors::Filter.new down_stream
        if prepend.respond_to? :call
          use_stream.puts_filter! prepend
        else
          use_stream.line_boundary_string = prepend
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
