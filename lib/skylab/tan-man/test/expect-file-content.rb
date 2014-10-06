module Skylab::TanMan

  class TestSupport::Expect_File_Content

    # assumes @output_s

    class << self
      def [] test_context_class
        test_context_class.include Test_Context_Instance_Methods__ ; nil
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
          self._TO_DO_excrpt_lines_from_beginning
        else
          false
        end
      end

      def excrpt_lines_from_end beg_d, end_d, s
        if s.length.nonzero?
          scn = backwards_index_scanner s, NEWLINE_
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

      def backwards_index_scanner s, sep
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
