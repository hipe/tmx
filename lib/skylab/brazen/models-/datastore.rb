module Skylab::Brazen

  class Models_::Datastore < Brazen_::Model_

    edit_entity_class(

      :desc, -> y do
        y << "manage datastores."
      end,

      :after, :workspace )

    class << self

      def is_silo
        false
      end

      def to_upper_unbound_action_stream
        Callback_.stream.via_item self
      end

      def init_action_class_reflection
        @acr = Model_::Lazy_Action_Class_Reflection.new self, Brazen_::Data_Stores_
        true
      end
    end
  end
end
