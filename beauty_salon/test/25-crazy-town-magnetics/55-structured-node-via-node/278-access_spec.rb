require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - SNvN - access', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    context '(picking up from the basics as seen in the last test file)' do

      # #covers:`const` #covers:`ivar`

      it 'builds' do
        structured_node_ || fail
      end

      it 'crimeney' do
        _x = at_ _left_shark
        _x.symbol == :@wee || fail
      end

      shared_subject :structured_node_ do
        structured_node_via_string_ '@wee::Bar'
      end
    end

    # (covering accessign an ivar is done over at #coverpoint2.5 expressions grouping)

    # --

    def _left_shark
      :any_parent_const_expression
    end

    # ==
    # ==
  end
end
# :#coverpoint2.3
# #born.
