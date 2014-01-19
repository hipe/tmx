module Skylab::Flex2Treetop::MyTestSupport

  class Line_Source__

    Basic = Flex2Treetop::Lib_::Basic[]
    MetaHell = ::Skylab::MetaHell

    def initialize debug_IO, &p
      @crrnt_chopped_line_scanner = nil
      @debug_IO = debug_IO
      block_given? and yield self
      super()
    end

    def init_upstream_line_source_with_emissions chan_i, em_a
      @emission_a = em_a
      init_chopped_line_scanner_for_channel chan_i ; nil
    end
  private
    def init_chopped_line_scanner_for_channel chan_i
      init_chopped_line_scanner bld_chopped_line_scanner_for_channel chan_i
    end

    def bld_chopped_line_scanner_for_channel chan_i
      Chopped_Line_Peeking_Channel_Scanner__.new @debug_IO, chan_i, @emission_a
    end
  public

    def init_upstream_line_source_with_open_file_IO io
      init_chopped_line_scanner bld_IO_chopped_line_scanner io ; nil
    end

  private
    def init_chopped_line_scanner x
      @crrnt_chopped_line_scanner and fail "upstream scanner alread set"
      @crrnt_chopped_line_scanner = x ; nil
    end
  public

    def gets_some_chopped_line
      @crrnt_chopped_line_scanner.gets or raise say_exp_more_lines
    end
  private
    def say_exp_more_lines
      "expected another line from '#{ chan_i }', had none."
    end
  public

    def assert_no_more_lines
      s = @crrnt_chopped_line_scanner.gets and fail say_exp_no_more_lines s
    end
  private
    def say_exp_no_more_lines s
      "expected no more lines, had: #{ [ chan_i, s ].inspect }"
    end
  public

    def change_upstream_scanner_to_channel chan_i
      chnge_chopped_lines_scanner_to bld_chopped_line_scanner_for_channel chan_i
      nil
    end

    def change_upstream_scanner_to_open_filehandle io
      chnge_chopped_lines_scanner_to bld_IO_chopped_line_scanner io ; nil
    end
  private
    def bld_IO_chopped_line_scanner io
      Chopped_Line_Peeking_IO_Scanner__.new @debug_IO, io
    end
  public

    def gets_some_first_chopped_line_that_does_not_match rx
      p = rx.method :=~
      begin
        s = gets_some_chopped_line
      end while p[ s ]
      s
    end

    def skip_until_last_N_lines d
      bb = Bounceback__.new( d, @crrnt_chopped_line_scanner ).execute
      chnge_chopped_lines_scanner_to bld_chopped_lines_scanner_from_ary bb.a
      bb.count
    end

  private

    class Bounceback__  # bounce down to the end of the scanner,
      def initialize d, scn  # then "go back up" N times
        @d = d ; @scn = scn ; nil
      end
      def execute
        buff = Basic::Rotating_Buffer[ @d ]
        count = 0
        while true
          line = @scn.gets
          line or break
          count += 1
          buff << line
        end
        @d = @scn = nil
        @a = buff.to_a ; @count = count - buff.virtual_buffer_length
        self
      end
      attr_reader :a, :count
    end

    def bld_chopped_lines_scanner_from_ary buff_a
      Chopped_Line_Peeking_Ary_Scanner__.new @debug_IO, buff_a
    end

  public

    def skip_contiguous_chopped_lines_that_match rx
      count = 0
      white_p = rx.method :=~
      while (( line = @crrnt_chopped_line_scanner.peek ))
        _did = white_p[ line ]
        _did or break
        @crrnt_chopped_line_scanner.gets
        count += 1
      end
      count
    end

    def skip_all_contiguous_emissions_on_channel chan_i
      chan_i == @crrnt_chopped_line_scanner.chan_i or self._DO_ME
      count = 0
      while @crrnt_chopped_line_scanner.gets
        count += 1
      end
      count
    end

    def peek_any_chopped_line
      @crrnt_chopped_line_scanner.peek
    end

    def close
      @crrnt_chopped_line_scanner.close
    end

  private

    def chnge_chopped_lines_scanner_to scn
      s = @crrnt_chopped_line_scanner.gets and fail say_unspent_lines s
      @crrnt_chopped_line_scanner = scn ; nil
    end

    def say_unspent_lines s
      "won't change upstream with unspent line(s): #{ [ chan_i, s ].inspect }"
    end

    def chan_i
      @crrnt_chopped_line_scanner.chan_i
    end

    Scanner_with_debug__ = -> cls do
      cls.class_exec( & Scanner_with_debug___ )
    end
    Scanner_with_debug___ = -> do
      alias_method :gets_before_debug, :gets
      def gets
        x = gets_before_debug
        x and @debug_IO and @debug_IO.puts [ chan_i, x ].inspect
        x
      end
    end

    class Chopped_Line_Peeking_Channel_Scanner__

      def initialize debug_IO, chan_i, em_a
        @gets_p = -> do
          if em_a.length.nonzero? and chan_i == em_a.first.stream_name
            em_a.shift.string.chop! or fail "empty string?"
          end
        end
        @chan_i = chan_i ; @debug_IO = debug_IO ; nil
      end

      def gets
        @gets_p.call
      end

      attr_reader :chan_i

      Basic::List::Scanner::With[ self, :peek ]
      Scanner_with_debug__[ self ]
    end

    class Chopped_Line_Peeking_IO_Scanner__

      def initialize debug_IO, io
        @gets_p = -> do
          s = io.gets
          if s
            s.chop! or fail "empty line without terminating newline?"
          else
            io.close ; @gets_p = MetaHell::EMPTY_P_ ; nil
          end
        end
        @close_p = -> do
          io.close ; nil
        end
        @debug_IO = debug_IO ; nil
      end

      def gets
        @gets_p[]
      end

      def close
        @close_p[]
      end

      def chan_i
        :_file_IO_handle_
      end

      Basic::List::Scanner::With[ self, :peek ]
      Scanner_with_debug__[ self ]
    end

    class Chopped_Line_Peeking_Ary_Scanner__ < Basic::List::Scanner::For::Array

      def initialize debug_IO, ary
        super ary
        @debug_IO = debug_IO ; nil
      end

      def chan_i
        :ary
      end

      Scanner_with_debug__[ self ]
    end
  end
end
