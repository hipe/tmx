module Skylab::Basic

  module Tree

    Magnetics::Tree_via_NodeIdentifiers = -> upstream_x do

        root = Here_::Mutable.new

        upstream_x.each do |identifier|

          root.touch_node identifier.to_tree_path,
            :leaf_node_payload_proc, -> do
              identifier
            end
        end

        root

    end

    # ==
    # ==
  end
end
