require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - graph - use" do

    TS_[ self ]
    # use :want_line
    use :memoizer_methods
    use :want_CLI_or_API
    use :operations

    # (1/N)
    context "no workspace arguments complains about missing required arguments" do

      it "invokes" do
        _tuple || fail
      end

      it "missing requireds are.. (structured retrieval)" do
        _ev = _tuple.first
        _ev.reasons == %i( workspace_path digraph_path ) || fail
      end

      shared_subject :_tuple do

        call_API( * _subject_action )

        a = []
        want :error, :missing_required_attributes do |ev|
          a.push ev
        end

        want_fail
        a
      end
    end

    # (2/N)
    context "just digraph path no workspace arguments complains of missing reqs" do

      it "invokes" do
        _tuple || fail
      end

      it "missing requireds are.. (message generation)" do  # :#cov1.3

        _ev = _tuple.first
        _line = black_and_white _ev
        _line == "missing required parameter :workspace_path\n" || fail
      end

      shared_subject :_tuple do

        call_API(
          * _subject_action,
          :digraph_path, 'some-path',
        )

        a = []
        want :error, :missing_required_attributes do |ev|
          a.push ev
        end

        want_fail
        a
      end
    end

    # (3/N)
    context "workspace path referent must exist" do

      it "invokes" do
        _tuple || fail
      end

      it "event has much detail" do
        ev, workspace_path = _tuple
        ev.num_dirs_looked == 1 || fail
        ev.file_pattern_string_or_array == cfn || fail
        ev.start_path == workspace_path || fail
      end

      shared_subject :_tuple do

        workspace_path = the_empty_esque_directory_

        _call_API_with_digraph_path_and_workspace_path(
          'some-path',
          workspace_path,
        )

        a = []
        want :error, :resource_not_found do |ev|
          a.push ev
        end

        want_fail
        a.push workspace_path
        a
      end
    end

    # (4/N)
    context "digraph path cannot be relative (at backend level)" do

      it "invokes" do
        _tuple || fail
      end

      it "event has structured info" do

        ev = _tuple.fetch 0
        :path_cannot_be_relative == ev.terminal_channel_symbol || fail
        ev.to_event.path == 'some-relative/path' || fail
      end

      shared_subject :_tuple do

        _workspace_path = path_for_workspace_005_with_just_a_config_

        _call_API_with_digraph_path_and_workspace_path(
          'some-relative/path',
          _workspace_path,
        )

        a = []
        want :error, :invalid_property_value do |ev|
          a.push ev
        end

        want_fail

        a
      end
    end

    # (5/N)
    context "dirname of digraph path cannot be noent" do

      it "result is NIL" do  # :#cov1.1
        _tuple.last.nil? || fail
      end

      it "structured event, whines with focused detail" do

        arg_path, ev = _tuple[ 0, 2 ]

        ev.path == ::File.dirname( arg_path ) || fail

        _actual = black_and_white ev
        _actual == "parent directory must exist - some-deep"
      end

      shared_subject :_tuple do

        a = []

        workspace_path = path_for_workspace_005_with_just_a_config_

        digraph_path = ::File.join workspace_path, 'some-deep/path.dot'

        a.push digraph_path

        # (we include the extension in the name above so that we don't
        #  get an emission about it being added.)

        # (we place the would-be digraph file in the workspace directory
        #  so that the path is relativized in the config, making it easier
        #  to assert in a portable way here.)

        _call_API_with_digraph_path_and_workspace_path digraph_path, workspace_path

        want :resource_not_found, :parent_directory_must_exist do |ev|
          a.push ev
        end

        a.push execute
        a
      end
    end

    # (6/N)
    context "digraph path cannot be a directory" do

      it "invokes" do  # :#cov1.2
        _tuple.last.nil? || fail
      end

      it "explains what was expected and what was actual" do

        _ev = _tuple.first

        _actual = black_and_white _ev

        _actual == "not-a-dotfile.dot exists but is not a file, it is a directory" || fail
      end

      shared_subject :_tuple do

        path = path_for_fixture_workspace_ '010-has-a-directory-that-looks-like-a-file'

        _call_API_with_digraph_path_and_workspace_path(
          ::File.join( path, cdn, 'not-a-dotfile.dot' ),
          path,
        )

        # (this path refers to a directory in the fixture)
        # (under #tombstone-A we used to make this through a patch)

        a = []
        want :error, :wrong_ftype do |ev|
          a.push ev
        end

        a.push execute
      end
    end

    # (7/N)
    context "digraph is file but config parse error" do

      it "results in NIL" do  # #cov1.4
        _tuple.last.nil? || fail
      end

      it "config parse error says.." do

        _ev = _tuple.first
        _actual = black_and_white_lines _ev
        want_these_lines_in_array_ _actual do |y|
          y << "expected section name in tm-conferg.file:1:2"
          y << "  1: [\"whtvr\"]\n"
          y << "      ^"
        end
      end

      shared_subject :_tuple do

        path = path_for_fixture_workspace_ '015-config-parse-error'

        digraph_path = ::File.join path, cdn, 'i-exist', 'like-a-boss.dog'

        _call_API_with_digraph_path_and_workspace_path digraph_path, path

        a = []
        want :error, :config_parse_error do |ev|
          a.push ev
        end

        a.push execute
      end
    end

    # (8/N)
    context "(work) when digraph path referent exists - writes config file" do

      it "invokes; result is a would-be custom struct" do  # :#cov1.5, #here2
        a = _tuple.last
        a.first == :_result_from_use_TM_ || fail
        a.last == "i-exist/like-a-boss.dog" || fail
      end

      it "this first event talks about .." do
        _ev = _tuple[ -3 ]
        _content = black_and_white _ev
        _content =~ /\Aadded value - \( path : "/ or fail
      end

      it "this second event talks about .." do
        _ev = _tuple[ -2 ]
        _content = black_and_white _ev
        _content =~ /\Aupdated tm-conferg\.file \(\d+ bytes\)\z/ or fail
      end

      it "content of config file looks good" do

        _path = ::File.join _tuple[1], cfn
        _actual = ::File.open _path, ::File::RDONLY

        want_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          y << "[digraph]"
          y << /\Apath = [[:graph:]]/
          y << "[wiw]"
        end
      end

      shared_subject :_tuple do

        a = _create_the_two_files_where_the_config_file_has_this_line '[wiw]'

        _call_API_with_digraph_path_and_workspace_path( * a )

        want :info, :related_to_assignment_change, :added do |ev|
          a.push ev
        end

        want :info, :success, :collection_resource_committed_changes do |ev|
          a.push ev
        end

        _d = execute
        a.push _d
      end
    end

    # (9/N)

    # NOTE - a lot happened with the next 2 tests at #history-A.2 :#here2:
    #
    #   - we flipped test 9 and 10. it used to be that the one that passed
    #     an open IO for an argument value went first, then a more "ordinary"
    #     one went second. but since we now aren't sure if we want the former
    #     form, we are putting the more ordinary case first, and the weirder
    #     variant second or not at all.
    #
    #     (they are each totally rewritten anyway, so no history is lost
    #     by swapping positions.)
    #
    #   - at the moment, we don't want what used to be test 9 at all. if in
    #     the future we find that in fact we do, we'll go back and re-do
    #     this commit.
    #
    #   - it used to be that we had a special method for asserting
    #     expectation of a set of events without regard to what order they
    #     occurred in (`_want_events_order_insensitive`). at first
    #     appearance the (now preferred) "fail early" technique is at odds
    #     with this pool-based technique because the former requires that
    #     you forward-declare all expected emissions in the order they are
    #     expected;
    #
    #     however A) because now our API for how and when we mutate and
    #     write mutated config files is more established, the order of
    #     emissions should hopefully be more rigid and B) the underlying
    #     spirit of the original arrangement (testing details of emissions
    #     in a manner divorced from their relative placement) is still
    #     achieved under our present technique.

    context "(work) normal case" do

      it "result is a would-be struct, the path to the newly created file" do  # #here2

        a = _tuple[2]  # result
        a.first == :_result_from_use_TM_ || fail
        a.last == "make-me.dot" || fail
      end

      it "wrote the new digraph file, whose content looks good" do

        _digraph_path = _tuple[1]  # digraph_path
        _but_actually = "#{ _digraph_path }.dot"
        io = ::File.open _but_actually
        line = io.gets
        io.close
        line.include? "this file is exists only to be a short file" || fail
      end

      it "write a line in the config talkin bout this new digraph file" do

        _workspace_path = _tuple[0]  # workspace_path
        _config_path = ::File.join _workspace_path, cfn
        actual = ::File.open _config_path
        want_these_lines_in_array_with_trailing_newlines_ actual do |y|
          y << "[ digraph ]"
          y << "path = make-me.dot"
          y << "starter = shorty-short.dot"
        end
        actual.close
      end

      it "because no extension was supplied in the argument path, one was added (explained)" do

        _ev = _dereference_event :adding_extension
        _actual = black_and_white _ev
        _actual == "adding .dot extension to make-me" || fail
      end

      it "for fancy CLI, the file create gets two events: one before and one after" do

        ev, ev_ = _dereference_events :before_probably_creating_new_file, :wrote_file

        _actual = black_and_white ev
        _actual_ = black_and_white ev_

        _actual == "creating make-me.dot" || fail
        _actual_ == "wrote make-me.dot (182 bytes)" || fail
      end

      it "(the usual suspects occurred because of the config write)" do

        ev, ev_ = _dereference_events(
          :added,  # near :related_to_assignment_change,
          :collection_resource_committed_changes,
        )

        _actual = black_and_white ev
        _actual_ = black_and_white ev_

        _actual == 'added value - ( path : "make-me.dot" )' || fail
        _actual_ == 'updated tm-conferg.file (58 bytes)' || fail
      end

      def _dereference_event sym
        _event_hash.fetch sym
      end

      def _dereference_events * syms
        h = _event_hash
        syms.map do |sym|
          h.fetch sym
        end
      end

      def _event_hash
        _tuple.fetch 3
      end

      shared_subject :_tuple do

        a = []

        workspace_path = make_a_copy_of_this_workspace_ '027-short-city'
        digraph_path = ::File.join workspace_path, cdn, 'make-me'  # note no extension

        a.push workspace_path
        a.push digraph_path

        call_API(
          * _subject_action,
          :created_on, "XYZ",
          :digraph_path, digraph_path,
          :workspace_path, workspace_path,
          :config_filename, cfn,
        )

        o = __begin_gather_events_by_terminal_channel_symbol

        o.want :info, :adding_extension
        o.want :info, :before_probably_creating_new_file
        o.want :info, :wrote_file
        o.want :info, :related_to_assignment_change, :added
        o.want :info, :success, :collection_resource_committed_changes

        a.push execute
        a.push o.__release_hash
      end
    end

    # (10/N)
    # (#here2 explains how test 9 and 10 switched positions and we got rid
    # of what used to be test 9; hence there is nothing in the 10 "slot")

    def __begin_gather_events_by_terminal_channel_symbol
      X_oper_graph_use_ThisThing.new method :want
    end

    class X_oper_graph_use_ThisThing

      # because of the sheer number of events of interest emitted here,
      # it's more practical to reference them by symbolic-key-of-terminal-
      # channel-symbol than by offset. but keep in mind because of the
      # "fail early" architecture (a good thing) we must assert the order
      # of the events nonetheless. (see #here1 for what we used to do.)
      #
      # this is hacked inline here because it's never been needed anywhere
      # else, and we want it to really fight to be abstracted out of this
      # one case.

      def initialize p
        @_event_via_terminal_channel_symbol = {}
        @expect = p
      end

      def want * sym_a
        @expect.call( * sym_a ) do |ev|
          @_event_via_terminal_channel_symbol[ sym_a.last ] = ev
        end
      end

      def __release_hash
        remove_instance_variable :@_event_via_terminal_channel_symbol
      end
    end

    def _call_API_with_digraph_path_and_workspace_path digraph_path, path

      call_API(
        * _subject_action,
        :digraph_path, digraph_path,
        :workspace_path, path,
        :config_filename, cfn,
      )
    end

    def _create_the_two_files_where_the_config_file_has_this_line config_line

      _patch_string = <<-O.unindent
        --- /dev/null
        +++ b/#{ cfn }
        @@ -0,0 +1 @@
        +#{ config_line }
        --- /dev/null
        +++ b/#{ cdn }/i-exist/like-a-boss.dog
        @@ -0,0 +1 @@
        + but this is not a dotfile
      O

      workspace_path = prepare_a_tmpdir_like_so_ _patch_string

      _digraph_path = ::File.join workspace_path, cdn, 'i-exist', 'like-a-boss.dog'

      [ _digraph_path, workspace_path ]
    end

    def _subject_action
      [ :graph, :use ]
    end

    # ==
    # ==
  end
end
# :#history-A.2 (can be temporary) ..
# #history-A.1 the beginning of the ween-off-[br] rewrite
