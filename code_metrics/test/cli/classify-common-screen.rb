module Skylab::CodeMetrics::TestSupport

  class CLI::Classify_Common_Screen

    # (this is probably a predecessor to etc in [br] "expect section")

    class << self

      def [] tcc
        tcc.include Test_Context_Instance_Methods__
      end
    end  # >>

    module Test_Context_Instance_Methods__

      def build_info_line_stream_

        _s_a = _memoized_common_screen_classifications.__info_lines
        Common_::Stream.via_nonsparse_array _s_a
      end

      def headers_
        _memoized_common_screen_classifications.__headers
      end

      def string_matrix_
        _memoized_common_screen_classifications.__string_matrix
      end

      def _memoized_common_screen_classifications
        es = execution_snapshot_
        es.memo[ :__my_memo__ ] ||= Build_my_memo___.new( es ).execute
      end
    end

    My_Memo___ = ::Struct.new(
      :__info_lines,
      :__headers,
      :__string_matrix
    )

    class Build_my_memo___

      def initialize es
        @execution_snapshot = es
      end

      def execute

        @_st = Common_::Stream.via_nonsparse_array(
          @execution_snapshot.output_lines )

        __resolve_contiguous_info_lines
        __resolve_headers
        __resolve_string_matrix
        My_Memo___.new @_info_lines, @_header_line, @_string_matrix
      end

      def __resolve_contiguous_info_lines

        info_line_a = []
        st = @_st

        begin
          line_o = st.gets
          line_o or break
          if :e == line_o.stream_symbol
            info_line_a.push line_o.string
            redo
          end
          @_line_o = line_o
          break
        end while nil

        @_info_lines = info_line_a
        NIL_
      end

      def __resolve_headers

        _s_a = Celify_row_line__[ @_line_o.string ]

        _sym_a = _s_a.map do | s_ |
          if s_.length.zero?
            :_blank_header_
          else
            s_.downcase.gsub( SPACE_, UNDERSCORE_ ).intern
          end
        end

        @_header_line = _sym_a
        NIL_
      end

      def __resolve_string_matrix

        s_a_a = []
        st = @_st

        begin
          line_o = st.gets
          line_o or break
          s_a_a.push Celify_row_line__[ line_o.string ]
          redo
        end while nil

        @_string_matrix = s_a_a
        NIL_
      end
    end

    Celify_row_line__ = -> do

      rx = %r([ ]*\|[ ]*)

      -> s do

        s_a = s.split rx

        EMPTY_S_ == s_a.first or fail  # left flank glyph

        NEWLINE_ == s_a.last or fail  # right flank glyph

        s_a[ 1 ... -1 ]
      end
    end.call

    module Test_Context_Instance_Methods__

      # ~ expectations

      define_method :expect_absolute_path_, -> do

        rx = /\A\/.+[a-z]+\.code\z/

        -> x do

          if rx !~ x
            fail "must look like absolute path: #{ x.inspect }"
          end
        end
      end.call

      define_method :expect_integer_, -> do

        rx = /\A  (?<num>  \d+  ) \z/x

        -> x, exp_d=nil do

          md = rx.match x
          if md
            if exp_d
              d = md[ :num ].to_i
              if ! exp_d.include? d
                fail "expecting integer #{ d } to be in #{ exp_d }"
              end
            end
          else
            fail "expecting this to look like integer - #{ x.inspect }"
          end
        end

      end.call

      define_method :expect_percent_, -> do

        rx = /\A (?<num> \d{1,3} \. \d\d ) % \z/x

        -> x, expect_f=nil do

          md = rx.match x

          if md
            if expect_f
              md[ :num ].to_f.should eql expect_f
            end
          else
            fail "expecting this to look like percent - #{ x.inspect }"
          end
        end
      end.call

      def expect_pluses_ sm, row_range, col_index, * more_or_less

        o = Expect_Pluses___.new
        o.column_index = col_index
        o.row_classifications = more_or_less
        o.row_range = row_range
        o.string_matrix = sm
        o.test_context = self
        o.execute
      end

      class Expect_Pluses___

        attr_writer(
          :column_index,
          :row_classifications,
          :row_range,
          :string_matrix,
          :test_context,
          :execute,
        )

        def execute

          _num_pluses = ___build_num_pluses

          _act = Home_.lib_.basic::List.classify(
            _num_pluses,
            [ :low, :medium, :high ],
          )

          _act.should @test_context.eql @row_classifications
        end

        def ___build_num_pluses

          num_pluses = []

          col_index = @column_index
          # unstyle = Home_.lib_.brazen::CLI_Support::Styling::Unstyle_styled
          sm = @string_matrix
          r = @row_range
          last = r.end
          if 0 > last
            last = sm.length - last
          end

          ( r.begin.upto last ).each do |d|
            _row = sm.fetch d
            s = _row.fetch col_index
            if s.length.zero?
              self._OOPS
            end
            # s = unstyle[ s ]
            num_pluses.push RX___.match( s )[ 0 ].length
          end

          num_pluses
        end

        RX___ = /\A\++\z/
      end
    end

    UNDERSCORE_ = '_'
  end
end
