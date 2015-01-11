require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Graph

  describe "[tm] models graph use" do

    extend TS_

    TestSupport_::Expect_line[ self ]

    context "when no workspace" do

      it "no args - missing the one required arg" do

        call_API :graph, :use

        expect_not_OK_event :missing_required_properties do | ev |
          ev.to_event.miss_a.first.name_i.should eql :digraph_path
        end

        expect_failed
      end

      it "just digraph path, no ws resolution" do

        call_API :graph, :use,
          :digraph_path, 'some-path'

        ev = expect_not_OK_event :missing_required_properties
        black_and_white( ev ).should eql "missing required property 'path'"

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
          ev.filename.should eql cfn
          ev.start_pathname.should eql @ws_pn
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

        expect_event :adding_extension

        ev = expect_not_OK_event :resource_not_found

        full_path_ = ::File.dirname full_path

        ev.to_event.path.should eql full_path_

        black_and_white( ev ).should eql "No such file or directory - some-deep"

        expect_failed
      end

      context "and digraph is abspath whose dirname exists" do

        it "and digraph path is directory - no" do

          prepare_ws_tmpdir <<-O.unindent
            --- /dev/null
            +++ b/#{ cfn }
            @@ -0,0 +1 @@
            +[ "whatever" ]
            --- /dev/null
            +++ b/#{ cdn }/not-a-dotfile.dot/empty-file.txt
            @@ -0,0 +1 @@
            +
          O

          dgpn = @ws_pn.join "#{ cdn }/not-a-dotfile.dot"

          call_API :graph, :use,
            :digraph_path, dgpn.to_path,
            :workspace_path, @ws_pn.to_path, :config_filename, cfn

          expect_not_OK_event :resource_is_wrong_shape,
            /\Aexpected \(val "file"\) had \(ick "directory"\) - #{
              }\(pth #<Pathname:[^>]+not-a-dotfile\.dot>\)\z/

          expect_failed
        end

        it "and digraph path is file but config parse error" do

          shared_setup_via_config_line '["whtvr"]'
          expect_not_OK_event :config_parse_error
          expect_failed

        end

        it "and digraph path is file" do

          shared_setup_via_config_line '[whtvr]'

          expect_OK_event :datastore_resource_committed_changes

          cpn = @ws_pn.join cfn

          @output_s = cpn.read

          excerpt( -2 .. -2 ).should eql "[graph \"i-exist/like-a-boss.dog\"]\n"

          expect_succeeded
        end

        def shared_setup_via_config_line config_line

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

          dgpn = @ws_pn.join "#{ cdn }/i-exist/like-a-boss.dog"

          call_API :graph, :use,
            :digraph_path, dgpn.to_path,
            :workspace_path, @ws_pn.to_path, :config_filename, cfn
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

            ev = expect_neutral_event :adding_extension
            black_and_white( ev ).should eql "adding .dot extension to make-me"

            ev = expect_not_OK_event :entity_not_found
            black_and_white( ev ).should eql "in config there are no starters"

            ev = expect_neutral_event :using_default
            black_and_white( ev ).should match(
              /\Ausing default starter "holy-smack\.dot" \(the last of [23] starters\)/ )

            ev = expect_OK_event :wrote_file
            black_and_white( ev ).should match(
              /\Awrote make-me\.dot \([456]\d\d bytes\)/ )

            ev = expect_OK_event :datastore_resource_committed_changes
            black_and_white( ev ).should match(
              %r(\Aupdated config \(\d{2} bytes\)) )

            io = dg_pn.sub_ext( '.dot' ).open( READ_MODE_ )
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

            expect_not_OK_event :entity_not_found
            expect_event :using_default
            ev = expect_event :wrote_file
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
  end
end
