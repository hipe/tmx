require_relative '../../test-support'

describe "[tm] sexp auto list pattern (grammar 06)", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto
  use :the_method_called_let

  using_grammar '06' do
    using_input '100-nerp' do
      it 'does not blink (works 2 times in a row)' do
        a = produce_result
        b = produce_result
        a.class.rule_symbol == :nerks || fail
        expect( a.class ).to eql b.class
        expect( a.object_id == b.object_id ).to eql false
      end
      it_unparses_losslessly
      it 'result lets you get the nerk' do
        o = result.nerk
        expect( o.class.respond_to?( :expression ) ).to eql false
        expect( o ).to eql 'aaaa'
      end
    end

    let(:rest) { result.e1 }

    using_input '200-nerp' do

      it_unparses_losslessly

      it 'the second element is array-like' do
        o = rest
        o.respond_to? :each or fail
        expect( o.length ).to eql 1
      end

      it 'the first element of the above array looks like this' do
        sx = rest.first
        sx.class.expression_symbol == :nerks0 || fail
        sx.nerk == 'bbb2' || fail
      end
    end

    using_input '300-nerp' do
      it_unparses_losslessly
      it 'lets you touch and see the final two members' do
        o = rest
        expect( o.length ).to eql 2
        _ = o.map(&:unparse)
        expect( [",bbb2", ",aa999"] ).to eql _
      end
    end
  end
end
