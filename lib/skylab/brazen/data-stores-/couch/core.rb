module Skylab::Brazen

  class Data_Stores_::Couch < Brazen_::Data_Store_::Model_

    Entity__ = Brazen_::Model_::Entity

    Entity__[ self, -> do
      o :desc, -> y do
        y << "manage couch datastores."
      end
    end ]

    Action__ = Brazen_::Data_Store_::Action

    module Actions

      class Add < Action__
        Entity__[ self, -> do
          o :desc, -> y do
            y << "add a couch db."
          end

          o :description, -> y do
            y << "the name of the database to add."
          end,
          :required, :property, :name,

          :flag, :property, :dry_run
        end ]
      end

      class Ls < Action__
        Entity__[ self, -> do
          o :desc, -> y do
            y << "list couch db's."
          end
        end ]
      end

      class Rm < Action__
        Entity__[ self, -> do
          o :desc, -> y do
            y << "remove a couch db."
          end

          o :description, -> y do
            y << "the name of the database to add."
          end
          o :required, :property, :name
        end ]
      end
    end
  end
end
