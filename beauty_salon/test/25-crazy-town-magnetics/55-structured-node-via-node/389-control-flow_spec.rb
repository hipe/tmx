require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - SNvN - control flow', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    context 'normal case' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'first child builds and is the thing' do
        _x = _scrutinized
        _x._node_type_ == :int || fail  # covered in #coverpoint1.1
      end

      it 'second child (component) builds' do
        _whens || fail
      end

      it 'third child builds and is' do
        _x = _else
        _x._node_type_ == :int || fail  # covered in #coverpoint1.1
      end

      def structured_node_
        _same_thing
      end
    end

    context 'when' do

      it 'the matchables are a list' do
        matchers = _first_when.one_or_more_matchable_expressions
        matchers.length == 1 || fail
        x = matchers.dereference 0
        x._node_type_ == :int || fail
        x.as_integer == 3 || fail  # (not supposed to do this here but meh)
      end

      it 'the consequence expression' do
        _x = _first_when.any_consequence_expression
        _x._node_type_ == :nil || fail
      end

      def _first_when
        _same_thing.one_or_more_whens.dereference 0
      end
    end

    shared_subject :_same_thing do
      structured_node_via_string_ "case 1 ; when 3 ; nil ; else ; 4 end"
    end

    # --

    def _scrutinized
      at_ :scrutinized_expression
    end

    def _whens
      at_ :one_or_more_whens
    end

    def _else
      at_ :any_else_expression
    end

    # ==
    # ==
  end
end
# :#coverpoint2.4
# #born.
