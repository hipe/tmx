require_relative '../../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  describe "[sg] CLI actions node tags" do

    extend TS_  # the numbers used below are [#hl-134] canonical CLI test id's

    with_invocation 'node', 'tags'

    context "(at the branch node)" do

      it "  0)" do
        invoke
        expect 'expecting {add|ls|rm}'
        expect 'usage: sn0g node tags [<action>] [<args> [..]]'
        expect 'use sn0g node tags -h [<action>] for help'
        expect_failed
      end

      it "1.1)" do
        invoke 'foo'
        expect %r(\Athere is no "foo" action)i
        expect_failure_result
      end

      it "1.2)" do
        invoke '-x'
        expect %r(\Ainvalid option: -x)i
        expect_failure_result
      end
    end

    context "ls" do

      with_manifest <<-O.unindent
        [#1]  keifer #one #two
        [#2] sutherland
        [#3]   donald #four
      O

      it "  0)" do
        setup_tmpdir_read_only
        invoke 'ls'
        expect %r(\Aexpecting:? <node-ref>)i
      end # :+#xyzzy

      it "1.1)" do
        setup_tmpdir_read_only
        invoke 'ls', 'wizzle'
        expect %r(\A#{ failed }invalid identifier name \"wizzle\")i
      end  # :+#xyzzy

      it "1.2)" do
        setup_tmpdir_read_only
        invoke 'ls', '-k'
        expect %r(\Ainvalid option: -k)i
      end  # :+#xyzzy

      it "1.4)"
      false and begin
        debug!
        setup_tmpdir_read_only
        invoke 'ls', '-h'
      end

      it "1.3)" do
        setup_tmpdir_read_only
        invoke 'ls', '[#1]'
        expect :pay, '[#1] is tagged with #one and #two.'
        expect_succeeded
      end

      it "1.3) (when tagged with nothing)" do
        setup_tmpdir_read_only
        invoke 'ls', '[#2]'
        expect :pay, '[#2] is not tagged at all.'
        expect_succeeded
      end

      it "no manifest"

      def failed
        'failed to ls tags - '
      end
    end

    context "rm" do
      with_manifest <<-O.unindent
        [#1234] one #two three
      O

      # #todo tall stacks swallo error results (most of these tests)

      it "  0)" do
        do_not_setup_tmpdir
        invoke 'rm'
        expect %r(\Aexpecting:? <node-ref>)i
        weirdly_expect_success_result
      end

      it "1.1) x - needs two args (node ref and tag name)" do
        do_not_setup_tmpdir
        invoke 'rm', 'zap-daddy'
        expect %r(\Aexpecting:? <tag-name>)i
      end

      it "2.1x1)" do
        do_not_setup_tmpdir
        invoke 'rm', 'foo', 'faa'
        expect %r(\A#{ failed }invalid identifier name \"foo\")i
      end

      it "2.1x1) (well formed but not found)" do
        setup_tmpdir_read_only
        invoke 'rm', '[#8]', 'faa'
        expect %r(\A#{ failed }#{
          }there is no node with identifier .*"8")i
      end

      it "2.3x1)" do
        setup_tmpdir_read_only
        invoke 'rm', '[#1234]', 'noip'
        expect %r(\A#{ failed }\[#1234\] is not tagged with \"#noip)i
      end

      it "2.3x3" do
        invoke 'rm', '[#1234]', 'two'
        expect %r(\Awhile rming tag, removed #two)i
        expect_success_result
        @pn.read.should eql "[#1234]       one three\n"
      end

      it "no manifest"

      def failed
        "failed to rm tag - "
      end
    end

    context "add" do

      with_manifest <<-O.unindent
        [#003] this is three
        [#001] this is one #hi
      O

      it "0)" do
        do_not_setup_tmpdir
        invoke 'add'
        expect %r(\Aexpecting: <node-ref>)i
      end

      it "1.4)"
      false and begin
        debug!
        invoke 'add', '-h'
      end

      it "1.3)" do
        do_not_setup_tmpdir
        invoke 'add', 'x'
        expect %r(\Aexpecting:? <tag-name>)i
      end

      it "2.1x1)" do
        do_not_setup_tmpdir
        invoke 'add', 'x', 'y'
        expect %r(\A#{ failed }invalid identifier name \"x\")i
      end

      it "2.3x1) (not found)" do
        do_not_setup_tmpdir
        invoke 'add', '[#002]', 'x'
        expect %r(\A#{ failed }there is no node with identifier .*"002")i
      end

      it "2.3x1)" do
        setup_tmpdir_read_only
        invoke 'add', '[#003]', 'foo bar'
        expect %r(\A#{ failed }tag must be alphanumeric #{
          }separated with dashes - invalid tag name: "#foo bar")i
      end

      it "2.3x3)" do
        invoke 'add', '[#003]', '2014-ok'
        expect %r(\Awhile adding tag, appended #2014-ok)i
      end

      it "2.3x3) (when redundant)" do
        setup_tmpdir_read_only
        invoke 'add', '[#001]', 'hi'
        expect %r(\A#{ failed }\[#001\] is already tagged with #hi)i
      end

      def failed
        'failed to add tag - '
      end
    end
  end
end
