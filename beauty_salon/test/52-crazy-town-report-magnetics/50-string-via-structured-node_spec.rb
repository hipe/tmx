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
  end
end
# #born.
