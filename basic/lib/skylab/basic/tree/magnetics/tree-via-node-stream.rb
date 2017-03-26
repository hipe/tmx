module Skylab::Basic

  module Tree

    Magnetics::Tree_via_NodeStream = -> in_st do

      root = Here_::Mutable.new

      begin
        id = in_st.gets
        id or break
        root.touch_node(
          id.to_tree_path,
          :leaf_node_payload_proc, -> do
            id
          end,
        )
        redo
      end while nil

      root
    end

    # ==
    # ==
  end
end
