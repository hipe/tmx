module Skylab::DocTest::TestSupport

  module Runs

    def self.[] tcc
      tcc.include self
    end

    # -

      def at_index_expect_cat_sym_and_num_lines_ d, sym, d_

        run = _a.fetch d
        run.category_symbol___ == sym or fail
        run.number_of_lines___ == d_ or fail
      end

      def run_array_via_regex_ rx

        _cb = __RUNS_exactly_one_comment_block_for rx
        _st = magnetics_module_::RunStream_via_CommentBlock[ _cb ]
        _st.to_a
      end

      def __RUNS_exactly_one_comment_block_for rx

        cb = nil
        _line_st = _ELC_line_stream_after rx
        st = magnetics_module_::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ _line_st ]

        begin
          blk = st.gets
          blk or break
          sym = blk.category_symbol
          :static == sym && redo
          :comment == sym || ::Kernel._EEK
          cb and ::Kernel._EEK
          cb = blk
          redo
        end while nil
        cb || ::Kernel._EEK
      end
    # -
  end
end
