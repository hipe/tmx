class Skylab::Task

  module MagneticsViz

    class Magnetics_::DotfileGraph_via_Graph

      def initialize graph, & oes_p
        @graph = graph
        @_oes_p = oes_p
      end

      def execute
        self  # for now
      end

      def express_into_under y, expag
        dup.__etc y, expag
      end

      def __etc y, exp
        @expression_agent = exp
        @yielder = y
        y << "digraph g {\n"
        y << "}\n"
      end
    end
  end
end
