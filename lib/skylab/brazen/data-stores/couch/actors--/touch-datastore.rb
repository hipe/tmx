module Skylab::Brazen

  class Data_Stores::Couch

    class Actors__::Touch_datastore < Couch_Actor_

      Actor_.call self, :properties,
        :entity

      def execute
        init_response_receiver_for_self_on_channel :ensure_exists
        @entity.put EMPTY_S_,
          :entity_identifier_strategy, :__N_O_N_E__,
          :response_receiver, @response_receiver
      end

    public

      def ensure_exists_when_201_created _
        @on_event_selectively.call :info, :created_datastore do
          bld_created_datastore_event
        end
        ACHIEVED_
      end

      def bld_created_datastore_event
        build_OK_event_with :created_datastore, :description,
          @entity.description, * @entity.to_even_iambic
      end

      def ensure_exists_when_412_precondition_failed o
        @on_event_selectively.call :info, :datastore_exists do
          bld_datastore_exists_event
        end
        nil
      end

      def bld_datastore_exists_event
        build_OK_event_with :datastore_exists, :description,
          @entity.description, * @entity.to_even_iambic
      end
    end
  end
end
