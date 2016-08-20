require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] models - context (paraphernalia) (intro)" do

    TS_[ self ]
    use :memoizer_methods
    use :embedded_line_collections
    # use :case

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

        _a_st = _a.first.to_line_stream

        _e_st = _ELC_line_stream_after %r(\bthe above makes this\z)

        expect_actual_line_stream_has_same_content_as_expected_ _a_st, _e_st
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

        _a_st = magnetics_module_::LineStream_via_NodeStream[
          Common_::Stream.via_nonsparse_array( _a ) ]

        _e_st = _ELC_line_stream_after %r(\byou'll get\z)
        _ELC_close_if_necessary

        expect_actual_line_stream_has_same_content_as_expected_ _a_st, _e_st
      end
    end

    # not yet covered: #coverpoint2-1: a comment block with no code run

    def _for rx

      _line_st = _ELC_line_stream_after rx
      o = magnetics_module_
      _bs = o::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ _line_st ]
      _ns = o::NodeStream_via_BlockStream_and_Choices[ _bs, real_default_choices_ ]
      # (wants [#ta-005])
      _ns.to_a
    end
  end
end
