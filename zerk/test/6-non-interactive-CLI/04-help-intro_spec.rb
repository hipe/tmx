require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - help intro" do  # (was in [ac])

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI

    it "1.4)   topmost help screen shows desc of op that is in frame 1" do

      _rx = %r(^ +wazoozie-foozie +have 'fun'\n)
      _top_help_screen.section( :actions ).must_have_styled_line_matching _rx
    end

    context "2.0)   missing a required argument", wip: true do

      given do
        argv 'waz'
      end

      it "fails" do
        fails
      end

      it "whines" do
        first_line.should be_line( :styled, :e, "expecting <flim-flam>" )
      end
    end

    context "2.3)   with one arg", wip: true do

      given do
        argv 'waz', 'ziz'
      end

      it "x." do
        @exitstatus.should eql 12332
      end

      it "x" do
        expect :styled, :e, "hello 'ziz'"
      end
    end

    context "(help screen for operation, option postfixed)", wip: true do

      given do
        argv 'waz', '-h'
      end

      it "2.4.A) operation help screen starts with usage" do

        d = root_ACS_state.lookup_index 'usage'
        d.should be_zero
        _ = root_ACS_state.tree.children.fetch( d ).x.unstyled
        _.should match %r(\Ausage: fam wazoozie-foozie <flim-flam>$)
      end

      it "2.4.B) operation help screen has description of operation" do

        _node = root_ACS_state.lookup 'description'
        _node.x.unstyled.should match %r(^description: have 'fun'$)
      end

      it "2.4.C) operation help screen has description of parameter!" do

        _ = root_ACS_state.lookup( 'argument' ).to_string :unstyled
        _.should match %r(^argument\n +<flim-flam> +'yes'$)
      end
    end

    it "1.4.B) first help screen shows classic desc of asc in frame 1" do

      _rx = %r(^[ ]{2,}fantazzle-dazzle[ ]{2,}'yay'$)
      _top_help_screen.section( :actions ).must_have_styled_line_matching _rx
    end

    it "1.4.C) first help screen shows classic desc of frame 1 itself" do

      _rx = %r(\bwrites files\b)
      _ = _top_help_screen.section( :description ).first_line.unstyled_styled
      _ =~ _rx or fail
    end

    context "+1  3.4)   request help on its action", wip: true do

      given do
        argv 'fantaz', 'open', '-h'
      end

      it "succeeds" do
        root_ACS_state.exitstatus.should match_successful_exitstatus
      end

      it "usage" do

        a = root_ACS_state.lookup( 'usage' ).to_lines :unstyled

        _1 = "usage: fam fantazzle-dazzle open [-v] [-d] <file>"
        _2 = "       fam fantazzle-dazzle open -h"

        a[ 0 ].should eql _1
        a[ 1 ].should eql _2
        a.fetch( 2 ).should eql EMPTY_S_
      end

      it "options" do

        root_ACS_state.lookup( 'options' ).children.fetch( 0 ).
          x.string.should match %r(\A  +-v, --verbose  +tha V$)
      end

      it "argument" do

        root_ACS_state.lookup( 'argument' ).children.fetch( 0 ).
          x.string.should match %r(\A  +<file>)
      end
    end

    context "3.3)   money", wip: true do

      given do
        argv  'fantaz', 'open', '-v', 'zang'
      end

      it "x." do
        @exitstatus.should eql :_neat_
      end

      it "works" do
        expect :e, '[:file, "zang", :V]'
      end
    end

    dangerous_memoize :_top_help_screen do

      invoke__ '-h'
      _lines = release_lines_for_expect_stdout_stderr
      TS_::Non_Interactive_CLI::Help_Screens::Coarse_Parse.new _lines
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_41_File_Writer ]
    end
  end
end
