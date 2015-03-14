module Skylab::GitViz::TestSupport

  module Mock_1

    # a "business" "test bundle" (employed via 'use :mock_1') that is used
    # in conjunction with using the mock repository of the same name.

    class << self
      def [] ctx
        ctx.include Instance_Methods___
      end
    end  # >>

    module Instance_Methods___

      def expect_informational_emissions_for_mock_1

        __expect_this_many_system_commands 8
        expect_this_many_statements_about_omissions 2
        expect_no_more_events
      end

      def __expect_this_many_system_commands d
        expect_N_events d, :next_system_command
      end

      def expect_this_many_statements_about_omissions d
        expect_N_events d, :omitting_informational_commitpoint
      end
    end
  end
end
