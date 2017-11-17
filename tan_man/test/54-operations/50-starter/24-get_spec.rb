require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - starter get" do

    # (the counterpart code node (file) explains the many (~9) predictable
    # kinds of failures that can occur even for such a simple operation.)
    # (:#cov2.2 is all the tests in this file.)

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :operations

    # (1/N)
    it "'workspace_path' is required (currently)" do

      call_API(
        * _subject_action,
      )

      want :error, COMMON_MISS_ do |ev|
        ev.to_event.reasons.first == :workspace_path
      end

      want_fail
    end

    # (2/N)
    it "when workspace path is noent" do

      workspace_path = the_no_ent_directory_

      call_API(
        * _subject_action_plus,
        :workspace_path, workspace_path,
      )

      want :error, :start_directory_is_not_directory

      want_fail
    end

    # (3/N)
    context "when workspace path does not have config filename (check real default)" do

      # :#cov2.1 (this one default)

      it "invokes" do
        _tuple || fail
      end

      it "config filename was same as REAL default" do
        _event.file_pattern_string_or_array == Home_::Config_filename_[] || fail
      end

      it "config filename was SAME STRING INSTANCE as real default (OCD)" do
        _event.file_pattern_string_or_array.object_id == Home_::Config_filename_[].object_id || fail
      end

      def _event
        _tuple.first
      end

      shared_subject :_tuple do

        workspace_path = the_empty_esque_directory_

        call_API(
          * _subject_action,
          :workspace_path, workspace_path,
        )

        a = []
        want :error, :resource_not_found do |ev|
          a.push ev
        end

        want_fail
        a
      end
    end

    # (4/N)
    context "when workspace does not have entity" do

      it "fails normally" do

        _fails_normally
      end

      it "structured event has invite" do

        ev = _tuple.first

        ev.invite_to_action == [ :starter, :set ] || fail

        _actual = black_and_white ev

        _actual == 'section "digraph" not found in tm-conferg.file' || fail
      end

      shared_subject :_tuple do

        a = []
        _workspace_path = path_for_workspace_005_with_just_a_config_

        call_API(
          * _subject_action_plus,
          :workspace_path, _workspace_path,
        )

        want :error, :config_component_not_found do |ev|
          a.push ev
        end

        a.push execute
        a
      end
    end

    # ( note: (5/N) tested a case where multiple starters were indicated
    #         in the config. we have since changed the means of storage
    #         from being as a section to as an assignment (but we could be
    #         compelled to change it back). anyway for now, we don't care
    #         about this case (although there could be multiple assigments,
    #         and in such cases we don't know which it would take.
    #         the original test case description:
    #             "when workspace has multiple entities, none of which exist"
    #         #history-A.

    # (6/N)
    context "when workspace has entity, but is noent" do

      # #lends-coverage to [#sy-008.4]

      it "invokes, doesn't fail" do  # :#cov2.8
        _tuple || fail
      end

      it "results in NOTHING (nil)" do
        # #history-A.2: we used to result in an invalid starter structure here
        _sct = _tuple.first
        _sct.nil? || fail
      end

      it "emits an informational message about this invalidity" do

        # (near #spot1.2: places that depend on the constituency of starters)

        _event = _tuple.last
        _actual = black_and_white_lines _event

        item = '"[a-z]+(?:-[a-z]+)*\\.dot"'

        want_these_lines_in_array_ _actual do |y|
          y << 'unrecognized starter "this-starter-does-not-exist.dot"'
          y << %r(\Adid you mean (#{ item }(?:, #{ item })* or #{ item })\?\z)
        end

        # (the above asserts a count of at least two items. elsewhere
        # (under #spot.same) the constituency and order is asserted.)
      end

      shared_subject :_tuple do

        workspace_path = path_for_fixture_workspace_ '020-starter-is-no-ent'

        call_API(
          * _subject_action_plus,
          :workspace_path, workspace_path,
        )

        event = nil
        want :error, :item_not_found do |ev|
          event = ev
        end

        _result = execute
        [ _result, event ]
      end

      def expression_agent

        # (just to see how the CLI expag expresses an expression like this.)

        Home_::No_deps_[]::CLI_InterfaceExpressionAgent.instance
      end
    end

    # (7/N) lookin' good my scrollies - NOTE there was no corresponding
    # test for this case in the original flowriginal

    context "when everything is OK" do

      it "invokes, doesn't fail" do
        _tuple || fail
      end

      it "results in the VALID starter item structure (indistinguishable from invalid)" do
        _sct = _tuple.first
        _sct.normal_symbol == :holy_smack || fail
      end

      shared_subject :_tuple do

        workspace_path = path_for_fixture_workspace_ '025-starter-is-OK'

        call_API(
          * _subject_action_plus,
          :workspace_path, workspace_path,
        )
        _result = execute
        [ _result ]
      end
    end

    # ==

    def _fails_normally
      _tuple.last.nil? || fail
    end

    # ==

    def _subject_action_plus
      [ * _subject_action, :config_filename, cfn ]
    end

    def _subject_action
      X_oper_starter_get_THIS_ACTION
    end

    # ==

    X_oper_starter_get_THIS_ACTION = [ :starter, :get ]

    # ==
    # ==
  end
end
# :#history-A.2: (can be temporary): used to result in something on noent
# :#history-A.1: [br] ween, tombstone some tests, move others.
