module Skylab::TestSupport

  class Expect_line

    # assumes @output_s

    class << self

      def [] test_context_class
        test_context_class.include Test_Context_Instance_Methods__ ; nil
      end

      def shell output_s
        Shell__.new output_s
      end
    end

    Test_Context_Instance_Methods__ = ::Module.new

    class Shell__

      include Test_Context_Instance_Methods__

      def initialize s
        @output_s = s
      end
    end

    module Test_Context_Instance_Methods__

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

        _RX = TestSupport_._lib.string_lib.regex_for_line_scanning

        scnr = TestSupport_::Library_::StringScanner.new s

        y = []
        current_line_index = 0
        while current_line_index < beg_d
          current_index += 1
          if ! scnr.skip _RX
            y = false
            break
          end
        end
        if y
          while current_line_index <= end_d
            current_line_index += 1
            s = scnr.scan _RX
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

        Callback_::Scn.new do
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
        expect_line_scanner.next_line_
      end

      def advance_to_next_nonblank_line
        expect_line_scanner.advance_to_next_rx NONBLANK_RX__
      end

      def line
        @expect_line_scanner.line
      end

      def expect_line_scanner
        @expect_line_scanner ||= Expect_Line::Scanner.via_string( @output_s )
      end
    end

    NONBLANK_RX__ = /[^[:space:]]/
  end

  module Expect_Line

    class Scanner

      class << self

        def via_line_stream lines
          new lines
        end

        def via_string string
          new TestSupport_._lib.string_lib.line_stream string
        end

        private :new
      end

      def initialize up
        @up = up
      end

      attr_reader :line

      def next_line_
        @line = @up.gets
      end

      def advance_to_next_rx rx
        @line = @up.gets
        advance_to_rx rx
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

      def skip_blank_lines
        begin
          @line = @up.gets
          if BLANK_RX__ =~ @line
            redo
          else
            break
          end
        end while nil
      end

      BLANK_RX__ = /\A[[:space:]]*\z/

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
          Callback_.stream.via_nonsparse_array @a
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
  end
end
