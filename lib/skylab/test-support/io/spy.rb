module Skylab::TestSupport

  class IO::Spy < ::Skylab::Headless::IO::Interceptors::Tee  # :[#023] ".."

    def self.standard
      new( buffer: Subsys::Services::StringIO.new ).tty!
    end

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

    def string  # assumes :buffer is a member. a "convenience macro"
      self[ :buffer ].string
    end
  end
end
