module Skylab::Headless
  class IO::Interceptors::Filter <
    ::Struct.new :downstream, :previous_newline, :handlers

    # intercept write-like messages intended for an ::IO, but do something
    # magical with the content. Don't forget to call flush! at the end.

    include Headless::IO::Interceptor::InstanceMethods

    newline = "\n" # (easier to refactor in case we add \r support)

    def line_begin_string= string
      self.line_begin = -> { downstream.write string }
      string
    end

    def line_begin= f
      line :line_begin, f
    end

    def line_end= f
      line :line_end, f
    end

    # route everything through write()
    define_method :puts do |*a|
      a = a.flatten
      0 == a.length and a.push ''
      a.each do |s|
        if handlers[:puts_wrap]
          s = handlers.puts_wrap.reduce( s ) { |m, x| x.call m }
        end
        s = s.to_s
        s = "#{ s }#{ newline }" if newline != s[-1]
        write s
      end
      nil # per ::IO#puts, but consider it undefined.
    end

    def puts_filter! callable     # each data passed to puts will first be
      handlers.puts_wrap ||= []   # run through each filter in the order
      handlers.puts_wrap.push callable    # received in a reduce operation,
      true                                # the result being what is finally
    end                                   # passed to puts

    define_method :write do |str|
      res = nil
      begin
        if 0 == str.length || ! @check_for_line_boundaries
          res = downstream.write str
          break
        end
        nl = previous_newline
        self.previous_newline = newline == str[-1]
        a = str.split newline, -1
        last = a.length - 1
        a.each_with_index do |s, idx|
          if 0 != idx
            downstream.write newline
            handlers[:line_end] and handlers.line_end[ ]
          end
          if 0 != idx || nl and last != idx || '' != s and handlers[:line_begin]
            handlers.line_begin[ ]
          end
          if '' != s
            downstream.write s
          end
         end
        res = str.length
      end while nil
      res
    end

    alias_method :<<, :write

  protected

    handlers_struct = ::Struct.new :line_begin, :line_end, :puts_wrap

    define_method :initialize do |downstream|
      @check_for_line_boundaries = nil
      self[:downstream] = downstream
      self[:previous_newline] = true
      self[:handlers] = handlers_struct.new
    end

    def line which, f
      handlers[which] and fail "won't clobber existing #{ which } handler"
      @check_for_line_boundaries = true
      handlers[which] = f
    end
  end
end
