require_relative '../../test-support'

describe "[bnf2tt] API parameter - square" do

  Skylab::BNF2Treetop::TestSupport[ self ]
  use :API_parameters

  it 'the parameter "square" lets you use square brackets differently' do
    normal = translate(string: 'foo ::= [bar]')
    crazy  = translate(string: 'foo ::= [bar]', squares: true)
    normal_of( normal ).should eql('rule foo [bar] end')
    normal_of( crazy ).should  eql('rule foo bar? end')
  end
end
