module Skylab::DocTest::TestSupport

  module Runs

    def self.[] tcc
      tcc.include self
    end

    # -

      def at_index_expect_cat_sym_and_num_lines_ d, sym, d_

        run = _a.fetch d
        run.category_symbol == sym or fail
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

    # ==

    Code_run_via_big_string = -> big_s do
      Functions__.__code_run big_s
    end

    Discussion_run_via_big_string = -> big_s do
      Functions__.__discussion_run big_s
    end

    module Functions__ ; class << self

      # we're not sure about this: we wanted to be able to create
      # individual runs without using the magnet but this is rough

      def __discussion_run big_s

        st = line_stream_via_string_ big_s

        dr = Home_::Models_::Discussion::Run.new_empty__

        s = st.gets
        begin
          dr.accept_line_via_offsets( * __disc_etc( s ), s )
          s = st.gets
        end while s

        dr
      end

      def __code_run big_s

        st = line_stream_via_string_ big_s

        s = st.gets
        cr = Home_::Models_::Code::Run.begin_via_offsets__( * _code_etc( s ), s )
        while s = st.gets
          cr.accept_line_via_offsets( * _code_etc( s ), s )
        end

        cr
      end

      def __disc_etc line

        m_r, c_r, l_r = _three line
        if c_r.size.zero?
          ::Kernel._ETC
        else
          [ m_r, c_r, l_r ]
        end
      end

      def _code_etc line

        m_r, c_r, l_r = _three line
        if c_r.size.zero?
          ::Kernel._ETC
        else
          [ m_r, c_r, l_r ]
        end
      end

      def line_stream_via_string_ s  # again
        Home_.lib_.basic::String.line_stream s
      end

      def _three line  # EEK

        md = Home_::Magnetics_::BlockStream_via_LineStream_and_Single_Line_Comment_Hack::HACK_RX__.match line

        lib = Home_::Magnetics_::RunStream_via_CommentBlock
        md_ = lib::RX___.match line, md.offset( 0 ).last

        ( 1 .. 3 ).map do |d|
          lib::Range__[ md_.offset( d ) ]
        end
      end
    end ; end
  end
end
