module Skylab::Snag

  module Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      class Actors_::Replace_node

        Callback_::Actor.call self, :properties, :bx, :node, :collection

        def execute

          o = BS_::Sessions_::Rewrite_Stream_End_to_End.new(
            @bx, @node, @collection, & @on_event_selectively )

          ok = o.start_the_output_stream
          ok &&= o.write_each_node_until_the_subject_node_is_found
          ok &&= o.write_the_new_node
          ok &&= o.write_the_remaining_nodes
          ok && o.finish_the_output_stream

        end
      end
    end
  end
end
