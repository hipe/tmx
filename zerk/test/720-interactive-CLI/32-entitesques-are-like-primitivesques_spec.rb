require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] iCLI - entitesques are like primitivesques" do

    TS_[ self ]
    use :memoizer_methods
    use :want_screens

    context "(this one tree)" do

      # first screen worked
      # bad node name worked
      # prompt for component worked

      context "(enter bad value for component)" do

        given do
          input 's', 'sample rate: 99 kHz'
        end

        it "expresses the issue" do
          first_line == "kHz can't be less that 100 (had 99.0)" or fail
        end

        it "prompts again" do
          last_line == "enter sample: " or fail
        end
      end

      context "(enter good value for component)" do

        given do
          input 'sampl', 'sample rate: 100 kHz'
        end

        it "reports that the value was set" do
          first_line == "set sample to 100.0 kHz" or fail
        end
      end

      def subject_root_ACS_class
        My_fixture_top_ACS_class[ :Class_01_thru_09 ]::Class_06_One_Entitesque
      end
    end
  end
end
