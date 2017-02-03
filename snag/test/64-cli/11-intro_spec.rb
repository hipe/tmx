require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] CLI - intro" do

    TS_[ self ]

    use :my_CLI
    use :my_tmpdir_

    expecting_rx = %r{\Aexpecting <action>\z}i

    usage_rx = %r{\Ausage: sn0g <action> \[\.\.\]\n?\z}

    invite_rx = %r{\Ause 'sn0g -h' for help$}i

    deeper_invite_rx = %r{\Ause 'sn0g -h <action>' for help on that action.\n\z}

    context "the CLI canon lvls 0 & 1 ui" do

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

        expect_succeed
      end

      it "2.3x4H (good arg/good opt) (help postfix) (param API)" do

        invoke 'to-do', '-h'

        tree = flush_invocation_to_help_screen_tree

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

    it "open - as report - numeric option, yaml" do

      invoke 'open', '-1', '--upstream-identifier', Path_alpha_[]

      on_stream :o
      expect '---'
      _expect_identifier '005'
      expect %r(\Amessage[ ]+: #open \.\z)

      expect :e, "(one node total)"

      expect_no_more_lines

      @exitstatus.should be_zero
    end

    it 'open - as report - suffix' do

      invoke 'open', '--upstream-identifier',
        Fixture_tree_[ :for_report_01_small_variety ]

      on_stream :o
      _expect_separator

      _expect_identifier '004.2'
      expect %r(\Amessage[ ]+: ##{}open this is #feature-creep but meh\z)

      _expect_separator
      _expect_identifier '004'
      expect %r(\Amessage[ ]+: ##{}open here's an open guy with two lines\z)

      expect :e, "(2 nodes total)"

      expect_no_more_lines

      @exitstatus.should be_zero
    end

    it 'open - as muation' do

      td = my_tmpdir_

      td.prepare

      td.mkdir 'doc'

      td.copy Fixture_file_[ :rochambeaux_mani ], 'doc/issues.md'  # (result is pn)

      invoke 'open', 'wazeezle', '--try-to-reappropriate',
        '--upstream-identifier', td.to_path

      expect :e, %r(\Aopened a node: updated [^ ]+ \(131 bytes\)\z)

      on_stream :o
      _expect_separator
      _expect_identifier '002'
      expect %r(\Amessage +: #open wazeezle \( #was: #done wiz.+\)\z)

      expect_no_more_lines

      @exitstatus.should be_zero
    end

    define_method :_expect_separator, ( -> do
      bar = '---'
      -> do
        expect bar
      end
    end.call )

    def _expect_identifier s

      expect %r(\Aidentifier[ ]+: \[##{ ::Regexp.escape s }\]\z)
    end
  end
end
# #tombstone: no more memoized client
# :+#tombstone: specs for the old "numbers" action
