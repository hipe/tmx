require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - SNvN - literals', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_THIS_STUFF

    context 'parse just an integer' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'read the integer as an integer' do
        _x = at_ _primitive_value
        14 == _x || fail
      end

      shared_subject :structured_node_ do
        structured_node_via_string_ '14'
      end
    end

    # --

    def _primitive_value
      :as_integer
    end

    # ==
    # ==
  end
end
# :#testpoint2.1
# #born.
