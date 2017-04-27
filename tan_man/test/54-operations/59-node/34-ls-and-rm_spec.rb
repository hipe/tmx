require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] node list and remove" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API
    use :models_node

# (1/N)
    context "a workspace without a graph value complains & invite" do

      it "fails" do
        _fails_normally
      end

      it "structured event details (invite)" do

        ev = _tuple.first

        ev.reason_symbol == :section_not_found || fail
        ev.component_name_symbol == :digraph || fail
        ev.invite_to_action == [ :graph, :use ] || fail
      end

      it "event message" do

        _actual = black_and_white_lines _tuple.first

        expect_these_lines_in_array_ _actual do |y|
          y << 'section "digraph" not found in tan-man.conf'
        end
      end

      shared_subject :_tuple do

        _dir = dir :with_freshly_initted_conf

        call_API(
          * _subject_action_one,
          :workspace_path, _dir,
          :config_filename, 'tan-man.conf',
        )

        a = []
        expect :error, :config_component_not_found do |ev|
          a.push ev
        end

        a.push execute
      end
    end

# (2/N)
    it "`list` results in a stream of items that know their name" do

        call_API(
          * _subject_action_one,
          :workspace_path, dir( :two_nodes ),
          :config_filename, cfn_shallow,
        )

        st = execute

        x = st.gets
        x.node_name_symbol_ == :foo || fail

        x = st.gets
        x.node_name_symbol_ == :bar || fail

        st.gets.should be_nil
    end

# (3/N)
    context "remove nope" do

      it "fails" do
        _fails_normally
      end

      it "event.." do

        ev = _tuple.first
        ev.component.as_slug == "berk" || fail
        _actual = black_and_white ev
        _actual == 'node not found - "berk"' || fail
      end

      shared_subject :_tuple do

        call_API(
          * _subject_action_two,
          :node_name, "berk",
          :workspace_path, dir( :two_nodes ),
          :config_filename, cfn_shallow,
        )

        a = []
        expect :error, :node_not_found do |ev|
          a.push ev
        end
        a.push execute
      end
    end

# (4/N)
    context "remove money" do

      expected_bytes = 14

      it "result is a structure with a small amount of info" do

        sct = _tuple.last
        sct.bytes == expected_bytes || fail
        sct.user_value == true || fail
      end

      it "file looks OK (not perfect but OK)" do

        sct = _tuple.first
        io = ::File.open sct.dotfile_path

        expect_these_lines_in_array_with_trailing_newlines_ io do |y|
          y << "digraph {"
          y << "  }"
        end

        io.close
      end

      it "event members" do

        ev = _first_event
        ev.is_completion == true || fail
        ev.bytes == expected_bytes || fail
        ev.was_dry_run && fail
        ev.byte_downstream_reference.path || fail
        ev.is_completion || fail
        ev.ok || fail
      end

      it "event message" do

        _actual = black_and_white _first_event
        _actual == "updated the.dot (#{ expected_bytes } bytes)" || fail
      end

      def _first_event
        _tuple[1]
      end

      shared_subject :_tuple do

        o = given_dotfile_ <<-O.unindent
          digraph {
            ermagherd [ label = "berks" ]
          }
        O

        # o = given_dotfile_FAKE_ "#{ ENV['HOME'] }/tmp/__tmx_dev_tmpdir__/tm-testing-cache/volatile-tmpdir"
        a = [ o ]

        call_API(
          * _subject_action_two,
          :node_name, "berks",
          :workspace_path, o.workspace_path,
          :config_filename, o.config_filename,
        )

        expect :succeeded, :wrote_resource do |ev|
          a.push ev
        end

        a.push execute
      end
    end

    def _fails_normally
      _x = _tuple.last
      _x.nil? || fail
    end

    def _subject_action_one
      [ :node, :ls ]
    end

    def _subject_action_two
      [ :node, :rm ]
    end

    # ==
    # ==
  end
end
