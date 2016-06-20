module Skylab::DocTest

  class Models_::AssetDocument

    class << self

      def via_line_stream___ line_st  # #testpoint-only (for now)
        new.__init_via_line_stream line_st
      end

      private :new
    end  # >>

    def initialize
      @_indexes_of_blocks_with_magic = nil
      @_blocks = []
    end

    # -- initting from line stream ONLY

    def __init_via_line_stream line_st

      block_st = Magnetics_::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ line_st ]
      begin
        block = block_st.gets
        block or break
        send CAT_SYM___.fetch( block.category_symbol ), block
        redo
      end while nil

      if @_indexes_of_blocks_with_magic
        @HAS_MAGIC = true
      end

      self
    end

    CAT_SYM___ = {
      comment: :__process_comment_block,
      static: :__accept_static_block,
    }

    # -- reading

    def to_line_stream___  # #testpoint-only
      Common_::Stream.via_nonsparse_array( @_blocks ).expand_by do |blk|
        blk.to_line_stream_
      end
    end

    # -- initting support

    def __accept_static_block blk
      @_blocks.push blk ; nil
    end

    def __process_comment_block cb

      # IFF we see magic anywhere in the comment block, then what we store
      # is a magic block. otherwise store it as-is as a comment block.

      a = []
      indexes_of_runs_with_magic = nil

      st = Magnetics_::RunStream_via_CommentBlock[ cb ]

      begin
        run = st.gets
        run || break
        if :code == run.category_symbol && run.has_magic_copula
          ( indexes_of_runs_with_magic ||= [] ).push a.length
        end
        a.push run
        redo
      end while nil

      if indexes_of_runs_with_magic
        ( @_indexes_of_blocks_with_magic ||= [] ).push @_blocks.length
        @_blocks.push MagicCommentBlock___.new( indexes_of_runs_with_magic, a )
      else
        @_blocks.push cb
      end
      NIL_
    end

    # ==

    class MagicCommentBlock___

      def initialize d_a, run_a
        @_indexes_of_runs_with_matgic = d_a
        @_runs = run_a
      end

      def to_line_stream_  # might be #testpoint-only..
        Common_::Stream.via_nonsparse_array( @_runs ).expand_by do |run|
          run.to_line_stream_
        end
      end
    end
  end
end
