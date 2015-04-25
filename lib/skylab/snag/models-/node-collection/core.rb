module Skylab::Snag

  class Models_::Node_Collection

    class << self

      def new_via_upstream_identifier x, & oes_p

        if x.respond_to? :to_simple_line_stream

          _new_via_upstream_identifier x, & oes_p
        else

          # (the current fallback assumption is that this is an FS path)
          new_via_path x, & oes_p
        end
      end

      def new_via_path path, & oes_p

        _id = Snag_.lib_.
          system.filesystem.class::Byte_Upstream_Identifier.new path

        _new_via_upstream_identifier _id, & oes_p
      end

      def _new_via_upstream_identifier id, & oes_p

        expression_adapter_( id.modality_const ).

          node_collection_via_upstream_identifier_( id, & oes_p )
      end

      def expression_adapter_ modality_const

        NC_::Expression_Adapters.const_get modality_const, false
      end
    end  # >>

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
