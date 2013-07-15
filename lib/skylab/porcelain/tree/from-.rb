module Skylab::Porcelain

  module Tree

    H_ = {
      paths: -> { Tree::From_paths_ },
      hash: -> { Tree::From_hash_ }
    }.freeze

    From_ = -> *a do
      H_.fetch( a.fetch( 2 ) ).call[ *a ]
    end
  end
end
