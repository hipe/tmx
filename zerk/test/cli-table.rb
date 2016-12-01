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

    def against_stream_expect_lines_ tuple_st, & p

      act_st = design_ish_.line_stream_via_mixed_tuple_stream tuple_st

      if do_debug
        __flush_to_debug_IO_and_exit act_st
      else
        __against_this_expect_lines act_st, & p
      end
    end

    def __flush_to_debug_IO_and_exit act_st

      io = debug_IO

      io.puts "(there is no proper debug mode for tables.)"
      io.puts "(instead we flush the table and exit..)\n\n.\n"

      begin
        line = act_st.gets
        line || break
        io.puts line
        redo
      end while above

      io.puts ".\n\n#{ '>' * 80 }\nEXITING from #{ __FILE__ }\n#{ '<' * 80 }\n\n"
      exit 0
    end

    def __against_this_expect_lines act_st

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

    # (none of these "sayers" are covered)

    def __say_missing s
      "had no more lines but was expecing line: #{ s.inspect }"
    end

    def __say_extra s
      "unexpected extra line: #{ s.inspect }"
    end

    def table_module_
      Home_::CLI::Table
    end
  end
end
# #history: what is spiritually the predecessor of this is the root t.s for [tab]
