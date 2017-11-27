# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town report magnetics - string via structured node', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

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
        # #coverpoint3.2
        _thing_ding( 1 ) == 2 || fail
      end

      it 'the first line, however is not indented at all' do
        _thing_ding( 0 ) == 0 || fail
      end

      it 'the last lines does NOT have the trailing newline!' do
        _lines.fetch( 3 ) =~ /\bend\z/ || fail
      end

      it 'the replacements were made (byte-by-byte verification, too)' do

        want_these_lines_in_array_ _lines do |y|

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
        build_lines_
      end

      shared_subject :structured_node_ do

        _sn = _structured_node_before

        _sn2 = _dig_and_change_terminal(
          :zero_or_more_expressions,
          0,
          :lvar_as_symbol,
          :my_lvar,
          _sn,
        )

        _dig_and_change_terminal(
          :zero_or_more_expressions,
          1,
          :condition_expression,
          :symbol,
          :my_lvar,
          _sn2,
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

    context 'hello fellows - change a method name' do

      it 'the change effects' do
        structured_node_ || fail
      end

      it 'neat' do
        want_these_lines_in_array_ build_lines_ do |y|
          y << "def dadunk foo, bar=nil, baz: nil\n"
          y << "  Const_CHANGED::Const2\n"
          y << 'end'
        end
      end

      shared_subject :structured_node_ do

        _sn = _structured_node_before

        _sn2 = _dig_and_change_terminal(
          :method_name,
          :dadunk,
          _sn,
        )

        _dig_and_change_terminal(
          :any_body_expression,
          :any_parent_const_expression,
          :symbol,
          :Const_CHANGED,
          _sn2,
        )
      end

      shared_subject :_structured_node_before do

        structured_node_via_string_ <<~O
          def chabunk foo, bar=nil, baz: nil
            Const1::Const2
          end
        O
      end
    end

    def _dig_and_change_terminal * x_a, sn
      sn.DIG_AND_CHANGE_TERMINAL( * x_a )
    end

    def subject_magnetic_
      Home_::CrazyTownUnparseMagnetics_::String_via_StructuredNode
    end
  end
end
# #history-A.2: de-monolithize large test file into 6 smaller files.
# #born.
