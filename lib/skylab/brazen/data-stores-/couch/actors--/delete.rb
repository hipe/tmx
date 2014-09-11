module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Delete_datastore_entity__ < Couch_Actor_

      Actor_[ self, :properties,
        :action, :kernel ]

      def execute
        _collection_name = @action.class.model_class.persist_to
        _cols = @kernel.models[ _collection_name ]
        _col = _cols.instance
        _col.delete_entity_via_action @action
      end
    end
  end
end
