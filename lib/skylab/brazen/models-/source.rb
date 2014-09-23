module Skylab::Brazen

  class Models_::Source < Brazen_::Model_

    Brazen_.model_entity self do

      o :desc, -> y do
        y << "manage sources."
      end

      o :after, :datastore

      o :persist_to, :datastore_couch_primary,

      :required,
      :property, :name,

      :required,
      :property, :url

    end

    Actions = make_action_making_actions_module

    module Actions

      Add = make_action_class :Add

      Ls = make_action_class :List

      Rm = make_action_class :Remove

    end
  end
end
