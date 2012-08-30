module Skylab::Headless
  class IO::Interceptors::Filter <
    ::Struct.new(:downstream, :previous_newline, :handlers)

    # intercept write-like messages intended for an ::IO, but do something
    # magical with the content. Don't forget to call flush! at the end.

    include Headless::IO::Interceptor::InstanceMethods

    def initialize downstream, opts=nil
      @check_for_line_boundaries = nil
      super(downstream, NEWLINE, IO::Interceptors::Filter::Handlers.new)
      opts and opts.each { |k, v| send("#{k}=", v) }
      yield self if block_given?
    end

    def line_boundary_string= string
      on_line_boundary { downstream.write string }
    end

    NEWLINE = "\n" # easier to refactor in case we add \r support

    def on_line_boundary &b
      @check_for_line_boundaries = true
      handlers.line_boundary = b
    end

    # route everything through write()
    def puts *a
      a = a.flatten
      0 == a.length and a.push('')
      a.each do |s|
        s = s.to_s
        s = "#{s}#{NEWLINE}" unless NEWLINE == s[-1, 1]
        write s
      end
      nil # per ::IO#puts, but consider it undefined.
    end

    def write s
      if @check_for_line_boundaries
        if 0 < s.length
          pnl = previous_newline
          self.previous_newline = NEWLINE == s[-1, 1] ? NEWLINE : nil
          a = s.split("\n", -1)
          last = a.length - 1
          a.each_with_index do |_s, idx|
            downstream.write(NEWLINE) unless 0 == idx
            if 0 != idx || pnl and last != idx || '' != _s
              handlers.line_boundary.call
            end
            downstream.write(_s) unless '' == _s
          end
        end
      else
        downstream.write s
      end
    end

    alias_method :<<, :write

  end
  class IO::Interceptors::Filter::Handlers < ::Struct.new(:line_boundary) ; end
end
