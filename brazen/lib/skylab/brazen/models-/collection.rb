module Skylab::Brazen

  class Models_::Collection < Home_::Model

    edit_entity_class(

      :branch_description, -> y do
        y << "manage collections."
      end,

      :after, :workspace )

    class << self

      def build_unbounds_indexation_

        # this node is weird - it gets its children nodes from somewhere
        # else. amazingy this is all we have to do for this hack
        # (contrast w/ parent):

        Home_::Branchesque::Indexation.new(
          Home_::CollectionAdapters,  # <- look! as if it is an Actions
          self,
        )
      end
    end  # >>

    Silo_Daemon = nil
  end
end
