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
    end
  end
end
