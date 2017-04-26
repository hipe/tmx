module Skylab::TanMan

  class Models_::Node

    class Actions::Ls

      def definition
        _these = Home_::DocumentMagnetics_::CommonAssociations.to_workspace_related_stream_
        [
          :properties, _these,
        ]
      end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
      end

      def execute
        with_immutable_digraph_ do
          __via_immutable_digraph
        end
      end

      def __via_immutable_digraph

        fly = Here_.new_flyweight__

        _st = @_immutable_digraph_.graph_sexp.to_node_stream

        _st.map_by do |node|
          fly.reinit_as_flyweight__ node
        end
      end

      if false
      def with_immutable_digraph_
        if instance_variable_defined? :@_immutable_digraph_
          yield
        else
          super
        end
      end

      attr_writer(
        :_immutable_digraph_,
      )
      end

      # ==
      # ==
    end
  end
end
# #history: broke out of main model file (and full rewrite)
