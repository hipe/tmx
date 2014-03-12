module Skylab::TestSupport

  module IO
    Autoloader_[ self ]
  end

  class IO::Spy < TestSupport_::Lib_::IO[]::Interceptors::Tee  # :[#023] ..

    Autoloader_[ self, :methods ]

    def self.standard
      io = new( BUFFER_I__ => TestSupport_::Library_::StringIO.new ).tty!
      block_given? and yield io
      io
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
      set_dbg_element DEBUG_I__, TestSupport_::Lib_::Stderr[], prepend_x ; self
    end

    def any_debug_IO_notify any_debug_IO
      any_debug_IO and set_dbg_element DEBUG_I__, any_debug_IO, nil ; nil
    end

  private

    def set_dbg_element element_i, down_IO, prepend_x
      self[ element_i ] = prepend_x ? wrp_IO( prepend_x, down_IO ) : down_IO
      nil
    end

    def wrp_IO prepend_x, down_IO
      io = TestSupport_::Lib_::IO[]::Interceptors::Filter.new down_IO
      if prepend_x.respond_to? :call
        io.puts_filter! prepend_x
      else
        io.line_begin_string = prepend_x
      end
      io
    end

  public

    BUFFER_I__ = :buffer ; DEBUG_I__ = :debug  # ok to open up if needed

  end
end
