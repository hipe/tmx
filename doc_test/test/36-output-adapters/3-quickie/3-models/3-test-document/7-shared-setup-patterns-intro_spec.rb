require_relative '../../../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] output adapters - quickie - [..] - shared setup patterns" do

    TS_[ self ]
    use :memoizer_methods
    use :embedded_line_collections

    # (this test file bears similiary to the #coverpoint2 family)

    in_file do
      full_path_ 'doc/issues/010-magic-for-patterns-of-shared-setup.md'
    end

    context "#coverpoint5.1" do

      shared_subject :_nodes do
        _st = first_fake_file_node_stream_corresponding_to_regex_(
          %r(\bhere's a Dr\. Seuss story\z) )
        _st.to_a
      end

      it "builds, 1 node" do
        _nodes.length == 1 or fail
      end

      it "(every byte)" do

        _a_st = _nodes.first.to_line_stream( & Want_no_emission_ )

        _e_st = _ELC_line_stream_after %r(\bthe above produces\z)

        want_actual_line_stream_has_same_content_as_expected_ _a_st, _e_st
      end
    end

    def _nodes
      _tuple.nodes
    end

    def _for rx
      first_node_stream_corresponding_to_regex_( rx ).to_a.freeze
    end
  end
end
