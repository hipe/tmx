require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] magnetics - run stream via comment block" do

    TS_[ self ]
    use :memoizer_methods
    use :embedded_line_collections

    # (possibly like its sibling, this one stays tightly to this file:)

    in_file do
      full_path_ 'doc/issues/021-what-are-runs.md'
    end

    context "(first example)" do

      shared_subject :_a do
        _for %r(\bthis simple example\z)
      end

      it "(builds)" do
        _a or fail
      end

      context "(discussion run)" do

        it "has discussion run, is 3 lines long (#coverpoint-1)" do
          run = _run
          run.category_symbol___ == :discussion or fail
          run.number_of_lines___ == 3 or fail
        end

        it "this discussion run is lossless" do

          _exp = <<-HERE.unindent
            # hi i'm discussion line A
            # hi i'm discussion line B
            #
          HERE

          _assemble_string == _exp or fail
        end

        def _run
          _a.fetch 0
        end
      end

      context "(code run)" do

        it "has code run, is 1 line long" do
          run = _run
          run.category_symbol___ == :code or fail
          run.number_of_lines___ == 1 or fail
        end

        it "code run is lossless" do

          _assemble_string == "#     1 + 1  # => 2\n" or fail
        end

        def _run
          _a.fetch 1
        end
      end

      def _assemble_string
        _run.to_line_object_stream___.reduce_into_by "" do |s, o|
          s << o.string___
        end
      end

      context "(general)" do

        it "has no other runs" do
          _a.length == 2 or fail
        end
      end
    end

    context "(this second example) (#coverpoint-2)" do

      shared_subject :_a do
        _for %r(\bas it does in this example\b)
      end

      it "builds, is 2 runs in length" do
        _a.length == 2 or fail
      end

      it "(disc run)" do
        _at_index_expect_cat_sym_and_num_lines 0, :discussion, 3
      end

      it "(code run)" do
        _at_index_expect_cat_sym_and_num_lines 1, :code, 1
      end
    end

    context "(this final example) (#coverpoint-3)" do

      shared_subject :_a do
        x = _for %r(\bas in this example\b)
        _ELC_close_if_necessary  # NOTE only while you're sure it's the last one!
        x
      end

      it "builds" do
        _a
      end

      it "(disc / code / disc)" do
        _at_index_expect_cat_sym_and_num_lines 0, :discussion, 1
        _at_index_expect_cat_sym_and_num_lines 1, :code, 1
        _at_index_expect_cat_sym_and_num_lines 2, :discussion, 1
      end
    end

    def _at_index_expect_cat_sym_and_num_lines d, sym, d_

      run = _a.fetch( d )
      run.category_symbol___ == sym or fail
      run.number_of_lines___ == d_ or fail
    end

    def _for rx

      _cb = __exactly_one_comment_block_for rx
      _st = magnetics_module_::RunStream_via_CommentBlock[ _cb ]
      _st.to_a
    end

    def __exactly_one_comment_block_for rx

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
  end
end
# history: this is a rename-and-cleanup of another test file numbered "66"
