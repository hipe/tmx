module Skylab::Snag

  class Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      class << self

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

          @_filesystem = Snag_.lib_.system.filesystem
        end

        # ~ interface with the mutation session (compliments those in parent clas)

        def mutable_body_for_mutation_session
          self
        end

        def receive_changed_during_mutation_session
          # nothing.
          ACHIEVED_
        end

        def __add__object_for_mutation_session bx, node, & oes_p

          persist_entity bx, node, & oes_p
        end

        # c r u d

        # ~ create / update

        def persist_entity bx, node, & x_p  # per [#br-011] in [#038] (pseudocode)

          o = BS_::Sessions_::Rewrite_Stream_End_to_End.new( & x_p )

          o.collection = self

          o.downstream_identifier = bx && bx[ :downstream_identifier ]

          o.filesystem = @_filesystem

          o.tmpdir_path_proc = -> do  # (or push this up however)

            ::File.join Snag_.lib_.system.defaults.dev_tmpdir_path, 'sn0g'

          end

          o.subject_entity = node

          o.during_locked_write_session do | sess |

            __mutate_collection bx, node, sess, & x_p
          end
        end

        def __mutate_collection bx, node, sess, & x_p

          p = bx[ :_mutate_node ]
          if p
            _node = p[ node, sess, & x_p ]
            node = _node
            sess.replace_subject_entity _node
          end

          if node

            ok  = if node.ID
              BS_::Actors_::Replace_node[ sess, & x_p ]
            else
              BS_::Actors_::Add_node[ sess, & x_p ]
            end

            if ok
              # when the operaion succeeds, we result in the subject entity
              sess.subject_entity
            end
          else
            node
          end
        end

        # ~ retrieve one

        def entity_via_intrinsic_key node_id_x, & oes_p

          id = Snag_::Models_::Node_Identifier.new_via_user_value(
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

        # ~ retrive many ( counterpart to [#br-032] to_entity_stream_via_model )

        def to_entity_stream & oes_p  #

          BS_::Actors_::Produce_node_upstream[
            self, @byte_upstream_ID, & oes_p ]
        end

        def upstream_identifier
          @byte_upstream_ID
        end

        # ~ extended content & filesystem

        def node_has_extended_content_via_node_id id

          @extc_adptr[].node_has_extended_content_via_node_id__ id
        end

        def __build_extc_adpr

          bu_id = @byte_upstream_ID
          if bu_id.respond_to? :path

            Expression_Adapters::Filesystem::Extended_Content_Adapter.
              new_via_manifest_path_and_filesystem(
                bu_id.path, @_filesystem )
          else
            EC_Adapter_Dummy___[]
          end
        end

        EC_Adapter_Dummy___ = Callback_.memoize do
          o = ::Object.new
          o.send :define_singleton_method,
              :node_has_extended_content_via_node_id__ do | _ |
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
      end

      Autoloader_[ Actors_ = ::Module.new ]
      Brazen_ = Snag_.lib_.brazen
      BS_ = self
    end
  end
end
