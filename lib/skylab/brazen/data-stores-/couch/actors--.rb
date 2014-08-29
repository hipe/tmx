module Skylab::Brazen

  class Data_Stores_::Couch

    class Couch_Actor_ < Data_Store_::Actor

      def via_datastore_name_resolve_datastore
        ok = ACHEIVED_
        @datastore = @kernel.datastores.couch.retrieve_entity_via_name @datastore_i, -> ev do
          resolve_result_via_error ev
          ok = UNABLE_
        end
        ok
      end
    end

    module Actors__

      class Retrieve_datastore_entity < Couch_Actor_

        Actor_[ self, :properties,
          :name_i, :kernel, :no_p ]

        def execute
          _i = Couch_.persist_to
          _cols = @kernel.models[ _i ]
          col = _cols.instance
          error = nil
          entity = col.retrieve_entity_via_name_and_class @name_i, Couch_, -> ev do
            error = ev ; nil
          end
          if error
            @no_p[ error ]
          else
            entity
          end
        end
      end
    end
  end
end
