require_relative 'test-support'

describe "#{::Skylab::TanMan::Sexp::Auto} list pattern (grammar 06)" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport

  using_grammar '06' do
    using_input '100-nerp' do
      it_unparses_losslessly
      it 'result lets you get the nerk' do
        o = result.nerk
        o.class.nt_name.should eql(:nerk)
        o.unparse.should eql('aaaa')
      end
    end
    let(:rest) { result.e1 }
    using_input '200-nerp' do
      it_unparses_losslessly
      it 'the second element is array-like' do
        o = rest
        o.should respond_to(:each)
        o.length.should eql(1)
      end
      it 'the first element of the above array looks like this' do
        x = rest.first
        x.class.nt_name.should eql(:nerks0)
        x.nerk.class.nt_name.should eql(:nerk)
        x.nerk.unparse.should eql('bbb2')
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
