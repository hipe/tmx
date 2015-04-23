module Skylab::Snag

  module Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      class Actors_::Replace_node

        Callback_::Actor.call self, :properties, :bx, :node, :collection

        def execute

          BS_::Sessions_::Rewrite_Stream_End_to_End.new(

            @bx, @node, @collection, & @on_event_selectively

          ).session do | o |

            o.write_each_node_until_the_subject_node_is_found
            o.write_the_new_node
            o.write_the_remaining_nodes

          end
        end
      end
    end
  end
end
