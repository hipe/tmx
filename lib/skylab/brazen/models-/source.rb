module Skylab::Brazen

  class Models_::Source < Brazen_::Model

    edit_entity_class(

      :desc, -> y do
        y << "manage sources."
      end,

      :after, :collection,

      :persist_to, :collection_couch_primary,

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

    class Silo_Daemon

      def initialize kr, mod
      end

      def precondition_for add, my_node_id, precons
        :_hi_
      end
    end
  end
end
