module Skylab::Zerk::TestSupport

  module CLI_Table

    class << self
      def [] tcc
        tcc.include self
      end
    end  # >>

    def against_tuples_expect_lines_ * a_a, & p

      against_matrix_expect_lines_ a_a, & p
    end

    def against_matrix_expect_lines_ a_a, & p

      against_stream_expect_lines_ Home_::Stream_[ a_a ], & p
    end

    def against_stream_expect_lines_ tuple_st

      act_st = design_ish_.line_stream_via_mixed_tuple_stream tuple_st

      _yielder = ::Enumerator::Yielder.new do |exp_line|

        act_line = act_st.gets
        if act_line
          if exp_line != act_line
            act_line.should eql exp_line
          end
        else
          fail __say_missing exp_line
        end
      end

      yield _yielder

      unexp_line = act_st.gets
      if unexp_line
        fail __say_extra unexp_line
      end

      NIL
    end

    def __say_expected_had_none s
      "exepected line but had no more lines: #{ s.inspect }"
    end

    def __say_extra s
      "unexpected extra line: #{ s.inspect }"
    end

    def out_via_tuples_ * a_a
      out_via_in_
    end

    def out_via_in_ tuple_st
    end

    def table_module_
      Home_::CLI::Table
    end
  end
end
# #history: what is spiritually the predecessor of this is the root t.s for [tab]
