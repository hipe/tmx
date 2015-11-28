require_relative '../../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[br] ACS - modalities - reactive tree - CLI integ. - 1." do

    extend TS_
    use :memoizer_methods
    use :future_expect
    use :modalities_reactive_tree_CLI_integration_support

    it "1.4)   operation has description" do

      _s.should match %r(^ +wazoozie-foozie +have 'fun'\n)
    end

    context "for one particular operation" do

      it "2.0)   operation short one argument" do

        invoke 'waz'
        expect :styled, :e, "expecting <flim-flam>"
        expect_result_for_failure
      end

      it "2.4.A) operation help screen starts with usage" do

        _s_.should match %r(\Ausage: fam wazoozie-foozie <flim-flam>$)
      end

      it "2.4.B) operation help screen has description of operation" do

        _s_.should match %r(^description: have 'fun'$)
      end

      it "2.4.C) operation help screen has description of parameter!" do

        _s_.should match %r(^argument\n +flim-flam +'yes'$)
      end

      dangerous_memoize :_s_ do

        invoke 'waz', '-h'
        flush_to_unstyled_string_contiguous_lines_on_stream :e
      end

      it "2.3)   with one arg" do

        invoke 'waz', 'ziz'
        expect :styled, :e, "hello 'ziz'"
        expect_no_more_lines
        @exitstatus.should eql 12332
      end
    end

    context "for a branch node at level 1" do

      it "1.4.B) has description in first help screen" do
        _s.should match %r(^ +fantazzle-dazzle +'yay'$)
      end

      it "3.4)   request help on its action" do

        invoke 'fantaz', 'open', '-h'

        t = flush_help_screen_to_tree
        cx = t.children
        cx.length.should eql 3

        # usage

        cx[ 0 ].x.unstyled_content.should eql(
          "usage: fam fantazzle-dazzle open [-v] [-d] <file>" )

        # options

        cx[ 1 ].x.unstyled_header_content.should eql 'options'
        cx[ 1 ].children[ 0 ].x.line_content.should match(
          %r(\A-v, --verbose  +tha V\z) )

        # argument

        cx[ 2 ].x.unstyled_header_content.should eql 'argument'
        cx[ 2 ].children[ 0 ].x.line_content.should eql 'file'

      end

      it "3.3)   money" do

        invoke 'fantaz', 'open', '-v', 'zang'
        expect :e, '[:file, "zang", :V]'
        expect_no_more_lines
        @exitstatus.should eql :_neat_
      end
    end

    dangerous_memoize :_s do
      invoke '-h'
      flush_to_unstyled_string_contiguous_lines_on_stream :e
    end
  end
end
