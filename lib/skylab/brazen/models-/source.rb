module Skylab::Brazen

  class Models_::Source < Brazen_::Model_

    edit_entity_class(

      :desc, -> y do
        y << "manage sources."
      end,

      :after, :datastore,

      :persist_to, :datastore_couch_primary,

      :required,
      :property, :name,

      :required,
      :property, :url )

    attr_accessor :couch_entity_revision_  # special needs

    Actions = make_action_making_actions_module

    module Actions

      Add = make_action_class :Create

      Ls = make_action_class :List

      Rm = make_action_class :Delete

    end
  end
end
