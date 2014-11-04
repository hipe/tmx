module Skylab::SubTree

  module Tree_Print

    def self.tree_print obj, out, * x_a  # 'do_verbose_lines', 'info_p'
      _puts_p = out.respond_to?( :puts ) ? out.method( :puts ) : out
      ctx = Kernel__.new _puts_p, x_a
      obj.tree_print ctx
      ctx.flush ; nil
    end

    class Kernel__

      def initialize out_line_p, x_a
        @stack_label_x_a = []
        @out_line_p = out_line_p
        @traversal = SubTree_::API::Actions::My_Tree::Traversal_.
          new :out_p, method( :three_from_traversal ), * x_a
      end

      def node_label s
        @last_label = s
        a = [ * @stack_label_x_a, s ]
        @traversal << a  ; nil
      end

      def branch
        @stack_label_x_a << @last_label
        yield
        @stack_label_x_a.pop ; nil
      end

      def flush
        @traversal.flush ; nil
      end

    private

      def three_from_traversal glyphs_s_a, slug_s, xtra_s
        glyphs_s_a.length.nonzero? and sp = SPACE_
        @out_line_p[ "#{ glyphs_s_a * EMPTY_S_ }#{ sp }#{ slug_s }#{ xtra_s }" ]
        nil
      end
    end
  end
end
