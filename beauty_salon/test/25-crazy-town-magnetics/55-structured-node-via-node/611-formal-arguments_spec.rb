require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - SNvN - formal arguments', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_THIS_STUFF

    # #covers:`def`

    # NOTE - this is a rough sketch. we will need to assimilate the many
    # args soon and so we will want to recurse into the other components
    # of this guy, but not yet..

    context 'x.' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'oh geez' do
        at_( _thing_one ) == :foo || fail
      end

      shared_subject :structured_node_ do
        structured_node_via_string_ "def foo x, y=nil, & z; end"
      end
    end

    # --

    def _thing_one
      :symbol
    end


    # ==
    # ==
  end
end
# #born.
