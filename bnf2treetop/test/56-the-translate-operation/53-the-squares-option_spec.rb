require_relative '../test-support'

describe "[bnf2tt] the translate operation - the `squares` option" do

  Skylab::BNF2Treetop::TestSupport[ self ]
  use :API

  it 'the parameter "square" lets you use square brackets differently' do
    normal = translate(string: 'foo ::= [bar]')
    crazy  = translate(string: 'foo ::= [bar]', squares: true)
    expect( normal_of normal ).to eql 'rule foo [bar] end'
    expect( normal_of crazy ).to eql 'rule foo bar? end'
  end
end
