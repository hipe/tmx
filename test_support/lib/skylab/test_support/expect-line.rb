module Skylab::TestSupport

  class Expect_line

    # assumes @output_s

    class << self

      def [] test_context_class
        test_context_class.include Test_Context_Instance_Methods ; nil
      end

      def shell output_s
        Shell__.new output_s
      end
    end  # >>

    Test_Context_Instance_Methods = ::Module.new

    class Shell__

      include Test_Context_Instance_Methods

      def initialize s
        @output_s = s
      end
    end

    module Test_Context_Instance_Methods

      def excerpt range
        excerpt_lines( range ) * EMPTY_S_
      end

      def excerpt_lines range
        in_string_excerpt_range_of_lines @output_s, range
      end

      def in_string_excerpt_range_of_lines s, range
        beg_d = range.begin
        end_d = range.end
        if beg_d < 0
          if end_d < 0
            excrpt_lines_from_end beg_d, end_d, s
          else
            false
          end
        elsif end_d >= 0
          excrpt_lines_from_beginning beg_d, end_d, s
        else
          false
        end
      end

      def excrpt_lines_from_beginning beg_d, end_d, s

        _RX = Home_.lib_.basic::String.regex_for_line_scanning

        scn = Home_::Library_::StringScanner.new s

        y = []
        current_line_index = 0
        while current_line_index < beg_d
          current_line_index += 1
          if ! scn.skip _RX
            y = false
            break
          end
        end
        if y
          while current_line_index <= end_d
            current_line_index += 1
            s = scn.scan _RX
            if s
              y.push s
            else
              y = false
              break
            end
          end
        end
        y
      end

      def excrpt_lines_from_end beg_d, end_d, s
        if s.length.nonzero?
          scn = backwards_index_stream s, NEWLINE_
          d = s.length - 1
          if NEWLINE_ == s[ -1 ]  # [#sg-020] newline is terminator not separator
            scn.gets
          end
          ( - ( end_d + 1 )).times do
            d = scn.gets
            d or break
          end
        end
        y = nil
        if d
          ( end_d - beg_d + 1 ).times do
            d_ = scn.gets
            if d_
              ( y ||= [] ).push s[ ( d_ + 1 ) .. d ]
              d = d_
            else
              ( y ||= [] ).push s[ 0 .. d ]
              break
            end
          end
        end
        if y
          y.reverse!
        end
        y
      end

      def backwards_index_stream s, sep
        d = s.length - 1
        p = -> do
          r = s.rindex sep, d
          if r
            d = r - 1
            if d < 0
              p = EMPTY_P_
            end
            r
          else
            p = EMPTY_P_ ; r
          end
        end

        Common_::Scn.new do
          p[]
        end
      end

      # ~ using a stateful scanner

      def expect_next_nonblank_line_is string
        advance_to_next_nonblank_line
        line.should eql string
      end

      def advance_to_rx rx
        expect_line_scanner.advance_to_rx rx
      end

      def advance_to_next_rx rx
        expect_line_scanner.advance_to_next_rx rx
      end

      def next_nonblank_line
        advance_to_next_nonblank_line and line
      end

      def next_line
        expect_line_scanner.next_line
      end

      def advance_to_next_nonblank_line
        expect_line_scanner.advance_to_next_rx NONBLANK_RX__
      end

      def line
        @expect_line_scanner.line
      end

      def expect_line_scanner
        @expect_line_scanner ||= __build_expect_line_scanner
      end

      def __build_expect_line_scanner

        st = line_stream_for_expect_line
        if st
          Expect_Line_::Scanner.via_stream st
        else
          Expect_Line_::Scanner.via_string @output_s
        end
      end

      attr_reader :line_stream_for_expect_line
    end

    NONBLANK_RX__ = /[^[:space:]]/
  end

  module Expect_Line

    say_not_same = -> act_s, exp_s do
      "expected, had: #{ exp_s.inspect }, #{ act_s.inspect }"
    end
    say_unexpected = -> s do
      "unexpected extra line - #{ s.inspect }"
    end
    say_missing = -> s do
      "missing expected line - #{ s.inspect }"
    end

    Expect_same_string = -> actual_s, expected_s, context do

      lib = Home_.lib_.basic::String

      Streams_have_same_content.call(
        lib.line_stream( actual_s ),
        lib.line_stream( expected_s ),
        context,
      )
    end

    Streams_have_same_content = -> actual_st, expected_st, context do

      begin
        act_s = actual_st.gets
        exp_s = expected_st.gets
        if act_s
          if exp_s
            if exp_s == act_s
              redo
            else
              fail say_not_same[ act_s, exp_s ]
            end
          else
            fail say_unexpected[ act_s ]
          end
        elsif exp_s
          fail say_missing[ exp_s ]
        else
          # (when they both end at the same moment, success)
          break
        end
      end while nil
      NIL_
    end

    class Scanner

      class << self

        def via_line_stream lines
          new lines
        end

        def via_string string
          new Home_.lib_.basic::String.line_stream string
        end

        def via_stream st
          new st
        end

        private :new
      end  # >>

      def initialize up
        @up = up
      end

      def members
        [ :advance_N_lines, :advance_to_next_rx,
          :advance_to_rx, :next_line, :skip_blank_lines ]
      end

      attr_reader :line

      # ~ advancing by a counting number of lines from current or end

      def advance_to_before_Nth_last_line d

        skip_until_before_Nth_last_line d
        @line
      end

      def skip_until_before_Nth_last_line d

        buff = Home_.lib_.basic::Rotating_Buffer[ d + 1 ]

        count = -1  # because our buffer runs for one more than the amt requested
        begin
          line = @up.gets
          line or break
          count += 1
          buff << line
          redo
        end while nil

        st = Common_::Stream.via_nonsparse_array buff.to_a

        @line = st.gets
        @up = st

        count
      end

      def advance_N_lines d
        line = nil
        d.times do
          line = @up.gets
        end
        @line = line
        line
      end

      def next_line
        @line = @up.gets
      end

      # ~ convenience macros for paraphernalia

      def expect_header sym

        s = expect_styled_line
        if s

          exp = "#{ sym }\n"
          if exp == s
            NIL_  # ok - multi-line style, with no trailing colon
          else

            exp_ = "#{ sym }:\n"
            if exp_ == s
              self._WHERE  # still used?
            else
              fail "expecting #{ exp.inspect } or #{ exp_.inspect }"
            end
          end
        end
      end

      def expect_styled_line

        @line = @up.gets
        if @line

          line = Home_.lib_.brazen::CLI_Support::Styling.unstyle_styled @line

          if line
            @line = line
            line
          else
            fail "not styled: #{ line.inspect }"
          end
        else
          fail "expected line, had none"
        end
      end

      # ~ advancing by searching for a regexp (positively or negatively)

      def << expected_s

        @line = @up.gets
        if @line
          if expected_s == @line
            self
          else
            fail "expected #{ expected_s.inspect }, had #{ @line.inspect }"
          end
        else
          fail "expected #{ expected_s.inspect }, had no more lines"
        end
      end

      def expect_nonblank_line

        @line = @up.gets
        BLANK_RX___ =~ @line and fail "expected nonblank, had #{ @line.inspect }"
        NIL_
      end

      def expect_blank_line

        @line = @up.gets
        BLANK_RX___ =~ @line or fail "not blank: #{ @line.inspect }"
        NIL_
      end

      def skip_blank_lines

        advance_past_lines_that_match BLANK_RX___
      end

      BLANK_RX___ = /\A[[:space:]]*\z/

      def advance_past_lines_that_match rx

        @line = @up.gets
        advance_to_not_rx rx
      end

      def advance_to_next_rx rx

        @line = @up.gets
        advance_to_rx rx
      end

      def advance_to_not_rx rx

        _count_from_advance_to_not_rx rx
        @line
      end

      def skip_lines_that_match rx

        @line = @up.gets
        _count_from_advance_to_not_rx rx
      end

      def _count_from_advance_to_not_rx rx

        count = 0
        begin
          @line or fail "never found a line that didn't match #{ rx.inspect }"
          if rx =~ @line
            count += 1
            @line = @up.gets
            redo
          end
          break
        end while nil
        count
      end

      def advance_to_rx rx

        begin
          @line or fail "never found before end of file: #{ rx.inspect }"
          md = rx.match @line
          md and break
          @line = @up.gets
          redo
        end while nil
        md
      end

      # ~ finish

      def finish
        count = 0
        begin
          if @up.gets
            count += 1
            redo
          end
          break
        end while nil
        count
      end

      def flush
        s = ""
        begin
          line = @up.gets
          line or break
          s.concat line
          redo
        end while nil
        s
      end

      def expect_no_more_lines
        @line = @up.gets
        if @line
          fail "expected no more lines, had #{ @line.inspect }"
        end
      end

      # ~ building fake files

      def build_fake_file_from_line_and_every_line_while_rx rx
        fake_lines = []
        begin
          fake_lines.push @line
          @line = @up.gets
          if @line && rx =~ @line
            redo
          end
        end while nil

        Fake_File__.new fake_lines
      end

      class Fake_File__

        def initialize a
          @a = a
        end

        def fake_open
          Common_::Stream.via_nonsparse_array @a
        end
      end
    end

    class File_Shell

      class << self
        alias_method :[], :new
      end

      def initialize path
        @path = path
        @content = ::File.read path
      end

      def contains str
        @content.include? str
      end
    end

    Expect_line::Expect_Line_ = self
  end
end
