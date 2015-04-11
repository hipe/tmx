module Skylab::Snag

  module Models_::Node_Collection

    Expression_Adapters = ::Module.new

    module Expression_Adapters::Byte_Stream

      class << self
        def node_collection_via_upstream_identifier id, & oes_p

          Native_Collection___.new id
        end
      end  # >>

      class Native_Collection___  # or whatever

        def initialize id

          @path_identifier = id
        end

        def to_node_stream & oes_p

          BS_::Actors_::Produce_node_upstream[ @path_identifier, & oes_p ]
        end
      end

      Autoloader_[ Actors_ = ::Module.new ]

      BS_ = self
    end
  end
end
