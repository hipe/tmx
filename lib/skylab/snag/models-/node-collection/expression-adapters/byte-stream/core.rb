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

        # c r u d

        # ~ create / update

        def persist_entity bx, node, & oes_p  # per [#br-011] in [#038] (pseudocode)

          if node.ID
            BS_::Actors_::Replace_node.call bx, node, self, & oes_p
          else
            BS_::Actors_::Add_node.call bx, node, self, & oes_p
          end
        end

        # ~ retrieve one

        def entity_via_intrinsic_key node_id_x, & oes_p

          id = Snag_::Models_::Node_Identifier.try_convert(
            node_id_x, & oes_p )

          id and entity_via_identifier_object id, & oes_p
        end

        def entity_via_identifier_object id_o, & oes_p

          st = to_node_stream( & oes_p )

          st and begin

            node = __first_by st do | node_ |
              id_o == node_.ID
            end

            node or begin

              oes_p.call :error, :entity_not_found do
                __build_enity_not_found_event id_o
              end
            end
          end
        end

        def __build_enity_not_found_event id_o

          Brazen_::Model.common_events::Entity_Not_Found.new_with(
            :identifier, id_o,
            :model, Snag_::Models_::Node,
            :describable_source, @byte_upstream_ID )
        end

        def __first_by st, & p

          begin
            node = st.gets
            node or break

            _yes = p[ node ]
            if _yes
              st.upstream.release_resource
              break
            end
            redo
          end while nil
          node
        end

        # ~ retrive many ( counterpart to [#br-032] entity_stream_via_model )

        def to_node_stream & oes_p  #

          BS_::Actors_::Produce_node_upstream[
            self, @byte_upstream_ID, & oes_p ]
        end

        def upstream_identifier
          @byte_upstream_ID
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

      class Expression_Agent_

        def initialize d, d_, d__

          @identifier_integer_width = d__
          @sub_margin_width = d_
          @width = d
          @modality_const = :Byte_Stream
        end

        attr_reader :identifier_integer_width, :modality_const,
          :sub_margin_width, :width
      end

      Autoloader_[ Actors_ = ::Module.new ]
      Brazen_ = Snag_.lib_.brazen
      BS_ = self
    end
  end
end
