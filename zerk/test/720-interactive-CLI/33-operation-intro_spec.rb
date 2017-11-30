require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] iCLI - operation intro" do

    TS_[ self ]
    use :memoizer_methods
    use :want_screens

    context "(this one reactive model)" do

      context "missing one required: this is good enough for now but could change at [#021]" do

        given do
          input 'r', '3.2', 'a'
        end

        it "says what's missing" do

          _s = unstyle_styled_ first_line
          _s == "'add' is missing required parameter left number.\n" or fail
        end

        it "shows the buttons again" do
          _shows_the_buttons_again
        end
      end

      context "WAHOO" do

        given do
          input 'l', '1.2', 'r', '2.3', 'a'
        end

        it "(wahoo)" do
          first_line == "3.5" or fail
        end

        it "shows the buttons again" do
          _shows_the_buttons_again
        end
      end

      def _shows_the_buttons_again

        expect( buttonesques ).to be_in_any_order_the_buttons_(
          'left-number', 'right-number', 'add' )
      end

      def subject_root_ACS_class
        My_fixture_top_ACS_class[ :Class_11_Minimal_Postfix ]
      end
    end
  end
end
