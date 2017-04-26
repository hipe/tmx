module Skylab::Snag

  class Models_::NodeCollection

    module ExpressionAdapters::ByteStream

      # ~ for use with ByteStreamExpressionAgent below

      DEFAULT_WIDTH_ = 79
      DEFAULT_SUB_MARGIN_WIDTH_ = ' #open '.length
      DEFAULT_IDENTIFIER_INTEGER_WIDTH_ = 3

      # ~

      class << self

        def build_default_expression_agent
          ByteStreamExpressionAgent.new(
            DEFAULT_WIDTH_,
            DEFAULT_SUB_MARGIN_WIDTH_,
            DEFAULT_IDENTIFIER_INTEGER_WIDTH_ )
        end

        def node_collection_via_upstream_reference__ id, invo_rsx

          Native_Collection___.new id, invo_rsx
        end
      end  # >>

      class Native_Collection___ < Here_  # or whatever

        def initialize id, invo_rsx

          @_invocation_resources = invo_rsx

          @byte_upstream_ID = id
        end

        # ~ for [#ac-002] the ACS (compliments same in parent class)

        def __add__component cx, qk, & oes_p_p

          node = qk.value_x

          _oes_p = oes_p_p[ node ]  # transition from hot to cold

          persist_entity cx, node, & _oes_p
        end

        # c r u d

        # ~ create / update

        def persist_entity cx, node, & x_p  # per [#br-011] in [#038] (pseudocode)

          if cx
            _ds_x = cx._snag_downstream_reference_
          end

          _sessioner = sessioner_by do |o|

            o.downstream_reference = _ds_x
            o.subject_entity = node
            o.listener = x_p
          end

          _sessioner.during_locked_write_session do |sess|

            __mutate_collection cx, node, sess, & x_p
          end
        end

        def sessioner_by

          Here_::Magnetics_::EndToEndRewrite_via_Arguments.define do |o|
            yield o
            o.collection = self
            o.expression_adapter_actor_box = Here_::Magnetics_
            o.invocation_resources = @_invocation_resources
          end
        end

        def __mutate_collection cx, node, sess, & x_p

          if cx._snag_try_to_reappropriate_

            sess.mutate_collection_and_subject_entity_by_reappropriation
          end

          _ok = sess.against_collection_add_or_replace_subject_entity

          _ok && sess.subject_entity
        end

        # ~ retrieve one

        def entity_via_intrinsic_key node_id_x, & oes_p

          id = Models_::NodeIdentifier.via_user_value_(
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
              UNABLE_
            end
          end
        end

        def __build_enity_not_found_event id_o

          Home_.lib_.autonomous_component_system::Events::ComponentNotFound.with(

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

          Here_::Magnetics_::NodeStream_via_LineStream.call(
            self, @byte_upstream_ID, & oes_p )
        end

        def upstream_reference
          @byte_upstream_ID
        end

        # ~ extended content & filesystem

        def node_has_extended_content_via_node_ID id

          _extc_adapter.node_has_extended_content_via_node_ID__ id
        end

        def any_extended_content_filename_via_node_ID id

          _extc_adapter.any_extended_content_filename_via_node_ID__ id
        end

        def _extc_adapter
          @__extc_adapter ||= __extc_adapter
        end

        def __extc_adapter

          bu_id = @byte_upstream_ID
          if bu_id.respond_to? :path

            _fsa = @_invocation_resources.node_collection_filesystem_adapter

            ExpressionAdapters::Filesystem::ExtendedContentAdapter.
              via_manifest_path_and_filesystem bu_id.path, _fsa.filesystem
          else
            THE_EMPTY_EC_ADAPTER___
          end
        end

        module THE_EMPTY_EC_ADAPTER___ ; class << self
          def node_has_extended_content_via_node_ID__ _
            FALSE
          end
        end ; end
      end

      class ByteStreamExpressionAgent

        def initialize d, d_, d__

          @identifier_integer_width = d__
          @sub_margin_width = d_
          @width = d
          @modality_const = :ByteStream
        end

        attr_reader :identifier_integer_width, :modality_const,
          :sub_margin_width, :width

        def new_expression_context
          # (note the expags for [br] API and CLI implement this too
          # and you might want to be using those instead..)
          ::String.new
        end
      end
      Brazen_ = Home_.lib_.brazen
      Here_ = self
    end
  end
end
