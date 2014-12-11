module Skylab::Brazen

  class Models_::Datastore < Brazen_::Model_

    Brazen_::Model_::Entity.call self do

      o :desc, -> y do
        y << "manage datastores."
      end

      o :after, :workspace
    end

    class << self

      def is_silo
        false
      end

      def get_unbound_upper_action_scan
        # Callback_.stream.via_item self  # #todo is same
        p = -> do
          x = self
          p = EMPTY_P_
          x
        end
        Callback_.stream do
          p[]
        end
      end

      def init_action_class_reflection
        @acr = Model_::Lazy_Action_Class_Reflection.new self, Brazen_::Data_Stores_
        true
      end
    end
  end
end
