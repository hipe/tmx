require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] CLI core" do

    extend TS_

    use :expect_my_CLI

    expecting_rx = %r{\Aexpecting <action>\z}i

    usage_rx = %r{\Ausage: sn0g <action> \[\.\.\]\n?\z}

    invite_rx = %r{\Ause 'sn0g -h' for help$}i

    deeper_invite_rx = %r{\Ause 'sn0g -h <action>' for help on that action.\n\z}

    context "the CLI canon (with the same memoized client!) - lvls 0 & 1 ui" do

      use_memoized_client

      it "0.0  (no args) - expecting / usage / invite" do

        invoke
        o expecting_rx
        o usage_rx
        o invite_rx
        o
      end

      it "1.2  (strange opt) - reason / invite" do

        invoke '-x'
        expect "invalid option: -x"
        o invite_rx
        o
      end

      it "1.3  (good arg) (ping)" do

        invoke 'ping'
        expect 'hello from snag.'
        expect_no_more_lines
        @exitstatus.should eql :hello_from_snag
      end

      it "1.4  (good opt) - usage / invite" do

        invoke '-h'

        on_stream :e
        o = flush_to_content_scanner

        o.expect_styled_line.should match usage_rx
        o.expect_nonblank_line
        o.expect_blank_line
        o.expect_header :actions

        o.advance_to_before_Nth_last_line 1
        o.expect_styled_line.should match deeper_invite_rx

        expect_succeeded
      end

      it "2.3x4H (good arg/good opt) (help postfix) (param API)" do

        invoke 'to-do', '-h'

        _st = sout_serr_line_stream_for_contiguous_lines_on_stream :e

        tree = Snag_.lib_.brazen.test_support.CLI::Expect_Section.
          tree_via_line_stream _st

        cx = tree.children

        cx.first.x.unstyled_header_content.should eql 'usage'

        cx.last.x.unstyled_content.should eql(
          "use 'sn0g to-do -h <action>' for help on that action." )

        cx[ 1 ].x.unstyled_header_content.should eql 'actions'

        3 == cx.length or fail

        cx = cx[ 1 ].children
        cx.first.x.line_content.should match(
          /\A-h, --help \[cmd\] {2,}this screen \(or help for action\)\z/ )

        cx[ 1 ].x.line_content.should match(
          /\Ato-stream {2,}a report of the ##{}todo's/ )

        cx[ 2 ].x.line_content.should match %r(\Amelt\b)
      end
    end

    it "numeric option, yaml" do

      invoke 'open', '-1', '--upstream-identifier', Path_alpha_[]

      on_stream :o
      expect '---'
      expect %r(\Aidentifier[ ]+: \[#005\]\z)
      expect %r(\Amessage[ ]+: #open \.\z)

      expect :e, "(one node total)"

      expect_no_more_lines

      @exitstatus.should be_zero
    end
  end
end

# :+#tombstone: specs for the old "numbers" action
