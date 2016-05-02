require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] niCLI - help screens when adapters" do

    TS_[ self ]

    # -- eek: vendor lib and our lib collide. vendor lib must trump ours

    include TS_::My_Non_Interactive_CLI::InstanceMethods

    _ = Home_.lib_.zerk.test_support::Non_Interactive_CLI::Help_Screens
    _[ self ]

    def for_expect_stdout_stderr_prepare_invocation invo
      prepare_CLI_for_niCLI_ invo
      NIL_
    end

    # --

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
        section( :option ).raw_line( 1 ).string =~ _rx or fail
      end
    end

    context "(help screen from top with adapter selected)" do

      given_screen do
        argv '-ai', '-h'
      end

      it "first usage line is like above but shows adapter being selected" do

        _be_this = be_line :styled, "usage: xyzi -ai <action> [..]"
        section( :usage ).raw_line( 0 ).should _be_this
      end

      it "2nd usage is like above but (ditto)" do

        _be_this = be_line :styled, %r(\A {2,}xyzi -ai -h <action>$)
        section( :usage ).raw_line( 1 ).should _be_this
      end

      it "there does NOT appear the special custom section" do

        niCLI_help_screen.has_section( :option ) and fail
      end

      it "actions show adapter-only actions" do

        _hi = section( :actions ).items

        rx = %r(\A {2,}background-font\b)
        _found = _hi.detect do | item |
          rx =~ item.head_line.string
        end
        _found or fail
      end

      it "invite should should DOOTILY FOR FOOTILY" do

        _be_this = be_line :styled,
          "use 'xyzi -ai -h <action>' for help on that action."

        section( :use ).raw_line( 0 ).should _be_this
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
