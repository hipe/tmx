require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] magnetics - node stream via block stream" do

    # NOTE
    #   • if any of these fail, try falling back to the test file #file-1.
    #     (the regression order would have otherwise cut across folders.)
    #
    #   • this will probably redund heavily with logic we will want
    #     elsewhere, but we don't know yet what the interface will be
    #     for this "bare" output..

    TS_[ self ]
    use :memoizer_methods
    use :embedded_line_collections

    it "(the synopsis example in the README)" do

      # (because for now the main README has only one example (the synopsis),
      #  here's what it looks like to one-off ELC access for such cases:)

      fi = _ELC_file_via_path full_path_ 'README.md'

      _ls = fi.line_stream_via_regex %r(\bcontains a snippet like this\z)

      o = magnetics_module_

      _bs = o::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ _ls ]

      _ns = o::NodeStream_via_BlockStream_and_Choices[ _bs, :_no_tfc_2_, real_default_choices_ ]

      exp_st = fi.line_stream_via_regex %r(\bproduces this\z)
      fi.close_if_necessary

      expect_actual_line_stream_has_same_content_as_expected_(
        o::LineStream_via_NodeStream[ _ns ],
        exp_st,
      )
    end
  end
end
# this test file is #file-2
