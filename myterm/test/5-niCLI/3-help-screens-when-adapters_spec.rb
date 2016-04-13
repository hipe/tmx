require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] niCLI - help screens when adapters" do

    TS_[ self ]
    Home_.lib_.zerk.test_support::Non_Interactive_CLI::Help_Screens[ self ]

    context "(help screen from top)" do

      given_screen do
        argv '-h'
      end

      it "first usage line has been customized" do

        _be_this = be_line :styled, "usage: xyzi [ -a{i} ] <action> [..]"
        section( :usage ).raw_line( 0 ).should _be_this
      end

      it "second usage line too" do

        _be_this = be_line :styled, %r(\A {2,}xyzi \[ -a{i} \] -h <action>$)
        section( :usage ).raw_line( 1 ).should _be_this
      end

      it "options screen is customized" do

        _rx = %r(\A {2,}-a, --adapter=X {2,}[a-z])
        _sect = section( :option ).raw_line( 1 ).string =~ _rx or fail
      end
    end

    context "(help screen of adapter specific operation)" do

      given_screen do
        argv '-aim', 'OSA-script', '-h'
      end

      it "the short hotstring of active adapter appears in usage line" do

        _be_this = be_line :styled, %r(\Ausage: xyzi -ai osa-script \[-)
        section( :usage ).raw_line( 0 ).should _be_this
      end

      it "adapter specific components are in the o.p" do

        section( :options ).line_count > 2 or fail
      end
    end

    def subject_CLI
      Home_::CLI
    end
  end
end
