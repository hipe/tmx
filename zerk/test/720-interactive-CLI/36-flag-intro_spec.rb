require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] iCLI - flag" do

    TS_[ self ]
    use :memoizer_methods
    use :want_screens

    context "go from false to true, then run it." do

      given do
        common_compound_frame_for_design_
        input 'p', 'm'
      end

      context "(first screen)" do
        screen 0

        it "says it's false" do
          _line_of_interest_value == 'false' or fail
        end

        it "button for it" do
          have_button_for 'probe-lauf'
        end
      end

      context "(next screen)" do
        screen 1

        it "says it's true" do
          _line_of_interest_value == 'true' or fail
        end
      end

      context "(next screen)" do
        screen 2

        it "displays as in niCLI (with \"yes\")" do
          first_line == "yes" or fail
        end
      end
    end

    # (from the implementation, we are confident that the other way is OK)

    rx = nil
    define_method :_line_of_interest_value do

      st = screen.to_serr_line_stream

      s = st.gets
      if s.length.zero?
        s = st.gets
      end
      s[ 0 ] == "«" or fail  # placeholder for location

      _ = st.gets

      rx ||= /\A  +([^ ]+)  +(.+)/
      md = rx.match _

      md[ 1 ] == 'probe-lauf' or fail
      md[ 2 ]
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_36_Flag ]
    end
  end
end
