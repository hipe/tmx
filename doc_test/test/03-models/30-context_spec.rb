require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] models - context (paraphernalia) (intro)" do

    TS_[ self ]
    use :memoizer_methods
    use :embedded_line_collections

    in_file do
      full_path_ 'doc/issues/003-how-nodes-are-generated.md'
    end

    context "OE #coverpoint2-3" do

      shared_subject :_a do
        _for %r(\bpatterns in the comment block\z)
      end

      it "builds, 1 node" do
        _a.length == 1 or fail
      end

      it "(every byte)" do

        _a_st = _a.first.to_line_stream( & Want_no_emission_ )

        _e_st = _ELC_line_stream_after %r(\bthe above makes this\z)

        want_actual_line_stream_has_same_content_as_expected_ _a_st, _e_st
      end
    end

    # -
      it "OO #coverpoint2-2" do
        _for( %r(\bonly unassertive ones\z) ).length.zero? or fail
      end
    # -

    context "EE (comes out flatly) #coverpoint2-4" do

      shared_subject :_a do
        _for %r(\beach of which has an assertion\z)
      end

      it "builds, 2 nodes" do
        _a.length == 2 or fail
      end

      it "(every byte)" do

        _a_st = Home_::AssetDocumentReadMagnetics_::
          LineStream_via_NodeStream[ Stream_[ _a ], & Want_no_emission_ ]

        _e_st = _ELC_line_stream_after %r(\byou'll get\z)
        _ELC_close_if_necessary

        want_actual_line_stream_has_same_content_as_expected_ _a_st, _e_st
      end
    end

    # not yet covered: #coverpoint2-1: a comment block with no code run

    def _for rx
      first_node_stream_corresponding_to_regex_( rx ).to_a.freeze
    end
  end
end
