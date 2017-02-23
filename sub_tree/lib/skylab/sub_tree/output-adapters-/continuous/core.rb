module Skylab::SubTree

  class OutputAdapters_::Continuous

    Attributes_actor_.call( self,
      :upstream_tree,
      :output_line_downstream_yielder,
      :info_line_downstream_yielder,
      :do_verbose_lines,
    )

    def initialize
      @do_verbose_lines = false
      super
    end

    def execute

      es = Expression_State___.new(
        @do_verbose_lines,
        @info_line_downstream_yielder,
        @output_line_downstream_yielder )

      @upstream_tree.express_tree_against es

      es.flush__

      NIL_
    end

    class Expression_State___

      def initialize do_verbose_lines, info_y, down_y

        @down_y = down_y

        @stack_label_x_a = []

        @traversal = Continuous_::Traversal.with(
          :do_verbose_lines, do_verbose_lines,
          :output_proc, method( :__three_from_traversal )

        ) do | * i_a, & ev_p |
          self._WAHOO
        end
      end

      def __three_from_traversal glyph_s_a, slug_s, xtra_s

        if glyph_s_a.length.nonzero?
          sp = SPACE_
        end

        @down_y <<
          "#{ glyph_s_a * EMPTY_S_ }#{ sp }#{ slug_s }#{ xtra_s }#{ NEWLINE_ }"

        NIL_
      end

      def node_label s

        @last_label = s
        @traversal << [ * @stack_label_x_a, s ]
        NIL_
      end

      def branch

        @stack_label_x_a << @last_label
        yield
        @stack_label_x_a.pop
        NIL_
      end

      def flush__
        @traversal.flush
        NIL_
      end
    end

    Continuous_ = self
  end
end
