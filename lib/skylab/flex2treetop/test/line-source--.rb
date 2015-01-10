module Skylab::Flex2Treetop::MyTestSupport

  class Line_Source__

    def initialize debug_IO, &p
      @crrnt_chopped_line_scanner = nil
      @debug_IO = debug_IO
      block_given? and yield self
      super()
    end

    def init_upstream_line_source_with_emissions chan_i, em_a
      @emission_a = em_a
      init_chopped_line_stream_for_channel chan_i ; nil
    end
  private
    def init_chopped_line_stream_for_channel chan_i
      init_chopped_line_stream bld_chopped_line_stream_for_channel chan_i
    end

    def bld_chopped_line_stream_for_channel chan_i
      Chopped_line_peeking_channel_scanner__[ @emission_a, @debug_IO, chan_i ]
    end
  public

    def init_upstream_line_source_with_open_file_IO io
      init_chopped_line_stream bld_IO_chopped_line_stream io ; nil
    end

  private
    def init_chopped_line_stream x
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

    def change_upstream_stream_to_channel chan_i
      chnge_chopped_lines_stream_to bld_chopped_line_stream_for_channel chan_i
      nil
    end

    def change_upstream_stream_to_open_filehandle io
      chnge_chopped_lines_stream_to bld_IO_chopped_line_stream io ; nil
    end
  private
    def bld_IO_chopped_line_stream io
      Chopped_line_peeking_IO_scanner__[ io, @debug_IO ]
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
      chnge_chopped_lines_stream_to bld_chopped_lines_stream_from_ary bb.a
      bb.count
    end

  private

    class Bounceback__  # bounce down to the end of the scanner,
      def initialize d, scn  # then "go back up" N times
        @d = d ; @scn = scn ; nil
      end
      def execute
        buff = TestLib_::Rotating_buffer[ @d ]
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

    def bld_chopped_lines_stream_from_ary buff_a
      Chopped_line_peeking_ary_scanner__[ buff_a, @debug_IO ]
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
      count = 0
      while @crrnt_chopped_line_scanner.gets
        count += 1
      end
      count
    end

    def peek_any_chopped_line
      @crrnt_chopped_line_scanner.peek
    end

  private

    def chnge_chopped_lines_stream_to scn
      s = @crrnt_chopped_line_scanner.gets and fail say_unspent_lines s
      @crrnt_chopped_line_scanner = scn ; nil
    end

    def say_unspent_lines s
      "won't change upstream with unspent line(s): #{ [ chan_i, s ].inspect }"
    end

    def chan_i
      @crrnt_chopped_line_scanner.chan_i
    end

    Chopped_line_peeking_channel_scanner__ = -> em_a, debug_IO, chan_i do

      _scn = Callback_::Scn.new do

        if em_a.length.nonzero? && chan_i == em_a.first.stream_symbol
          str = em_a.shift.string
          str.chop! or fail "empty string?"
          str
        end
      end

      Finish_scn__[ _scn, debug_IO, chan_i ]
    end

    Chopped_line_peeking_IO_scanner__ = -> io, debug_IO do

      p = -> do
        s = io.gets
        if s
          s.chop! or fail "empty line without terminating newline?"
          s
        else
          io.close
          p = NILADIC_EMPTINESS_
          nil
        end
      end

      _scn = Callback_::Scn.new do
        p[]
      end

      Finish_scn__[ _scn, debug_IO, :_file_IO_handle_ ]
    end

    NILADIC_EMPTINESS_ = -> {}

    Chopped_line_peeking_ary_scanner__ = -> a, debug_IO do
      _scn = Callback_.stream.via_nonsparse_array a
      Finish_scn__[ _scn, debug_IO, :ary ]
    end

    Finish_scn__ = -> scn, debug_IO, chan_i do
      scn_ = if debug_IO
        Callback_.stream.map scn, Debug_map__[ chan_i, debug_IO ]
      else
        scn
      end

      Callback_::Scn.peek.gets_under scn_
    end

    Debug_map__ = -> chan_i, io do
      -> x do
        io.puts [ chan_i, x ].inspect
        x
      end
    end
  end
end
