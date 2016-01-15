require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - options intro" do  # (was in [ac])

    TS_[ self ]
    use :non_interactive_CLI

    it "1.4)   operation has description", wip: true do  # #waypoint-H

      _top_help_screen.should match %r(^ +wazoozie-foozie +have 'fun'\n)
    end

    # == FROM HERE  # #waypoint-3

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

    # == END
    # == BEGIN #waypoint-H

    context "(help screen)", wip: true do

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

    context "+1  1.4.B) has description in first help screen", wip: true do

      it "x." do
        _top_help_screen.should match %r(^ +fantazzle-dazzle +'yay'$)
      end
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

    ## == END
    ## == FROM HERE #waypoint-3

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

    if false
    dangerous_memoize :_top_help_screen do
      invoke '-h'
      flush_to_unstyled_string_contiguous_lines_on_stream :e
    end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_41_File_Writer ]
    end
  end
end
# #pending-rename: (..)
