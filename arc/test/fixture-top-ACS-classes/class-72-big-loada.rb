module Skylab::Autonomous_Component_System::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_72_Big_Loada

      def initialize & oes_p
        @_oes_p = oes_p
        @bar = :_yoohoo_
      end

      PARAMETERS = Attributes_.call(
        foo: nil,
        bar: :optional,
        quux: nil,
      )

      attr_writer( * PARAMETERS.symbols )

      def execute

        @_oes_p.call :info, :expression, :k do |y|
          y << highlight( 'k.' )
        end

        [ @foo, @bar, @quux ]
      end
    end
  end
end
