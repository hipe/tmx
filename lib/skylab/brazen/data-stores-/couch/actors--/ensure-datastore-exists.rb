module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Ensure_datastore_exists < Data_Store_::Actor

      Actor_[ self, :properties,
        :entity, :listener ]

      def execute
        @entity.put EMPTY_S_,
          :entity_identifier_strategy, :none,
          :channel, :ensure_exists, :delegate, self
      end

    public

      def ensure_exists_when_201_created _
        _ev = build_event_with :created_database, :description_s,
          @entity.description, * @entity.to_iambic, :ok, true
        @listener.receive_success_event _ev
      end

      def ensure_exists_when_412_precondition_failed o
        _ev = o.response_body_to_error_event
        @listener.receive_error_event _ev
      end
    end
  end
end
