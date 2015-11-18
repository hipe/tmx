module Skylab::Snag

  class Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      # ~ for use with Expression_Agent_ below

      DEFAULT_WIDTH_ = 79
      DEFAULT_SUB_MARGIN_WIDTH_ = ' #open '.length
      DEFAULT_IDENTIFIER_INTEGER_WIDTH_ = 3

      # ~

      class << self

        def build_default_expression_agent
          Expression_Agent_.new(
            DEFAULT_WIDTH_,
            DEFAULT_SUB_MARGIN_WIDTH_,
            DEFAULT_IDENTIFIER_INTEGER_WIDTH_ )
        end

        def node_collection_via_upstream_identifier_ id, & oes_p

          Native_Collection___.new id
        end
      end  # >>

      class Native_Collection___ < NC_  # or whatever

        def initialize id

          @byte_upstream_ID = id

          @extc_adptr = -> do
            x = __build_extc_adpr
            @extc_adptr = -> { x }
            x
          end

          @_FS_adapter = Home_.application_kernel_.silo(
            :node_collection
          ).FS_adapter_
        end

        # ~ for [#ac-002] the ACS (compliments same in parent class)

        def __add__component bx, node, ca, & oes_p

          persist_entity bx, node, & oes_p
        end

        def result_for_component_mutation_session_when_changed log, &__

          log.last_delivery_result || self._COVER_ME
        end

        # c r u d

        # ~ create / update

        def persist_entity bx, node, & x_p  # per [#br-011] in [#038] (pseudocode)

          o = start_sessioner( & x_p )

          o.downstream_identifier = bx && bx[ :downstream_identifier ]

          o.subject_entity = node

          o.during_locked_write_session do | sess |

            __mutate_collection bx, node, sess, & x_p
          end
        end

        def start_sessioner & x_p

          o = BS_::Sessions_::Rewrite_Stream_End_to_End.new( & x_p )
          o.collection = self
          o.expression_adapter_actor_box = BS_::Actors_
          o.FS_adapter = @_FS_adapter
          o
        end

        def __mutate_collection bx, node, sess, & x_p

          if bx[ :try_to_reappropriate ]

            sess.mutate_collection_and_subject_entity_by_reappropriation
          end

          _ok = sess.against_collection_add_or_replace_subject_entity

          _ok && sess.subject_entity
        end

        # ~ retrieve one

        def entity_via_intrinsic_key node_id_x, & oes_p

          id = Home_::Models_::Node_Identifier.new_via_user_value(
            node_id_x, & oes_p )

          id and entity_via_identifier_object id, & oes_p
        end

        def entity_via_identifier_object id_o, & oes_p

          st = to_entity_stream( & oes_p )

          st and begin

            node = __first_by st do | node_ |
              id_o == node_.ID
            end

            node or begin

              oes_p.call :error, :component_not_found do
                __build_enity_not_found_event id_o
              end
            end
          end
        end

        def __build_enity_not_found_event id_o

          Brazen_.event( :Component_Not_Found ).new_with(

            :component, id_o,
            :component_association, Models_::Node,
            :ACS, @byte_upstream_ID,
          )
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

        # ~ retrieve many ( counterpart to [#br-032] to_entity_stream_via_model )

        def to_entity_stream & oes_p  #

          BS_::Actors_::Produce_node_upstream[
            self, @byte_upstream_ID, & oes_p ]
        end

        def upstream_identifier
          @byte_upstream_ID
        end

        # ~ extended content & filesystem

        def node_has_extended_content_via_node_ID id

          @extc_adptr[].node_has_extended_content_via_node_ID__ id
        end

        def any_extended_content_filename_via_node_ID id

          @extc_adptr[].any_extended_content_filename_via_node_ID__ id
        end

        def __build_extc_adpr

          bu_id = @byte_upstream_ID
          if bu_id.respond_to? :path

            Expression_Adapters::Filesystem::Extended_Content_Adapter.
              new_via_manifest_path_and_filesystem(
                bu_id.path, @_FS_adapter.filesystem )
          else
            EC_Adapter_Dummy___[]
          end
        end

        EC_Adapter_Dummy___ = Callback_.memoize do
          o = ::Object.new
          o.send :define_singleton_method,
              :node_has_extended_content_via_node_ID__ do | _ |
            false
          end
          o
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

        def new_expression_context
          # (note the expags for [br] API and CLI implement this too
          # and you might want to be using those instead..)
          ::String.new
        end
      end

      Autoloader_[ Actors_ = ::Module.new ]
      Brazen_ = Home_.lib_.brazen
      BS_ = self
    end
  end
end
