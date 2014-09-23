module Skylab::Brazen

  module Data_Store_

    class Model_ < Brazen_::Model_

      class << self
        def main_model_class
          superclass.superclass
        end
      end

      NAME_STOP_INDEX = 1  # sl brzn datastore actions couch add

    end

    class Action < Brazen_::Model_::Action

      NAME_STOP_INDEX = 1

    end

    class Actor
    private

      def via_entity_resolve_model_class
        @model_class = @entity.class ; nil
      end

      def via_entity_resolve_entity_identifier
        @entity_identifier = @entity.class.node_identifier.
          with_local_entity_identifier_string @entity.local_entity_identifier_string  # #todo
        PROCEDE_
      end
    end
  end
end
