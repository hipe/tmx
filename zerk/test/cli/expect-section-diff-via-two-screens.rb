module Skylab::Zerk::TestSupport

  class CLI::ExpectSectionDiff_via_TwoScreens < Common_::Actor::Dyadic

    # assume that the two toplevel arguments being compared behave as
    # platform Struct's, and have the same members..

    # -

      def initialize left, right
        @left = left ; @right = right
      end

      def execute

        # (left is the "self", right is the "other")
        # (in one use case, left is the expected and right is the actual)

        _expected_st = Line_stream_via_sections_struct__[ @left ]
        _actual_st = Line_stream_via_sections_struct__[ @right ]

        diff = Diff_via_streams__[ _expected_st, _actual_st ]
        if diff.is_the_empty_diff
          THE_EMPTY_TOPIC_DIFF___
        else
          __complicated_money diff
        end
      end

      def __complicated_money diff
        HelpScreenDiff___.new diff
      end
    # -
    # ==

    class HelpScreenDiff___

      def initialize diff
        @diff = diff
      end

      def to_exception_message  # CODE SKETCH
        st = diff.to_hunk_stream
        st.gets  # ignore diff header
        _hunk = st.gets
        run_st = _hunk.to_run_stream
        buffer = ""
        4.times do
          # (the first four runs is hopefully a hunk header, some context
          # lines, maybe a minus and maybe a plus..)
          run = run_st.gets
          run || break
          run.to_line_stream.each { |line| buffer << line }
        end
        buffer
      end

      def is_the_empty_diff_of_screens
        false
      end
    end

    module THE_EMPTY_TOPIC_DIFF___ ; class << self
      def is_the_empty_diff_of_screens
        true
      end
    end ; end

    # ==

    Line_stream_via_sections_struct__ = -> sct do
      Stream_[ sct.members ].expand_by do |m|
        sect = sct[ m ]
        if sect
          Line_stream_via_section__[ sect ]
        end
      end
    end

    rx = %r((?:\n|\r\n\?)\z)
    Line_stream_via_section__ = -> sect do
      Stream_.call sect.emissions do |em|
        s = em.string
        rx =~ s ? s : "#{ s }#{ NEWLINE_ }"
      end
    end

    Diff_via_streams__ = -> left_line_stream, right_line_stream do
      Home_.lib_.system.diff.by do |o|
        o.left_line_stream = left_line_stream
        o.right_line_stream = right_line_stream
      end
    end


    # ==
  end
end
# #born for [tmx] testing that two help screens are identical
