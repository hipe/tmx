module Skylab::SubTree

  module Tree

    H__ = {
      hash: -> { Tree::From_hash_ },
      paths: -> { Tree::From_paths_ },
      path_nodes: -> { Tree::From_path_nodes__ }
    }.freeze

    From_ = -> x_a do
      H__.fetch( x_a.fetch 2 )[].call_via_iambic x_a
    end
  end
end
