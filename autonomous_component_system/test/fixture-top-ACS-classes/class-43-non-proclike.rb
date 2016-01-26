module Skylab::Autonomous_Component_System::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_43_Non_ProcLike

      class << self
        alias_method :new_, :new
        # private :new  [ze]
      end  # >>

      def initialize
        # (at writing an oes_p is passed by [ze] only. we don't need it (cold model)
      end

      def __zoof__component_operation

        Here_::Class_72_Big_Loada
      end

      def result_for_component_mutation_session_when_changed o
        o.last_delivery_result
      end
    end
  end
end
