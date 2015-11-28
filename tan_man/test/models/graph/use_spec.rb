require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] models graph use" do

    TS_[ self ]
    use :expect_line
    use :models

    context "when no workspace" do

      it "no args - missing the one required arg" do

        call_API :graph, :use

        expect_not_OK_event :missing_required_properties do | ev |

          [ :digraph_path, :workspace_path ].should be_include(
            ev.to_event.miss_a.first.name_symbol
          )
        end

        expect_failed
      end

      it "just digraph path, no ws resolution" do

        call_API :graph, :use,
          :digraph_path, 'some-path'

        ev = expect_not_OK_event :missing_required_properties
        black_and_white( ev ).should eql "missing required property 'workspace_path'"

        expect_failed
      end

      it "yes args but ws path is noent - workspace not found" do

        use_empty_ws

        call_API :graph, :use,
          :digraph_path, 'some-path',
          :workspace_path, @ws_pn.to_path,
          :config_filename, cfn

        expect_not_OK_event :workspace_not_found do |ev|
          ev = ev.to_event
          ev.num_dirs_looked.should eql 1
          ev.file_pattern_x.should eql cfn
          ev.start_path.should eql @ws_pn.to_path
        end

        expect_failed
      end
    end

    context "when workspace" do

      it "and digraph path is not absolute - no" do

        prepare_whatever_workspace

        call_API :graph, :use, :digraph_path, 'some-relative/path',
          :workspace_path, @ws_pn.to_path, :config_filename, cfn

        expect_not_OK_event :path_cannot_be_relative do |ev|
          ev.to_event.path.should eql 'some-relative/path'
        end

        expect_failed
      end

      it "and digraph is abspath whose dirname is noent - no" do

        prepare_whatever_workspace

        full_path = @ws_pn.dirname.join( 'some-deep/path' ).to_path

        call_API :graph, :use,
          :digraph_path, full_path,
          :workspace_path, @ws_pn.to_path, :config_filename, cfn

        ev = _expect_events_order_insensitive(

          adding_extension: nil,
          component_not_found: nil,
          using_default: nil,
          parent_directory_must_exist: IDENTITY_ )

        full_path_ = ::File.dirname full_path

        ev.to_event.path.should eql full_path_

        black_and_white( ev ).should eql "parent directory must exist - some-deep"

        expect_failed
      end

      context "and digraph is abspath whose dirname exists" do

        it "and digraph path is directory - no" do

          prepare_ws_tmpdir <<-O.unindent
            --- /dev/null
            +++ b/#{ cfn }
            @@ -0,0 +1 @@
            +[ whatever ]
            --- /dev/null
            +++ b/#{ cdn }/not-a-dotfile.dot/empty-file.txt
            @@ -0,0 +1 @@
            +
          O

          dgpn = @ws_pn.join "#{ cdn }/not-a-dotfile.dot"

          call_API :graph, :use,
            :digraph_path, dgpn.to_path,
            :workspace_path, @ws_pn.to_path, :config_filename, cfn

          expect_not_OK_event :wrong_ftype,
            /\A\(pth "[^"]+"\) exists but is not \(indefinite_noun #{
             }"file"\), it is \(indefinite_noun "directory"\)\z/

          expect_failed
        end

        it "and digraph path is file but config parse error" do

          shared_setup_via_config_line '["whtvr"]'
          expect_not_OK_event :config_parse_error
          expect_failed
        end

        it "and digraph path is file - OK" do

          shared_setup_via_config_line '[wiw]'

          expect_OK_event :collection_resource_committed_changes

          _read_config_file

          excerpt( -2 .. -1 ).should eql "[graph \"i-exist/like-a-boss.dog\" ]\n[wiw]\n"

          expect_succeeded
        end

        it "and diraph path is File object (A HACK)" do

          prepare_ws_tmpdir <<-O.unindent
            --- /dev/null
            +++ b/#{ cfn }
            @@ -0,0 +1 @@
            +[ graph "dingo-dango" ]
            --- /dev/null
            +++ b/#{ cdn }/open-this-yourself
            @@ -0,0 +1 @@
            + this will get overwritten
          O

          _file = @ws_pn.join( 'open-this-yourself' ).open( ::File::CREAT | ::File::EXCL | ::File::WRONLY )

          call_API :graph, :use,
            :digraph_path, _file,
            :workspace_path, @ws_pn.to_path, :config_filename, cfn

          @ev_a[ 0 .. -3 ] = EMPTY_A_

          expect_OK_event :wrote_file
          expect_OK_event :collection_resource_committed_changes
          expect_succeeded

          _read_config_file
          excerpt( 0 .. 0 ).should eql "[ graph \"../open-this-yourself\" ]\n"
        end

        def shared_setup_via_config_line config_line

          __like_a_boss config_line

          call_API :graph, :use,
            :digraph_path, @digraph_path,
            :workspace_path, @ws_pn.to_path, :config_filename, cfn
        end

        def __like_a_boss config_line

          prepare_ws_tmpdir <<-O.unindent
            --- /dev/null
            +++ b/#{ cfn }
            @@ -0,0 +1 @@
            +#{ config_line }
            --- /dev/null
            +++ b/#{ cdn }/i-exist/like-a-boss.dog
            @@ -0,0 +1 @@
            + but this is not a dotfile
          O

          @digraph_path = @ws_pn.join( "#{ cdn }/i-exist/like-a-boss.dog" ).to_path

          nil
        end

        def _read_config_file
          @output_s = @ws_pn.join( cfn ).read
          nil
        end

        context "and digraph does *not* exist" do

          it "and digraph path is without extension - adds ext, creates digraph" do

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

            expect_succeeded
          end

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
        end
      end
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
      st = flush_to_event_stream

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
  end
end
