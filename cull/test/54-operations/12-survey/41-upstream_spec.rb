require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - upstream set" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event

# (1/N)
    it "a random string with no prefix - treated as path" do
      # :#cov1.1
      freshly_initted_against 'zoidberg'
      want_not_OK_event :path_must_be_absolute
      want_fail
    end

# (2/N)
    it "use a strange prefix" do

      freshly_initted_against "zoidberg:no see"

      _em = want_not_OK_event_ :unrecognized_argument

      black_and_white_lines( _em.cached_event_value ).should eql(
        [ 'unrecognized prefix "zoidberg"', 'did you mean "file"?' ] )

      want_fail
    end

# (3/N)
    it "use the 'file' prefix but noent" do
      freshly_initted_against 'file:wazoo.json'
      want_not_OK_event_ :errno_enoent
      want_fail
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

      _em = want_not_OK_event :invalid_extension

      s_a = black_and_white_lines _em.cached_event_value

      s_a.first.should eql 'unrecognized extension ".beefer"'
      s_a.last.should eql 'did you mean ".json" or ".markdown"?'

      want_no_more_events
    end

# (5/N)
    context "add path with good extension and existent referent on fresh workspace" do

      # #cov1.2, #lends-coverage-to [#br-007.1]

      it "(result is number of bytes written FOR NOW)" do

        d = _tuple.last

        # yuck the number of characters written to the file depends on
        # the absolute path of the monolith directory. this should be
        # changed (probably) so .. maybe an option to force relative paths
        # for assets, even when they are longer than the absolute path. but
        # meh that's a #todo. for now we just allow that the absolute dev
        # directory path can be up to 40 chars long ..

        d.respond_to? :bit_length or fail

        ( 128..169 ).include? d or fail
      end

      it "emits event talkin bout added" do
        _actual = black_and_white _tuple.first
        _actual == 'added value - ( adapter : "json" )' || fail
      end

      it "emits talkin bout set upstream" do
        _actual = black_and_white _tuple[1]
        _actual =~ /\AJSON file: .+\bnot\.json\z/ || fail
      end

      it "emits talkin bout updated (not created)" do
        _actual = black_and_white _tuple[2]
        _actual =~ /\Aupdated [^ ]+ \(\d+ bytes\)\z/ || fail
      end

      it "content" do
        io = ::File.open ::File.join _tuple[-2], config_tail_
        want_these_lines_in_array_with_trailing_newlines_ io do |y|
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

        want :info, :related_to_assignment_change, :added do |ev|
          a.push ev
        end

        _want_common_success_finish a
        a.push path
        a.push x
      end
    end

# (6/N)
    context "add (same path) over survey with existing upstream" do

      # #lends-coverage-to [#br-007.1] (again)

      it "(results in number of bytes)" do
        _tuple.last.zero? && fail
      end

      it "says how it changed one" do
        _actual = black_and_white _tuple[1]
        _actual == 'no change in value - ( adapter : "json" )' || fail
      end

      it "content good (an interceding comment is preserved)" do

        _path = _tuple[0]
        io = ::File.open ::File.join( _path, config_tail_ )

        want_these_lines_in_array_with_trailing_newlines_ io do |y|

           y << "# ohai i am some config file"  # (as it was in the beginning)
           y << %r(\A\[ upstream "file:[^ ]+not\.json" \]\n\z)
           y << "adapter = json"  # this is something that was changed
        end
        io.close
      end

      shared_subject :_tuple do

        path = prepare_tmpdir_with_patch_( :some_config_file ).path
        x = _call_API_with_path_and_file path, _existent_but_not_JSON_file

        a = [ path ]  # _tuple[0]

        want :info, :related_to_assignment_change, :no_change do |ev|
          a.push ev  # _tuple[1]
        end

        _want_common_success_finish
        a.push x  # _tuple.last
      end
    end

# (7/N)
    context "add existent upstream on a workspace with multiple upstreams" do

      # :#cov1.6, :#spot1.3.
      # [#011.D.2] describes how #tombstone-A.1 pertains to this test case.

      it "fails" do
        _fails
      end

      it "explains" do
        _actual = _tuple.first
        want_these_lines_in_array_ _actual do |y|
          y << 'the document has more than one existing "upstream" section.'
          y << "must have at most one."
        end
      end

      shared_subject :_tuple do

        _path = fixture_directory_ :upstreams_multiple

        x = _call_API_with_path_and_file _path, _existent_but_not_JSON_file

        a = []
        want :error, :expression, :multiple_sections_for_singleton do |y|
          a.push y
        end

        a.push x
      end
    end

# (8/N)
    context "unset when it is already not set" do

      it "fails" do
        _fails
      end

      it "explains" do
        _actual = _tuple.first
        _actual == [ "cannot unset upstream - no upstream set" ] || fail
      end

      shared_subject :_tuple do

        x = call_API(
          * _subject_action,

          :unset_upstream,
          :path, freshly_initted_path_
        )

        a = []
        want :error, :expression, :no_upstream_set do |y|
          a.push y
        end
        a.push x
      end
    end

# (9/N)
    context "unset OK" do

      it "succeeds (result is number of bytes written for now)" do
        _x = _tuple.last
        _x.zero? && fail
      end

      it "emits something talkin bout removed (in a non-document-centric-way)" do

        _actual = _tuple[1]
        want_these_lines_in_array_ _actual do |y|
          y << %r(\Aremoved upstream \(JSON file: [^ ]+\bshamonay\.file\)\z)
        end
      end

      it "emits talkin bout wrote resource" do

        _ev = _tuple[2]
        _ev.bytes.zero? && fail
      end

      it "after having done this, the file has no data lines" do

        _head = _tuple[0]
        _path = ::File.join _head, config_filename
        io = ::File.open _path

        want_these_lines_in_array_with_trailing_newlines_ io do |y|
          y << "# ohai i am some config file"
        end

        io.close
      end

      shared_subject :_tuple do

        a = []

        path = prepare_tmpdir_with_patch_( :some_config_file ).path

        a.push path  # _tuple[0]

        call_API(
          * _subject_action,
          :unset_upstream,
          :path, path,
        )

        want :info, :expression, :removed_entity do |y|
          a.push y  # _tuple[1]
        end

        want :info, :collection_resource_committed_changes do |ev|
          a.push ev  # _tuple[2]
        end

        a.push @result  # _tuple.last
      end
    end

    # -- assert

    def _want_common_success_finish a=nil

      if a
        p = -> ev do
          a.push ev
        end
      end

      want :info, :set_upstream, & p

      want :info, :collection_resource_committed_changes, & p

      NIL
    end

    def _fails
      _tuple.last.nil? || fail
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
# #tombstone-A.2: deleting the upstream no longer happens with the empty string hack
# :#tombstone-A.1: there was a patch. there was a method called `count_lines`
