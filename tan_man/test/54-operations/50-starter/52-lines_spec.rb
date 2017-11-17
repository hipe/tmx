require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - starter lines" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :operations

    context "against default (using the flag requesting the default starter)" do

      it "results in a `gets`-able (a StringIO) of the lines" do

        _actual = _tuple.last

        want_these_lines_in_array_ _actual do |y|

          # (at writing we have to include the newlines here instead of using
          # the dedicated method for this because the strings aren't mutable.)

          y << "# created by tan-man on {{ CREATED_ON }}\n"
          y << NEWLINE_
          y << "digraph {\n"
          y << NEWLINE_
          y << "}\n"
        end
      end

      it "emits the thing telling you it is using the default (and what the default is)" do

        _actual = _tuple.first

        want_these_lines_in_array_ _actual do |y|
          y << "using default starter: minimal.dot"
        end
      end

      shared_subject :_tuple do

        a = []

        call_API(
          * _subject_action,
          :use_default,
        )

        want :info, :expression, :using_default_starter do |y|
          a.push y
        end

        a.push execute
      end
    end

    # (#archive (can be temporary) in sibling file - we used to test
    # the "lines" action with a path in the workspace with no referent
    # ("no-ent"). in the new refactor we would use '020-starter-is-no-ent'
    # to test this, but since we are setting this setup for other actions
    # already we don't bother here, for now.)

    context "workspacey" do

      it "works" do

        actual = _tuple.last

        y = ::Enumerator::Yielder.new do |expected_line|
          actual_line = actual.gets
          actual_line == expected_line || fail
        end

          y << "# created by tan-man on {{ CREATED_ON }}\n"
          y << NEWLINE_
          y << "digraph {\n"
          y << NEWLINE_
          y << "/*\n"
          y << "  example stmt_list:\n"
      end

      it "emits" do
        _actual = _tuple.first
        want_these_lines_in_array_ _actual do |y|
          y << "using starter: holy-smack.dot"
        end
      end

      shared_subject :_tuple do

        _workspace_path = path_for_fixture_workspace_ '025-starter-is-OK'

        a = []

        call_API(
          * _subject_action,
          :workspace_path, _workspace_path,
          :config_filename, cfn,
        )

        want :info, :expression, :using_starter do |y|
          a.push y
        end

        a.push execute
      end
    end

    def _subject_action
      [ :starter, :lines ]
    end

    # ==
    # ==
  end
end

# #born years later
