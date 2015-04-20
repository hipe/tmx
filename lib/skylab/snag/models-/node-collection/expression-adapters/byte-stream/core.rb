module Skylab::Snag

  module Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      class << self
        def node_collection_via_upstream_identifier id, & oes_p

          Native_Collection___.new id
        end
      end  # >>

      class Native_Collection___  # or whatever

        def initialize id

          @byte_upstream_ID = id

          @extc_adptr = -> do
            x = __build_extc_adpr
            @extc_adptr = -> { x }
            x
          end
        end

        def to_node_stream & oes_p

          BS_::Actors_::Produce_node_upstream[
            self, @byte_upstream_ID, & oes_p ]
        end

        # ~

        def node_has_extended_content_via_node_id id

          @extc_adptr[].node_has_extended_content_via_node_id__ id
        end

        def __build_extc_adpr
          Expression_Adapters::Filesystem::Extended_Content_Adapter.
            new_via_manifest_path_and_filesystem(
              @byte_upstream_ID.path,
              Snag_.lib_.system.filesystem )
        end
      end

      Autoloader_[ Actors_ = ::Module.new ]

      BS_ = self
    end
  end
end
