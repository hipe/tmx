module Skylab::Snag

  class Models_::Node_Collection

    if false

    def changed node, is_dry_run, verbose_x
      node.delegate or self._SANITY
      @manifest.change_node node, is_dry_run, verbose_x
    end

    def when_not_found delegate
      _ev = Snag_::Model_::Event.inline :node_not_found, :query, @q do |y, o|
        y << "there is no node #{ o.query.phrasal_noun_modifier }"
      end
      delegate.receive_error_event _ev
    end
    end

    class Silo_Daemon

      def initialize kr, mc
        @kernel = kr
        @model_class = mc
        freeze
      end

      def node_collection_via_upstream_identifier x, & oes_p

        id = if x.respond_to? :to_simple_line_stream
          x

        else  # the current fallback assumption is that this is an FS path

          Snag_.lib_.system.filesystem.class::Byte_Upstream_Identifier.new x
        end

        NC_::Expression_Adapters.const_get( id.modality_const, false ).
          node_collection_via_upstream_identifier( id, & oes_p )
      end
    end

    def edit * x_a, & x_p

      Snag_::Model_::Collection::Mutation_Session.call x_a, self, & x_p
    end

    def __node__class_for_mutation_session
      Snag_::Models_::Node
    end

    def mutable_body_for_mutation_session_by _
      self
    end

    module Expression_Adapters
      EN = nil
      Autoloader_[ self ]
    end

    Actions = THE_EMPTY_MODULE_
    NC_ = self

  end
end
