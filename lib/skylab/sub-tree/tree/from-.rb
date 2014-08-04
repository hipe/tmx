module Skylab::SubTree

  module Tree

    H__ = {
      hash: -> { Tree::From_hash_ },
      paths: -> { Tree::From_paths_ },
      path_nodes: -> { Tree::From_path_nodes__ }
    }.freeze

    From_ = -> *a do
      H__.fetch( a.fetch( 2 ) ).call[ *a ]
    end
  end
end
