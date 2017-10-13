require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - SNvN - assignment', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    context 'ivar assignment' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'the ivar (the left hand side) is a symbol' do
        _x = _left_shark
        _x == :"@foo_bar" || fail
      end

      it 'right hand side - any expression, appropriate to the thing' do
        # (this type of grammar symbol is covered in a previous test. make minimal contact here.)
        # #testpoint1.54
        _x = _right_shark
        _x._node_.type == :int || fail
      end

      def _left_shark_method_name
        :ivar_as_symbol
      end

      shared_subject :structured_node_ do
        structured_node_via_string_ '@foo_bar = 15'
      end
    end

    context 'lvar assignment' do

      # #covers:`nil`

      it 'builds' do
        structured_node_ || fail
      end

      it 'the left hand side (the lvar) is a symbol' do
        _x = _left_shark
        _x == :righty || fail
      end

      it 'right hand side - any expression, appropriate to the thing' do
        _x = _right_shark
        _x._node_.type == :nil || fail
      end

      shared_subject :structured_node_ do
        structured_node_via_string_ 'righty = nil'
      end

      def _left_shark_method_name
        :lvar_as_symbol
      end
    end

    # ==

    def _left_shark
      at_ _left_shark_method_name
    end

    def _right_shark
      at_ :zero_or_one_right_hand_side_expression
    end

    # ==
    # ==
  end
end
# :#testpoint2.2
# #born.
