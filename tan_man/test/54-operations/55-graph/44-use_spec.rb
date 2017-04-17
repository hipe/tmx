require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - graph - use" do

    TS_[ self ]
    # use :expect_line
    use :memoizer_methods
    use :expect_CLI_or_API
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

        call_API :graph, :use

        a = []
        expect :error, :missing_required_attributes do |ev|
          a.push ev
        end

        expect_fail
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
          :graph, :use,
          :digraph_path, 'some-path',
        )

        a = []
        expect :error, :missing_required_attributes do |ev|
          a.push ev
        end

        expect_fail
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
        expect :error, :resource_not_found do |ev|
          a.push ev
        end

        expect_fail
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
        expect :error, :invalid_property_value do |ev|
          a.push ev
        end

        expect_fail

        a
      end
    end

    # (5/N)
    context "dirname of digraph path cannot be noent" do

      it "invokes" do  # :#cov1.1
        _tuple || fail
      end

      it ".."  # (at writing 2 of the 4 emissions emit..)
      def _xx

        ev = _expect_events_order_insensitive(

          adding_extension: nil,
          component_not_found: nil,
          using_default: nil,
          parent_directory_must_exist: IDENTITY_ )

        full_path_ = ::File.dirname full_path

        ev.to_event.path.should eql full_path_

        black_and_white( ev ).should eql "parent directory must exist - some-deep"
      end while false

      shared_subject :_tuple do

        workspace_path = path_for_workspace_005_with_just_a_config_

        _digraph_path = ::File.join workspace_path, 'some-deep/path'

        _call_API_with_digraph_path_and_workspace_path _digraph_path, workspace_path

        a = []
        expect :info, :adding_extension do |ev|
          a.push ev
        end

        expect :resource_not_found, :parent_directory_must_exist do |ev|
          a.push ev
        end

        a
      end
    end

    # (6/N)
    context "digraph path cannot be a directory" do

      it "invokes" do  # :#cov1.2
        _tuple || fail
      end

      it ".."
      if false
          expect_not_OK_event :wrong_ftype,
            /\A\(pth "[^"]+"\) exists but is not \(indefinite_noun #{
             }"file"\), it is \(indefinite_noun "directory"\)\z/
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
        expect :error, :wrong_ftype do |ev|
          a.push ev
        end

        expect_fail
        a
      end
    end

    # (7/N)
    context "digraph is file but config parse error" do

      it "invokes" do  # #cov1.4
        _tuple || fail
      end

      it "config parse error says.."

      shared_subject :_tuple do

        path = path_for_fixture_workspace_ '015-config-parse-error'

        digraph_path = ::File.join path, cdn, 'i-exist', 'like-a-boss.dog'

        _call_API_with_digraph_path_and_workspace_path digraph_path, path

        a = []
        expect :error, :config_parse_error do |ev|
          a.push ev
        end

        expect_fail
        a
      end
    end

    # (8/N)
    context "WORKS when digraph path referent exists - writes config file" do

      it "invokes; result is nothing interesting" do  # :#cov1.5
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

        expect_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          y << "[digraph]"
          y << /\Apath = [[:graph:]]/
          y << "[wiw]"
        end
      end

      shared_subject :_tuple do

        a = _create_the_two_files_where_the_config_file_has_this_line '[wiw]'

        _call_API_with_digraph_path_and_workspace_path( * a )

        expect :info, :related_to_assignment_change do |ev|
          a.push ev
        end

        expect :info, :success, :collection_resource_committed_changes do |ev|
          a.push ev
        end

        _d = execute
        a.push _d
      end
    end

    # (9/N)
    context "you can pass an open IO as the digraph path (a convenience hack)" do

      it "invokes", wip: true do
        # (this needs starter silo)
        _tuple || fail
      end

      it ".."
      def _xx

          scn = @event_log.flush_to_scanner

          while :wrote_file != scn.head_as_is.channel_symbol_array.last
            scn.advance_one
          end

          @event_log = scn.flush_to_stream

          expect_OK_event :wrote_file

          expect_committed_changes_

          expect_succeed

          _read_config_file

          excerpt( 0 .. 0 ).should eql "[ graph \"../open-this-yourself\" ]\n"
      end

      shared_subject :_tuple do

        workspace_path = prepare_a_tmpdir_like_so_ <<-O.unindent
          --- /dev/null
          +++ b/#{ cfn }
          @@ -0,0 +1 @@
          +[ graph "dingo-dango" ]
          --- /dev/null
          +++ b/#{ cdn }/open-this-yourself
          @@ -0,0 +1 @@
          + this will get overwritten
        O

        _path = ::File.join workspace_path, 'open-this-yourself'

        _IO = ::File.open _path, ::File::CREAT | ::File::EXCL | ::File::WRONLY

        _call_API_with_digraph_path_and_workspace_path _IO, workspace_path

        self.DEBUG_ALL_BY_FLUSH_AND_EXIT
      end
    end

    $stderr.puts "\n\n\nDON'T YOU ... FORGET ABOUT ME\n\n\n"
    if false

    # (10/N)
          it "and digraph path is without extension - adds ext, creates digraph" do  # #too-big

            prepare_whatever_workspace

            @ws_pn = volatile_tmpdir

            dg_pn = @ws_pn.join "#{ cdn }/make-me"

            call_API :graph, :use,
              :created_on, "XYZ",
              :digraph_path, dg_pn.to_path,
              :workspace_path, @ws_pn.to_path, :config_filename, cfn

            _expect_events_order_insensitive(

              adding_extension: [ nil,
                "adding .dot extension to make-me" ],

              component_not_found: [ nil,
                "in workspace config there are no starters" ],

              using_default: [ nil,
                /\Ausing default starter "minimal\.dot" \(the last of [23] starters\)/ ],

              before_probably_creating_new_file: nil,

              wrote_file: [ true,
                /\Awrote make-me\.dot \([456]\d bytes\)/ ],

              collection_resource_committed_changes: [ true,
                %r(\Aupdated config \(\d{2} bytes\)) ] )

            io = dg_pn.sub_ext( '.dot' ).open( ::File::RDONLY )
            o = TestSupport_::Expect_Line::Scanner.via_line_stream io

            o.next_line.should eql "# created by tan-man on XYZ\n"
            io.close

            expect_succeed
          end

    # (11/N)
          it "and the digraph path is with extension - creates digraph" do

            prepare_whatever_workspace

            ws_pn = volatile_tmpdir

            dg_pn = ws_pn.join "#{ cdn }/make-this.wtvr"

            call_API :graph, :use,
              :digraph_path, dg_pn.to_path,
              :workspace_path, @ws_pn.to_path,
              :config_filename, cfn

            ev = _expect_events_order_insensitive(
              component_not_found: nil,
              using_default: nil,
              before_probably_creating_new_file: nil,
              wrote_file: IDENTITY_,
              collection_resource_committed_changes: nil )

            ::File.basename( ev.to_event.path ).should eql 'make-this.wtvr'

            expect_succeeded_result
          end

    def prepare_whatever_workspace
      prepare_ws_tmpdir <<-O.unindent
        --- /dev/null
        +++ b/#{ cfn }
        @@ -0,0 +1 @@
        +[ whatever ]
      O
    end

    def _expect_events_order_insensitive mutable_h

      # :+#abstraction-candidate

      h = mutable_h
      last_user_result = nil

      el = event_log
      st = Common_.stream do
        em = el.gets
        if em
          em.cached_event_value
        end
      end

      begin
        ev = st.gets
        ev or break
        k = ev.terminal_channel_i
        x = h.fetch k
        h.delete k
        x or redo

        if x.respond_to? :call
          last_user_result = x[ ev ]
          redo
        end

        ok, msg_x = x

        ok_ = ev.to_event.ok
        ok == ok_ or fail "`#{ k }.ok` was #{ ok_.inspect }, expected #{ ok.inspect }"

        msg_x or redo
        msg = black_and_white ev
        if msg_x.respond_to? :named_captures
          msg.should match msg_x
        else
          msg.should eql msg_x
        end

        redo
      end while nil

      if h.length.nonzero?
        fail "these expected events were not emitted: (#{ h.keys * ', ' })"
      end

      last_user_result
    end
    end  # if false

    def _call_API_with_digraph_path_and_workspace_path digraph_path, path

      call_API(
        :graph, :use,
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
    # ==
    # ==
  end
end
# #history-A.1 the beginning of the ween-off-[br] rewrite
