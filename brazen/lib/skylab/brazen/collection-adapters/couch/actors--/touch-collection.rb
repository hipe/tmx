module Skylab::Brazen

  class Collection_Adapters::Couch

    class Actors__::Touch_collection < Couch_Actor_

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
        @on_event_selectively.call :info, :created_collection do
          bld_created_collection_event
        end
        ACHIEVED_
      end

      def bld_created_collection_event
        build_OK_event_with :created_collection, :description,
          @entity.description, * @entity.to_even_iambic
      end

      def ensure_exists_when_412_precondition_failed o
        @on_event_selectively.call :info, :collection_exists do
          bld_collection_exists_event
        end
        nil
      end

      def bld_collection_exists_event
        build_OK_event_with :collection_exists, :description,
          @entity.description, * @entity.to_even_iambic
      end
    end
  end
end
