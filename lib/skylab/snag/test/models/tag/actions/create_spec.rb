require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - tag - actions - add", wip: true do

    extend TS_

    context "(with this manifest)" do

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
