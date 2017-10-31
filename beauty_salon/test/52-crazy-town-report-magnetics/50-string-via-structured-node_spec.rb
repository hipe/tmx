require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town report magnetics - string via etc', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    context 'just as an exercise, try this' do

      it 'before node builds' do
        _structured_node_before || fail
      end

      it 'modded node builds' do
        structured_node_ || fail
      end

      it 'say hello to our little magnet friend' do
        subject_magnetic_ || fail
      end

      it 'the replacement lines preserve the indent present in the original document' do
        # #testpoint3.2
        _thing_ding( 1 ) == 2 || fail
      end

      it 'the first line, however is not indented at all' do
        _thing_ding( 0 ) == 0 || fail
      end

      it 'the last lines does NOT have the trailing newline!' do
        _lines.fetch( 3 ) =~ /\bend\z/ || fail
      end

      it 'the replacements were made (byte-by-byte verification, too)' do

        expect_these_lines_in_array_ _lines do |y|

          y << %r(\bmy_lvar = some_method_call  # lvasgn\b)
          y << "  if my_lvar  # conditional, lvar access\n"
          y << "    true  # literal\n"
          y << %r(\A  end$)
        end
      end

      def _thing_ding d
        _lines_ = _lines
        _line = _lines_.fetch d
        md = _line.match %r(\A[ ]+)
        if md
          beg, end_ = md.offset 0
          end_ - beg
        else
          0
        end
      end

      shared_subject :_lines do
        _money.split %r(^)
      end

      shared_subject :structured_node_ do

        _sn = _structured_node_before

        _sn2 = _sn.DIG_AND_CHANGE_TERMINAL(
          :zero_or_more_expressions,
          0,
          :lvar_as_symbol,
          :my_lvar,
        )

        _sn2.DIG_AND_CHANGE_TERMINAL(
          :zero_or_more_expressions,
          1,
          :condition_expression,
          :symbol,
          :my_lvar
        )
      end

      shared_subject :_structured_node_before do
        structured_node_via_string_ <<~O
          # leftmost thing
            _my_lvar = some_method_call  # lvasgn
            if _my_lvar  # conditional, lvar access
              true  # literal
            end
        O
      end
    end

    def _money
      _sn = structured_node_
      _sn.to_code_LOSSLESS_EXPERIMENT__
    end

    def subject_magnetic_
      Home_::CrazyTownReportMagnetics_::String_via_StructuredNode
    end
  end
end
# #born.
