module Skylab::Snag

  module Models_::Criteria

    Actions = ::Module.new

    Brazen_ = Snag_.lib_.brazen

    class Actions::To_Stream < Brazen_::Model.common_action_class

      Brazen_::Model.common_entity self,

        :required,
        :property, :upstream_identifier,

        :required,
        :argument_arity, :one_or_more,
        :property, :criteria

      def produce_result

        h = @argument_box.h_  # we might mutate this

        @kernel.silo( :criteria ).EN_domain_adapter.
          produce_result_for_query_via_word_array(
            h.fetch( :criteria ), h, & handle_event_selectively )

      end
    end

    class Silo_Daemon

      def initialize kr, _mod

        @EN_domain_adapter = Criteria_::Library_::Domain_Adapter.
          new_via_kernel_and_NLP_const( kr, :EN )

      end

      attr_reader :EN_domain_adapter
    end

    module Expression_Adapters
      EN = nil
    end

    Criteria_ = self
  end
end
