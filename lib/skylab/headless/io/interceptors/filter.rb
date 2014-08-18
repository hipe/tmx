module Skylab::Headless

  class IO::Interceptors::Filter  # :[#159]

    # intercept write-like messages intended for an ::IO, but do something
    # magical with the content. Don't forget to call flush! at the end.

    include Headless::IO::Interceptors::Tee::Is_TTY_Instance_Methods

    def initialize downstream_IO
      @check_for_line_boundaries = nil
      @down_IO = downstream_IO
      @line_begin_p = @line_end_p = nil
      @prev_was_NL = true ; @puts_wrap_p_a = nil
    end

    def downstream_IO
      @down_IO
    end

    def puts *a  # route everything through write()
      a = a.flatten
      a.length.zero? and a << EMPTY_STRING_
      a.each do |s|
        if @puts_wrap_p_a
          s = @puts_wrap_p_a.reduce( s ) { |m, p| p[ m ] }
        end
        s = s.to_s
        NL__ == s[ -1 ] or s = "#{ s }#{ NL__ }"
        write s
      end ; nil  # per ::IO#puts, but consider it undefined.
    end

    def write str
      begin
        if str.length.zero? || ! @check_for_line_boundaries
          break(( r = @down_IO.write str ))
        end
        was_NL = @prev_was_NL
        @prev_was_NL = NL__ == str[ -1 ]
        a = str.split NL__, -1
        last_d = a.length - 1
        a.each_with_index do |s, d|
          is_not_first = d.nonzero?
          is_not_last = last_d != d
          has_width = s.length.nonzero?
          if is_not_first
            @down_IO.write NL__
            @line_end_p and @line_end_p[]
          end
          if is_not_first || was_NL and
            is_not_last || has_width and @line_begin_p
            @line_begin_p[]
          end
          if has_width
            @down_IO.write s
          end
        end
        r = str.length
      end while nil
      r
    end
    alias_method :<<, :write

    NL__ = "\n".freeze  # not #DOS-line-endings

    def line_begin_string= s
      self.line_begin_proc = -> { @down_IO.write s } ; s
    end

    def line_begin_proc= p
      add_line_hndlr :@line_begin_p, p ; p
    end

    def puts_filter! p # each data passed to puts will first be run
      # through each filter in the order received in a reduce operation,
      # the result being what is finally passed to puts
      (( @puts_wrap_p_a ||= [] )) << p ; nil
    end

    def line_end= p
      add_line_hndlr :@line_end_p, p ; p
    end

  private
    def add_line_hndlr ivar, p
      instance_variable_get( ivar ).nil? or raise "#{ ivar } is write-once"
      instance_variable_set ivar, p
      @check_for_line_boundaries = true ; nil
    end
  public

    %i( close closed? rewind truncate ).each do |i|
      define_method i do |*a|
        if @down_IO.respond_to? i
          @down_IO.send i, *a
        end
      end
    end
  end
end
