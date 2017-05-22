require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - upstream set" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event

# (1/N)
    it "a random string with no prefix - treated as path" do
      # :#cov1.1
      freshly_initted_against 'zoidberg'
      expect_not_OK_event :path_must_be_absolute
      expect_fail
    end

# (2/N)
    it "use a strange prefix" do

      freshly_initted_against "zoidberg:no see"

      _em = expect_not_OK_event_ :unrecognized_argument

      black_and_white_lines( _em.cached_event_value ).should eql(
        [ 'unrecognized prefix "zoidberg"', 'did you mean "file"?' ] )

      expect_fail
    end

# (3/N)
    it "use the 'file' prefix but noent" do
      freshly_initted_against 'file:wazoo.json'
      expect_not_OK_event_ :errno_enoent
      expect_fail
    end

    def freshly_initted_against s

      call_API(
        * _subject_action,
        :upstream, s,
        :path, freshly_initted_path_
      )
      NIL
    end

# (4/N)
    it "to an existing survey try to set an upstream with a strange extension" do

      call_API(
        * _subject_action,
        :path, _various_extensions_path,
        :upstream, 'file:strange-ext.beefer'
      )

      _em = expect_not_OK_event :invalid_extension

      s_a = black_and_white_lines _em.cached_event_value

      s_a.first.should eql 'unrecognized extension ".beefer"'
      s_a.last.should eql 'did you mean ".json" or ".markdown"?'

      expect_no_more_events
    end

# (5/N)
    context "add noent path with good extension on fresh workspace" do

      # #cov1.2, #lends-coverage-to [#br-007.1]

      it "(result is number of bytes written FOR NOW)" do
        129 == _tuple.last || fail
      end

      it "emits event talkin bout added" do
        _actual = black_and_white _tuple.first
        _actual == 'added value - ( adapter : "json" )' || fail
      end

      it "emits talkin bout set upstream" do
        _actual = black_and_white _tuple[1]
        _actual =~ /\AJSON file: «[^»]+»\z/ || fail
      end

      it "emits talkin bout updated (not created)" do
        _actual = black_and_white _tuple[2]
        _actual =~ /\Aupdated «[^»]+» \(\d+ bytes\)\z/ || fail
      end

      it "content" do
        io = ::File.open ::File.join _tuple[-2], config_tail_
        expect_these_lines_in_array_with_trailing_newlines_ io do |y|
          y << "# ohai"
          y << %r(\A\[upstream "file:[^ ]+not\.json"\]\n\z)
          y << "adapter = json"
        end
        io.close
      end

      shared_subject :_tuple do

        path = prepare_tmpdir_with_patch_( :freshly_initted ).path
        x = _call_API_with_path_and_file path, _existent_but_not_JSON_file

        a = []
        __expect_added a
        _expect_common_success_finish a
        a.push path
        a.push x
      end
    end

# (6/N)
    context "add upstream file on workspace with extraneous assignments and .." do

      # #lends-coverage-to [#br-007.1] (again)

      it "(results in number of bytes)" do
        _tuple.last.zero? && fail
      end

      it "says how it changed one" do
        _actual = black_and_white _tuple.first
        _actual == 'value changed - ( adapter : "fladapter" )' || fail
      end

      it "says how it removed one" do
        _actual = black_and_white _tuple[1]
        _actual == 'removed - ( jiminy : "crickets" )' || fail
      end

      it "content good (an interceding comment is preserved)" do

        _path = _tuple[-2]
        io = ::File.open ::File.join( _path, config_tail_ )

        expect_these_lines_in_array_with_trailing_newlines_ io do |y|

           y << "#ohai"  # was there in the beginning
           y << %r(\A\[upstream "file:[^ ]+not\.json"\]\n\z)
           y << "  # heyburt, highburt"  # ditto
           y << "  adapter=json"  # this is something that was changed
        end
        io.close
      end

      shared_subject :_tuple do

        path = prepare_tmpdir_with_patch_( :some_config_file ).path
        x = _call_API_with_path_and_file path, _existent_but_not_JSON_file

        a = []
        __expect_changed a
        __expect_removed a
        _expect_common_success_finish
        a.push path
        a.push x
      end
    end

