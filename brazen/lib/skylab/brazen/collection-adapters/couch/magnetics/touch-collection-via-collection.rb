module Skylab::Brazen

  class CollectionAdapters::Couch

    class Magnetics::TouchCollection_via_Collection < CouchMagnetic_  # 1x

      Attributes_actor_.call( self,
        :entity,
      )

      def execute
        init_response_receiver_for_self_on_channel :ensure_exists
        @entity.put EMPTY_S_,
          :entity_identifier_strategy, :__N_O_N_E__,
          :response_receiver, @response_receiver
      end

    public

      def ensure_exists_when_201_created _
        @listener.call :info, :created_collection do
          bld_created_collection_event
        end
        ACHIEVED_
      end

      def bld_created_collection_event
        build_OK_event_with :created_collection, :description,
          @entity.description, * @entity.to_even_iambic
      end

      def ensure_exists_when_412_precondition_failed o
        @listener.call :info, :collection_exists do
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
