require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] [..] block stream via line stream and single line commen hack" do

    TS_[ self ]
    use :embedded_line_collections

    # (this file drove the development of "ELC's")
    # (the tests here stay very close to the examples in this file:)

    in_file do
      full_path_ 'doc/issues/020-what-are-comment-blocks.md'
    end

    it "(change in colum of '#' makes a new comment block)" do

      _for %r(\bit forms a new comment block\z)
      _static
      _comment
      _comment
      _done
    end

    it "(when comment line has same indent as previous, same block)" do

      _for %r(\bbecomes part of the same block\z)
      _comment
      _static
      _comment
      _static
      _comment
      _done
    end

    it "(blanks break)" do

      _for %r(\bbreak a comment block\z)
      _comment
      _static
      _comment
      _done
    end

    it "(blanks within the block do not break the block)" do

      _for %r(\bnot break a comment block\z)
      _ELC_close_if_necessary

      _comment
      _done
    end

    def _for rx
      _line_stream = _ELC_line_stream_after rx
      @_stream = Home_::AssetDocumentReadMagnetics_::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ _line_stream ]
      NIL_
    end

    def _static
      _blk = @_stream.gets
      _blk.category_symbol == :static or fail
    end

    def _comment
      _blk = @_stream.gets
      _blk.category_symbol == :comment or fail
    end

    def _done
      _blk = @_stream.gets
      _blk and fail
    end
  end
end
# #history: a rename-and-edit of "comment block stream via [same]"
