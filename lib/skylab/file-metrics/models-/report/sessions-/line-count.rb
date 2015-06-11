module Skylab::FileMetrics

  class Models_::Report

    class Sessions_::Line_Count

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

        filter_a = __develop_filter

        yes = filter_a.length.nonzero?
        o = if yes
          Sessions_::Line_Count_via_Grep_Chain.new
        else
          Sessions_::Line_Count_via_WC.new
        end

        o.label = @label
        o.file_array = @file_array
        o.on_event_selectively = @on_event_selectively
        o.system_conduit = @system_conduit
        o.totaller_class = @totaller_class

        if yes
          o.filter_array = filter_a
        end

        # (no `collapse_and_distribute` here, caller might customize its call)
        o.execute

      end

      def __develop_filter

        filter_a = []
        o = Sessions_::Conjuncter.new

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

        @on_event_selectively.call :info, :expression, :linecount_conj_p do | y |

          y_ = o.express_into_line_context []
          y_.fetch( 0 )[ 0, 0 ] = '('
          y_.fetch( -1 ).concat ')'
          y_.each( & y.method( :<< ) )
          y
        end

        filter_a
      end
    end
  end
end
