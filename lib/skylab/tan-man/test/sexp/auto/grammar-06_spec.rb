require_relative 'test-support'

describe "[tm] Sexp::Auto list pattern (grammar 06)", g: true do

  extend ::Skylab::TanMan::TestSupport::Sexp::Auto

  using_grammar '06' do
    using_input '100-nerp' do
      it 'does not blink (works 2 times in a row)' do
        a = client.parse_string input_string
        b = client.parse_string input_string
        a.class.rule.should eql(:nerks)
        a.class.should eql(b.class)
        ( a.object_id == b.object_id ).should eql( false )
      end
      it_unparses_losslessly
      it 'result lets you get the nerk' do
        o = result.nerk
        o.class.respond_to?( :expression ).should eql( false )
        o.should eql('aaaa')
      end
    end

    let(:rest) { result.e1 }

    using_input '200-nerp' do
      it_unparses_losslessly
      it 'the second element is array-like' do
        o = rest
        o.should be_respond_to( :each )
        o.length.should eql(1)
      end
      it 'the first element of the above array looks like this' do
        x = rest.first
        x.class.expression.should eql(:nerks0)
        x.nerk.should eql('bbb2')
      end
    end

    using_input '300-nerp' do
      it_unparses_losslessly
      it 'lets you touch and see the final two members' do
        o = rest
        o.length.should eql(2)
        _ = o.map(&:unparse)
        [",bbb2", ",aa999"].should eql(_)
      end
    end
  end
end
