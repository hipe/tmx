module Skylab::Headless
  class IO::Interceptors::Filter <
    ::Struct.new(:downstream, :handlers, :last_char)

    # intercept write-like messages intended for an ::IO, but do something
    # magical with the content. Don't forget to call flush! at the end.

    include Headless::IO::Interceptor::InstanceMethods

    def initialize downstream
      @check_for_line_boundaries = nil
      super(downstream, IO::Interceptors::Filter::Handlers.new, nil)
      yield self if block_given?
    end

    NEWLINE = "\n" # easier to refactor in case we add \r support

    def on_line_boundary &b
      @check_for_line_boundaries = true
      handlers.line_boundary = b
    end

    # route everything through write()
    def puts *a
      0 == a.length and a = ['']
      a.each do |s|
        s = s.to_s
        unless NEWLINE == s[-1, 1]
          s = "#{s}#{NEWLINE}"
        end
        write s
      end
      downstream
    end

    def write s
      if @check_for_line_boundaries
        if NEWLINE == last_char or last_char.nil? and 0 < s.length
          handlers.line_boundary.call
        end
        if 0 < s.length
          self.last_char = s[-1]
        end
        downstream.write s
      else
        downstream.write s
      end
    end

    alias_method :<<, :write

  end
  class IO::Interceptors::Filter::Handlers < ::Struct.new(:line_boundary) ; end
end
