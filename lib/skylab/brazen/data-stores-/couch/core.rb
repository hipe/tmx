module Skylab::Brazen

  class Data_Stores_::Couch < Brazen_::Data_Store_::Model_

    Entity__ = Brazen_::Model_::Entity

    Entity__[ self, -> do
      o :desc, -> y do
        y << "manage couch datastores."
      end

      o :description, -> y do
        y << "the name of the database"
      end,

      :required, :property, :name

    end ]

    Action_Factory__ = Action_Factory.create_with self,
      Brazen_::Data_Store_::Action, Entity__

    module Actions

      Add = Action_Factory__.make :Add

      Ls = Action_Factory__.make :List

      Rm = Action_Factory__.make :Remove

    end
  end
end
