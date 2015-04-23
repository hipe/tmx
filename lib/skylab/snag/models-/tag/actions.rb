module Skylab::Snag

  class Models_::Tag

    Actions = ::Module.new

    class Actions::To_Stream < Brazen_::Model.common_action_class

      Brazen_::Model.common_entity self,

        :desc, -> y do
          y << 'list the tags for a given node.'
        end,

        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier

      def produce_result

        _oes_p = handle_event_selectively

        @node = @kernel.call_via_mutable_box :node, :to_stream,

          :identifier, @argument_box.remove( :node_identifier ),

          @argument_box,
          & _oes_p

        @node and __via_node
      end

      def __via_node
        @node.to_tag_stream
      end
    end
  end
end
