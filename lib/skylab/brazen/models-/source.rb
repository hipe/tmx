module Skylab::Brazen

  class Models_::Source < Brazen_::Model_

    Entity__ = Brazen_::Model_::Entity

    Entity__[ self, -> do
      o :desc, -> y do
        y << "manage sources."
      end

      o :persist_to, :couch_primary,

      :required,
      :property, :name,

      :required,
      :property, :url

    end ]

    Action_Factory__ = Action_Factory.create_with self,
      Brazen_::Model_::Action, Entity__

    module Actions

      Add = Action_Factory__.make :Add

      Ls = Action_Factory__.make :List

      Rm = Action_Factory__.make :Remove

    end
  end
end
