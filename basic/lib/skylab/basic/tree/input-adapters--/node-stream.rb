module Skylab::Basic

  module Tree

    Input_Adapters__::Node_Stream = -> in_st do

      root = Tree_::Mutable_.new

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
  end
end