# (7/N)
    context "add existent upstream on a workspace with multiple upstreams" do

      # when the association models a singleton (formerly "slotular")
      # component (as "upstream" and most others are), it used to be that
      # we would allow multiple sections to match and then we would combine
      # them together.
      #
      # now we see this as an overly active stunt - a file that has multiple
      # sections for a singleton association is invalid; and it should not
      # be up to us to decide how to fix it. to merge all the assignments
      # into one section as we used to do is weird; akin to combining pages
      # from different books into one book.
      #
      # local custom holds that when a workspace will be mutated during
      # the course of a test, we create it by patching it; and when not
      # we simply use a fixture directory in place (risky). as such, since
      # the fixture directory of this test went from being mutated to not
      # mutated, what used to be created by a patch has become a fixture
      # directory and we have put the old patch file under #tombstone-A.1.

      it "fails" do
        _tuple.last.nil? || fail
      end

      it "explains" do
        _actual = _tuple.first
        expect_these_lines_in_array_ _actual do |y|
          y << 'the document has 3 existing "upstream" sections.'
          y << "must have at most one."
        end
      end

      shared_subject :_tuple do

        _path = fixture_directory_ :upstreams_multiple

        x = _call_API_with_path_and_file _path, _existent_but_not_JSON_file

        a = []
        expect :error, :expression, :multiple_sections_for_singleton do |y|
          a.push y
        end

        a.push x
      end
    end

# (8/N)
    it "unset - no", wip: true do
      call_API(
        * _subject_action,
        :upstream, Home_::EMPTY_S_,
        :path, freshly_initted_path_
      )

      expect_not_OK_event :no_upstream_set
      expect_fail
    end

# (9/N)
    it "unset - yes", wip: true do
      TS_._THIS_TEST_IS_TOO_BIG

      td = prepare_tmpdir_with_patch_ :many_upstreams

      call_API(
        * _subject_action,
        :upstream, Home_::EMPTY_S_,
        :path, td.to_path
      )

      expect_not_OK_event :path_must_be_absolute

      _em = expect_OK_event :deleted_upstream

      expect_event_ :collection_resource_committed_changes

      black_and_white( _em.cached_event_value ).should eql(
        "deleted 3 'upstreams'" )

      expect_succeed
    end

    # -- assert

    def _expect_common_success_finish a=nil

      if a
        p = -> ev do
          a.push ev
        end
      end

      expect :info, :set_upstream, & p

      expect :info, :collection_resource_committed_changes, & p

      NIL
    end

    def __expect_added a
      expect :info, :related_to_assignment_change, :added do |ev|
        a.push ev
      end
    end

    def __expect_changed a
      expect :info, :related_to_assignment_change, :changed do |ev|
        a.push ev
      end
    end

    def __expect_removed a
      expect :info, :related_to_assignment_change, :removed do |ev|
        a.push ev
      end
    end

    def expression_agent_for_expect_emission
      Home_::Zerk_lib_[]::No_deps[]::API_InterfaceExpressionAgent.instance
    end

    # -- setup

    def _call_API_with_path_and_file path, file

      call_API(
        * _subject_action,
        :upstream, "file:#{ file }",
        :path, path,
      )
      remove_instance_variable :@result
    end

    # ~ paths

    def _existent_but_not_JSON_file
      ::File.join _various_extensions_path, survey_file_, 'not.json'
    end

    def _various_extensions_path
      fixture_directory_ :upstreams_with_various_extensions
    end

    def config_tail_
      ::File.join survey_file_, 'config'
    end

    def survey_file_
      'cull-survey'
    end

    # ~

    def _subject_action
      [ :survey, :edit ]
    end

    # ==
    # ==
  end
end
# :#tombstone-A.1: there was a patch. there was a method called `count_lines`
