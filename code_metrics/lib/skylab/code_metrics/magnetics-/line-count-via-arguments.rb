module Skylab::CodeMetrics

    class Magnetics_::Line_Count_via_Arguments

      attr_writer(
        :count_blank_lines,
        :count_comment_lines,
        :file_array,
        :label,
        :on_event_selectively,
        :system_conduit,
        :totaller_class
      )

      def execute

        filter_a = ___build_and_explain_filter_array

        has_filters = filter_a.length.nonzero?

        o = if has_filters
          Magnetics_::Line_Count_via_Grep_Chain.new
        else
          Magnetics_::Line_Count_via_WC.new
        end

        o.label = @label
        o.file_array = @file_array
        o.on_event_selectively = @on_event_selectively
        o.system_conduit = @system_conduit
        o.totaller_class = @totaller_class

        if has_filters
          o.filter_array = filter_a
        end

        # (no `finish_by` here, caller might customize its call)

        o.execute
      end

      def ___build_and_explain_filter_array

        filter_a = []
        o = Home_::Expression_Adapters_::Human::Conjuncter.new

        if @count_blank_lines

          o.add :include, :blank_line

        else

          o.add :exclude, :blank_line
          filter_a << "grep -v '^[ \t]*$'"
        end

        if @count_comment_lines

          o.add :include, :comment_line

        else

          o.add :exclude, :comment_line
          filter_a << "grep -v '^[ \t]*#'"
        end

        @on_event_selectively.call :info, :data, :linecount_NLP_frame do | y |
          o
        end

        filter_a
      end
    end
  # -
end
