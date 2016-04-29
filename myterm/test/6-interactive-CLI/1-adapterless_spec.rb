require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] iCLI - adapterless" do

    TS_[ self ]
    use :my_interactive_CLI

    context "(at first screen)" do

      given do
        input
      end

      it "there is a line that shows that no adapter is selected" do

        second_line == "  adapter  (none)" or fail
      end

      it "the buttons use custom hotstrings" do

        hotstring_for( 'adapters' ) == 's' or fail
        hotstring_for( 'adapter' ) == 'a' or fail
      end
    end

    context "(indicate that you want to set an adapter with 'a')" do

      given do
        input 'a'
      end

      it "asks you to enter." do
        last_line == "enter adapter: " or fail
      end
    end

    context "and then enter a bad one" do

      given do
        input 'a', 'fazoozle'
      end

      it "says unrec" do
        first_line == "unrecognized adapter name \"fazoozle\"" or fail
      end

      it "did you mean (IMPROVE THIS)" do
        second_line == "did you mean '\e[32mimagemagick\e[0m'?" or fail
      end
    end
  end
end
