module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Touch_datastore < Couch_Actor_

      Actor_[ self, :properties,
        :entity,
        :event_receiver ]

      def execute
        init_response_receiver_for_self_on_channel :ensure_exists
        @entity.put EMPTY_S_,
          :entity_identifier_strategy, :__N_O_N_E__,
          :response_receiver, @response_receiver
      end

    public

      def ensure_exists_when_201_created _
        _ev = build_OK_event_with :created_datastore, :description,
          @entity.description, * @entity.to_even_iambic
        send_event _ev
        ACHIEVED_
      end

      def ensure_exists_when_412_precondition_failed o
        _ev = build_OK_event_with :datastore_exists, :description,
          @entity.description, * @entity.to_even_iambic
        send_event _ev
        nil
      end
    end
  end
end
