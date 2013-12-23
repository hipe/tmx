module Skylab::TestSupport

  class IO::Spy < ::Skylab::Headless::IO::Interceptors::Tee  # :[#023] ..

    def self.standard
      new( BUFFER_I__ => TestSupport_::Services::StringIO.new ).tty!
    end

    def string  # assumes this constituent
      self[ BUFFER_I__ ].string
    end

    def clear_buffer
      self[ BUFFER_I__ ].instance_exec do
        rewind
        truncate 0
      end ; nil
    end

    def debug! prepend_x=nil
      down_IO = Stderr_[]
      if prepend_x
        io = Headless::IO::Interceptors::Filter.new down_IO
        if prepend_x.respond_to? :call
          io.puts_filter! prepend_x
        else
          io.line_begin_string = prepend_x
        end
      else
        io = down_IO
      end
      self[ DEBUG_I__ ] = io
      self
    end

    BUFFER_I__ = :buffer ; DEBUG_I__ = :debug  # ok to open up if needed

  end
end
