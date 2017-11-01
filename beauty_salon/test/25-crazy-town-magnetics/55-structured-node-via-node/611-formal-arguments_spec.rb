require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - SNvN - formal arguments', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    # #covers:`def`

    # NOTE - this is a rough sketch. we will need to assimilate the many
    # args soon and so we will want to recurse into the other components
    # of this guy, but not yet..

    it 'builds' do
      structured_node_ || fail
    end

    it 'oh geez' do
      at_( _thing_one ) == :foo || fail
    end

    it %{'args' is just there as this useless thing} do
      _x = _args
      _x._node_type_ == :args || fail
    end

    it '..necessitating this weirdly named thing' do
      _argfellows.length == 3 || fail
    end

    it 'this one kind' do
      _x = _argfellows.dereference 0
      _as_symbol( _x ) == :x || fail
    end

    it 'this other kind' do
      x = _argfellows.dereference 1
      x.as_symbol == :y || fail
      x.default_value_expression._node_type_ == :nil || fail
    end

    it 'this third kind' do
      _x = _argfellows.dereference 2
      _as_symbol( _x ) == :z || fail
    end

    def _argfellows
      _args.zero_or_more_argfellows
    end

    def _args
      structured_node_.args
    end

    shared_subject :structured_node_ do
      structured_node_via_string_ "def foo x, y=nil, & z; end"
    end

    # --

    def _as_symbol o
      o.as_symbol
    end

    def _thing_one
      :method_name
    end

    # ==
    # ==
  end
end
# #born.
