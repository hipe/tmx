require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - starter set" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API
    use :operations

# (1/N)
    context "set bad name" do

      it "fails" do
        _tuple.last == nil || fail
      end

      it "whines and splays" do

        _ev = _tuple.first

        _actual = black_and_white_lines _ev

        expect_these_lines_in_array_ _actual do |y|

          y << 'unrecognized starter "wiz"'

          item = '"[a-z]+(?:-[a-z]+)*\.dot"'

          y << /\Adid you mean #{ item }(?:, #{ item })* or #{ item }\?\z/
        end
      end

      shared_subject :_tuple do

        _workspace_path = path_for_workspace_005_with_just_a_config_

        call_API(
          * _subject_action,
          :starter_name, 'wiz',
          :workspace_path, _workspace_path,
        )

        a = []
        expect :error, :item_not_found do |ev|
          a.push ev
        end
        # (used to emit `business_item_not_found` before #history-A.1)
        # (used to emit `component_not_found` before #history-A)

        a.push execute
      end
    end
# (2/N)
    it "good name, no workspace path" do

      call_API(
        * _subject_action,
        :starter_name, "digr",
      )

      expect :error, COMMON_MISS_

      expect_fail
    end
# (3/N)
    context "good name, workspace path, but config parse error" do

      it "fails" do
        _tuple.last == nil || fail
      end

      it "explains config parse error" do

        _ev = _tuple.first
        _actual = black_and_white_lines _ev

        expect_these_lines_in_array_ _actual do |y|

          y << "expected open square bracket in tm-conferg.file:1:1"
          y << "  1: using_starter=hoitus-toitus.dot\n"
          y << "     ^"
        end
      end

      shared_subject :_tuple do

        _workspace_path = path_for_fixture_workspace_ '016-conf-parse-error-again'

        call_API(
          * _subject_action,
          :starter_name, "digraph.dot",
          :workspace_path, _workspace_path,
          :config_filename, cfn,
        )

        a = []
        expect :error, :config_parse_error do |ev|
          a.push ev
        end

        a.push execute
      end
    end
# (4/N)
    context "good name, workspace path, good config (matches fuzzily)" do

      it "results in the normalized path that was inserted/set" do
        _x = _tuple.last
       _rx = /\b#{ ::Regexp.escape( ::File.join 'starters', 'digraph.dot' ) }\z/
        _x =~ _rx || fail
      end

      it "emits thing about how the assignment was changed" do
        _ev = _tuple[1]
        _line = black_and_white _ev
        _line == 'value changed - ( starter : "this-starter-does-not-exist.dot" )' || fail
      end

      it "emits thing about how the config was updated (not created)" do
        _ev = _tuple[2]
        _line = black_and_white _ev
        _line =~ /\Aupdated tm-conferg.file \([1-9]\d+ bytes\)\z/ || fail
      end

      it "the file was actually written to" do
        _workspace_path = _tuple.first
        _path = ::File.join _workspace_path, cfn
        _io = ::File.open _path
        expect_these_lines_in_array_ _io do |y|
          y << "[ digraph ]\n"
          y << %r(\Astarter = [^ ]+#{ ::Regexp.escape ::File::SEPARATOR }digraph\.dot\n\z)
        end
      end

      shared_subject :_tuple do

        a = []
        workspace_path = make_a_copy_of_this_workspace_ '020-starter-is-no-ent'
        # workspace_path = given_dotfile_FAKE_ "#{ ENV['HOME'] }/tmp/__tmx_dev_tmpdir__/tm-testing-cache/volatile-tmpdir"

        a.push workspace_path

        call_API(
          * _subject_action,
          :starter_name, "digr",
          :workspace_path, workspace_path,
          :config_filename, cfn,
        )

        expect :info, :related_to_assignment_change do |ev|
          a.push ev
        end

        expect :info, :success, :collection_resource_committed_changes do |ev|
          a.push ev
        end

        a.push execute
      end
    end

    # ==
    # ==

    def _subject_action
      [ :starter, :set ]
    end
  end
end
# #history-A.1: fuzzy
# #history-A: full rewrite during ween off of [br]
