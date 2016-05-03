require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] iCLI - adapterful" do

    TS_[ self ]
    use :my_interactive_CLI

    context "(big kahuna)" do

      # *solely* in the interest of not "wasting" all the work that goes
      # into generating each screen-component of each screen that is built
      # after almost *each item* (string) that is entered in the array of
      # input strings below (MxN), we make one relatively massive interaction
      # session and run detailed tests on N of its screens, as opposed to
      # just the last screen like we often do.
      #
      # the main cost of this is that it won't regress as well as it would
      # with more focused tests (generally) - when something breaks
      # everything after it will be broken too. but we justify this as being
      # "OK" because it's just an integration test - deeper issues between
      # the application and framework should be resolved either in this
      # sidesystem in model tests or in [ze] in mode-gen tests; not here in
      # integration tests.

      given do

        # if you comment out both the below two lines and run any one of
        # the tests in this file, if the stars are aligned it should actually
        # change the background image of the (iTerm) terminal you run it in.

        filesystem_conduit_of TS_::Stubs::Filesystem_01.produce_new_instance

        system_conduit_of TS_::Stubs::System_Conduit_02_Yay.produce_new_instance

        input(
          'a', 'ima',  # set the adapter
          'f',  # enter into the "background front" frame
          'li',  # list them (not necessary, just covering it)
          'p', 'lucida',  # set the background font via path
          nil,  # jump down one frame
          'l', 'djibouti',  # set the label
          's',  # set background image!
        )
      end

      context "(first screen)" do

        screen 0

        it "shows adapter-related operation buttons" do
          last_line == 'adapter[s] [a]dapter' or fail
        end
      end

      context "(next screen)" do

        screen 1

        it "prompts you to enter adapter" do
          last_line == 'enter adapter: ' or fail
        end
      end

      context "(next screen)" do

        screen 2

        it "shows that adapter was set" do
          first_line == "set adapter to 'imagemagick'" or fail
        end

        it "shows adapter-specific components" do

          _this = include_in_any_order_the_buttons(
            'background-font',
            'label',
            'set-background-image',
          )

          buttonesques.should _this
        end
      end

      context "(next screen)" do

        screen 3

        it "shows that no path is selected" do
          lines[ -4 ] == "  path  (none)" or fail
        end

        it "shows the 2 background-font-related components" do
          _these_buttons
        end
      end

      context "(next screen) (NOTE - ..)" do

        screen 4

        it "shows the listing of the available fonts (stubbed)" do

          first_line == "/zoopie/doopie/fontible.dfont" or fail
          second_line == "/zooper/dooper/lucida-font.dfont" or fail
        end

        it "ends with same options" do
          _these_buttons
        end
      end

      # (skip prompt to enter path at screen with offset 5)

      # (skip same screen again at 6)

      context "(later)" do

        screen 8

        it "says set label" do
          first_line == "set label to \"djibouti\""
        end
      end

      context "(next screen)" do

        screen 9

        it "apparently worked" do

          first_line.include?( '(attempting: convert -font' ) or fail
          second_line.include?( 'apparently set iTerm background' ) or fail
        end
      end

      def _these_buttons
        last_line == "[p]ath [l]ist" or fail
      end
    end
  end
end
