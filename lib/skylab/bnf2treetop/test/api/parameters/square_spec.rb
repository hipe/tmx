require_relative 'test-support'

describe "[bnf2tt] API parameter - square" do

  extend ::Skylab::Bnf2Treetop::API::Parameters::TestSupport

  it 'the parameter "square" lets you use square brackets differently' do
    normal = translate(string: 'foo ::= [bar]')
    crazy  = translate(string: 'foo ::= [bar]', squares: true)
    normal_of( normal ).should eql('rule foo [bar] end')
    normal_of( crazy ).should  eql('rule foo bar? end')
  end
end
