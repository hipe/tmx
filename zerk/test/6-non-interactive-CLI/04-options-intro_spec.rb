require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - options intro", wip: true do  # (was in [ac])

    TS_[ self ]
    use :memoizer_methods
    # use :future_expect
    # use :modalities_reactive_tree_CLI_integration

    it "1.4)   operation has description" do
      _top_help_screen.should match %r(^ +wazoozie-foozie +have 'fun'\n)
    end

    context "for one particular operation" do

      it "2.0)   operation short one argument" do

        invoke 'waz'
        expect :styled, :e, "expecting <flim-flam>"
        expect_result_for_failure
      end

      it "2.3)   with one arg" do

        invoke 'waz', 'ziz'
        expect :styled, :e, "hello 'ziz'"
        expect_no_more_lines
        @exitstatus.should eql 12332
      end
    end

    context "(help screen)" do

      shared_subject :root_ACS_state do

        invoke 'waz', '-h'

        flush_invocation_to_help_screen_oriented_state
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

    it "+1  1.4.B) has description in first help screen" do
      _top_help_screen.should match %r(^ +fantazzle-dazzle +'yay'$)
    end

    context "+1  3.4)   request help on its action" do

      shared_subject :root_ACS_state do
        invoke 'fantaz', 'open', '-h'
        flush_invocation_to_help_screen_oriented_state
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

    it "3.3)   money" do

      invoke 'fantaz', 'open', '-v', 'zang'
      expect :e, '[:file, "zang", :V]'
      expect_no_more_lines
      @exitstatus.should eql :_neat_
    end

    dangerous_memoize :_top_help_screen do
      invoke '-h'
      flush_to_unstyled_string_contiguous_lines_on_stream :e
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_41_File_Writer ]
    end
  end
end
