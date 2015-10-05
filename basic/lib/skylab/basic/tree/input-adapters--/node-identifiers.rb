module Skylab::Basic

  module Tree

    # ->

      Input_Adapters__::Node_identifiers = -> upstream_x do

        root = Tree_::Mutable_.new

        upstream_x.each do | identifier |

          root.touch_node identifier.to_tree_path,
            :leaf_node_payload_proc, -> do
              identifier
            end
        end

        root
      end

      # <-
  end
end
