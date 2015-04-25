module Skylab::Snag

  class Models_::Criteria

    Brazen_ = Snag_.lib_.brazen

    Actions = ::Module.new

    class Actions::To_Stream < Brazen_::Model.common_action_class

      Brazen_::Model.common_entity self,

        :required,
        :property, :upstream_identifier,

        :required,
        :argument_arity, :one_or_more,
        :property, :criteria

      def produce_result

        c = Criteria_.new @kernel, & handle_event_selectively

        h = @argument_box.h_

        ok = c.receive_criteria_expression h.fetch( :criteria )

        if ok

          c.to_reduced_entity_stream_via_collection_identifier(
            h.fetch( :upstream_identifier ) )
        else
          ok
        end
      end
    end

    class Silo_Daemon

      def initialize kr, _mod

        @EN_domain_adapter = Criteria_::Library_::Domain_Adapter.
          new_via_kernel_and_NLP_const( kr, :EN )

      end

      attr_reader :EN_domain_adapter
    end

    # -> ( criteria model )

      def initialize k, & oes_p

        @kernel = k
        @on_event_selectively = oes_p
        @ok = true
      end

      def receive_criteria_expression x

        _ct = if x.respond_to? :value_x
          x
        else

          @kernel.silo( :criteria ).EN_domain_adapter.
            new_criteria_tree_via_word_array(
              x, & @on_event_selectively )
        end

        _receive _ct, :criteria_tree
      end

      def __receive_trueish__criteria_tree__ ct

        @criteria_tree =  ct

        _mc = @kernel.unbound_via_normal_identifier(
          @criteria_tree.name_x )

        remove_instance_variable :@kernel  # ick/meh

        _receive _mc, :model_class
      end

      def __receive_trueish__model_class__ mc

        @model_class = mc

        _expad = mc::Expression_Adapters::Criteria_Tree

        _receive _expad, :expression_adapter
      end

      def to_proc
        @_criteria_proc
      end

      def __receive_trueish__expression_adapter__ expad

        _lookup_p = expad.method :lookup_associated_model_

        @_criteria_proc = @criteria_tree.value_x.to_criteria_proc_under_ _lookup_p

        ACHIEVED_
      end

      def to_reduced_entity_stream_via_collection_identifier id_x

        col = @model_class.collection_module_for_criteria_resolution.

          new_via_upstream_identifier( id_x, & @on_event_selectively )

        if col
          to_reduced_entity_stream_against_collection col
        else
          col
        end
      end

      def to_reduced_entity_stream_against_collection col

        st = col.to_entity_stream( & @on_event_selectively )

        if st
          __to_reduced_entity_stream_against_entity_stream st
        else
          st
        end
      end

      def __to_reduced_entity_stream_against_entity_stream st

        p = @_criteria_proc

        st.reduce_by do | node |
          p[ node ]
        end
      end

      def _receive x, sym

        if x
          send :"__receive_trueish__#{ sym }__", x
        else
          @ok = x
          x
        end
      end

      # <-

    module Expression_Adapters
      EN = nil
    end

    Criteria_ = self
  end
end
